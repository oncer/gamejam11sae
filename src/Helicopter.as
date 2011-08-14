package  
{	
	import org.flixel.FlxSprite;
	import org.flixel.*;
	
	/**
	 * ...
	 * @author Chris
	 */
	public class Helicopter extends FlxGroup 
	{
		
		[Embed(source = "../gfx/helicopter.png")]  private var HelicopterClass:Class;
		[Embed(source = "../gfx/upgrades.png")]  private var UpgradesClass:Class;
		[Embed(source="../gfx/spitparticle.png")] private var SpitParticleClass:Class;
		[Embed(source="../gfx/kiste.png")] private var CrateClass:Class;
		
		/** has the same value like one of Llama. */
		private var upgradeType:uint;
		/** x velocity. */
		private var HELICOPTER_VELOCITY:uint = 200;		
		private var UPGRADEBOX_VELOCITY_AFTER_HIT:uint = 100;		
		private var HELICOPTER_Y:uint = 40;
		// this is the center where the upgrade box should spawn
		// +2 is necessary, because the upgrade frame has 1 pixel border (left and right)

		private var UPGRADE_CENTER_OFFSET_X:int = 46+2;
		
		private var helicopterSprite:FlxSprite;
		private var upgradeSprite:FlxSprite;
		private var crateDestroySprite:FlxSprite;
		
		private var isUpgradeHit:Boolean;
		private var isUpgradeDead:Boolean;
		private var isChopperOut:Boolean;
		
		private var explosion:FlxEmitter;
		private var isFacingRight:Boolean;
		
		private var ingameState:IngameState;
		
		public function Helicopter(INGAMESTATE:IngameState) 
		{
			ingameState = INGAMESTATE;
			// x doesnt matter, gets set in startHelicopter
			//super(0, HELICOPTER_Y);
			helicopterSprite = new FlxSprite(0, HELICOPTER_Y);
			// can be a unique instance, as only 1 copter is displayed at a single time
			helicopterSprite.loadGraphic(HelicopterClass, true, true, 96, 80, true);
			helicopterSprite.addAnimation("fly", [0, 1, 2, 3], 30, true);
			helicopterSprite.play("fly");			
			add(helicopterSprite);
			helicopterSprite.x = -100;
						
			upgradeSprite = new FlxSprite(0, 0);
			upgradeSprite.loadGraphic(UpgradesClass, false, false, 32, 32);
			add(upgradeSprite);
			
			crateDestroySprite = new FlxSprite(0, 0);
			crateDestroySprite.loadGraphic(CrateClass, true, false, 32, 32);
			crateDestroySprite.addAnimation("destroy", [0, 1, 2], 5, false);
			crateDestroySprite.exists = false;
			add(crateDestroySprite);
			
			isUpgradeHit = false;
			isUpgradeDead = false;
			isChopperOut = false;
			
			explosion = new FlxEmitter();
			add(explosion);
		}
		
		public function startHelicopter():void {
			trace("start a new helicopter");
			
			var random:int = Math.ceil(Math.random() * 10);
			upgradeType = random % Globals.N_UPGRADE_TYPES;
			trace("upgrade type: " + upgradeType);
			upgradeSprite.frame = upgradeType;
						
			// determine the facing direction
			var randomDirection:int = random % 2;
			// start right
			if (randomDirection == 0) {
				// start from the left side of the screen
				helicopterSprite.x = 0-helicopterSprite.frameWidth;
				
				helicopterSprite.velocity.x = HELICOPTER_VELOCITY;
				helicopterSprite.facing = FlxObject.RIGHT;
				isFacingRight = true;
			} else {
				helicopterSprite.x = FlxG.width;
				helicopterSprite.velocity.x = -HELICOPTER_VELOCITY;
				helicopterSprite.facing = FlxObject.LEFT;
				isFacingRight = false;
			}
			
			// the box has 1 transparent pixel at the border
			upgradeSprite.x = helicopterSprite.x+UPGRADE_CENTER_OFFSET_X-upgradeSprite.width/2;
			upgradeSprite.y = helicopterSprite.y + helicopterSprite.height - 1;
			upgradeSprite.acceleration = new FlxPoint(0, 0);
			upgradeSprite.velocity = new FlxPoint(0, 0);
			upgradeSprite.drag = new FlxPoint(0, 0);
			upgradeSprite.exists = true;
			crateDestroySprite.exists = false;
			
			isUpgradeHit = false;
			isUpgradeDead = false;
			isChopperOut = false;
			
			Globals.sfxPlayer.ChopperIn();
		}
		
		override public function update():void
		{
			super.update();
			// stop if outside of screen
			if (!isChopperOut && (helicopterSprite.x < -100 || helicopterSprite.x > FlxG.width+100)) {
				helicopterSprite.velocity.x = 0;
				Globals.sfxPlayer.ChopperOut();
				isChopperOut = true;
			} else if (!isUpgradeHit) {
				upgradeSprite.x = helicopterSprite.x+UPGRADE_CENTER_OFFSET_X-upgradeSprite.width/2;
			}
			
			if (isUpgradeDead && crateDestroySprite.finished)
			{
				crateDestroySprite.exists = false;
			}
			if (!isUpgradeDead && upgradeSprite.y + upgradeSprite.height > Globals.GROUND_LEVEL) {
				crateDestroySprite.exists = true;
				crateDestroySprite.x = upgradeSprite.x;
				crateDestroySprite.y = Globals.GROUND_LEVEL - upgradeSprite.height;
				crateDestroySprite.velocity.x = upgradeSprite.velocity.x;
				crateDestroySprite.acceleration.y = 0;
				crateDestroySprite.velocity.y = 0;
				crateDestroySprite.drag.x = 600;
				upgradeSprite.exists = false;
				crateDestroySprite.play("destroy");
				Globals.sfxPlayer.Upgrade();
				ingameState.setUpgrade();

				isUpgradeDead = true;
			}
		}
		
		public function getUpgradeSprite():FlxSprite 
		{
			return upgradeSprite;
		}
		
		public function getUpgradeType():uint
		{
			return upgradeType;
		}
		
		public function upgradeHit(spit:FlxObject):void 
		{
			isUpgradeHit = true;
			upgradeSprite.acceleration.y = 200;
			upgradeSprite.velocity.x = helicopterSprite.velocity.x;
			upgradeSprite.drag.x = 20;
			
			Globals.sfxPlayer.Splotsh();
			
			explosion.makeParticles(SpitParticleClass, 20, 16, true, 0);
			explosion.at(spit);
			explosion.setXSpeed(-50, 50);
			explosion.setYSpeed(-50, 50);
			explosion.gravity = upgradeSprite.acceleration.y;
			explosion.start(true);
			if(isFacingRight) {
				upgradeSprite.velocity.x = UPGRADEBOX_VELOCITY_AFTER_HIT;
			} else {
				upgradeSprite.velocity.x = -UPGRADEBOX_VELOCITY_AFTER_HIT;
			}
		}
		
		public function canUpgradeHit():Boolean
		{
			return !isUpgradeHit;
		}
		
		/**
		 * "Everything" refers to the chopper and the upgrade box.
		 * When those are all invisible, we can change level #
		 * without statistics glitches (shoot upgrade & get on next
		 * level)
		 */
		public function isEverythingOut():Boolean
		{
			return isChopperOut && isUpgradeDead;
		}
	}

}
