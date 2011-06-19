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
		
		private var isUpgradeHit:Boolean;
		private var isFacingRight:Boolean;
		
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
			} else {
				if(!isUpgradeHit)
					upgradeSprite.x = helicopterSprite.x+UPGRADE_CENTER_OFFSET_X-upgradeSprite.width/2;
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
		
		public function upgradeHit():void 
		{
			isUpgradeHit = true;
			upgradeSprite.acceleration.y = 200;
			if(isFacingRight)
				upgradeSprite.velocity.x = UPGRADEBOX_VELOCITY_AFTER_HIT;
			else
				upgradeSprite.velocity.x = -UPGRADEBOX_VELOCITY_AFTER_HIT;
			
		}
		
		public function canUpgradeHit():Boolean
		{
			return !isUpgradeHit;
		}
	}

}
