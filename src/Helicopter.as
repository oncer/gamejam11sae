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
		
		/** has the same value like one of Llama. */
		private var upgradeType:uint;
		/** x velocity. */
		private var VELOCITY:uint = 200;		
		private var HELICOPTER_Y:uint = 30;
		// this is the center where the upgrade box should spawn
		// +2 is necessary, because the upgrade frame has 1 pixel border (left and right)
		private var UPGRADE_CENTER_OFFSET_X:uint = 46+2;
		
		private var helicopterSprite:FlxSprite;
		private var upgradeSprite:FlxSprite;
		
		private var isUpgradeHit:Boolean;
		private var isUpgradeDead:Boolean;
		
		private var explosion:FlxEmitter;
		
		public function Helicopter() 
		{			
			// x doesnt matter, gets set in startHelicopter
			//super(0, HELICOPTER_Y);
			helicopterSprite = new FlxSprite(0, HELICOPTER_Y);
			// can be a unique instance, as only 1 copter is displayed at a single time
			helicopterSprite.loadGraphic(HelicopterClass, true, true, 96, 80, true);
			helicopterSprite.addAnimation("fly", [0, 1, 2, 3], 30, true);
			helicopterSprite.play("fly");			
			add(helicopterSprite);
						
			upgradeSprite = new FlxSprite(0, 0);
			upgradeSprite.loadGraphic(UpgradesClass, false, false, 32, 32);
			add(upgradeSprite);
			
			isUpgradeHit = false;
			isUpgradeDead = false;
		}
		
		public function startHelicopter():void {
			trace("start a new helicopter");
			
			var random:int = Math.ceil(Math.random() * 10);
			upgradeType = random % 3;
			trace("upgrade type: " + upgradeType);
			upgradeSprite.frame = upgradeType;
						
			// determine the facing direction
			var randomDirection:int = random % 2;
			// start right
			if (randomDirection == 0) {
				// start from the left side of the screen
				helicopterSprite.x = 0;
				
				helicopterSprite.velocity.x = VELOCITY;
				helicopterSprite.facing = FlxObject.RIGHT;
			} else {
				helicopterSprite.x = FlxG.width;
				helicopterSprite.velocity.x = -VELOCITY;
				helicopterSprite.facing = FlxObject.LEFT;
			}
			
			// the box has 1 transparent pixel at the border
			upgradeSprite.y = helicopterSprite.y + helicopterSprite.height - 1;
			upgradeSprite.acceleration.y = 0;
			upgradeSprite.velocity.x = 0;
			upgradeSprite.velocity.y = 0;
			isUpgradeHit = false;
			
		}
		
		override public function update():void
		{
			super.update();
			// stop if outside of screen
			if (helicopterSprite.x < -100 || helicopterSprite.x > FlxG.width+100) {
				helicopterSprite.velocity.x = 0;
			} else if (!isUpgradeHit) {
				upgradeSprite.x = helicopterSprite.x+UPGRADE_CENTER_OFFSET_X-upgradeSprite.width/2;
			}
			if (upgradeSprite.y + upgradeSprite.height > Globals.GROUND_LEVEL) {
				upgradeSprite.y = Globals.GROUND_LEVEL - upgradeSprite.height;
				upgradeSprite.acceleration.y = 0;
				upgradeSprite.drag.x = 600;
				upgradeSprite.flicker(1);
				isUpgradeDead = true;
			}
			/*if (isUpgradeDead && !upgradeSprite.flickering)
			{
				kill();
			}*/
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
			
			explosion = new FlxEmitter();
			explosion.makeParticles(SpitParticleClass, 20, 16, true, 0);
			explosion.at(spit);
			add(explosion);
			explosion.setXSpeed(-50, 50);
			explosion.setYSpeed(-50, 50);
			explosion.gravity = upgradeSprite.acceleration.y;
			explosion.start(true);
		}
		
		public function canUpgradeHit():Boolean
		{
			return !isUpgradeHit;
		}
	}

}
