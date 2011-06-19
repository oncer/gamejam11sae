package
{
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.*;

	//This is the class declaration for the little player ship that you fly around in	
	public class Llama extends FlxGroup
	{
		[Embed(source = "../gfx/lama.png")] private var LamaClass:Class;
		[Embed(source = "../gfx/crosshair.png")] private var TargetClass:Class;
		[Embed(source = "../gfx/bar1.png")] private var Bar1Class:Class;
		[Embed(source = "../gfx/bar2.png")] private var Bar2Class:Class;
		
		[Embed(source = "../gfx/boost02.png")] private var UpgradesClass:Class;
		
		
		public static const UPGRADE_NONE:uint = 0;
		public static const UPGRADE_RAPIDFIRE:uint = 1;
		public static const UPGRADE_BIGSPIT:uint = 2;
		public static const UPGRADE_MULTISPAWN:uint = 3;
		public var upgradeType:uint;
		private var upgrade:FlxSprite;
		
		
		
		//We use this number to figure out how fast the ship is flying
		protected var _thrust:Number;
		
		public var lama:FlxSprite;
		private var target:FlxSprite;
		public var jumpUpAcceleration : int;	
		
		[Editable (type = "slider", min = "-2000", max = "-100")]
		public var jumpUpVelocity:Number;	
		
		[Editable (type="slider", min="100", max="1000")]
		public var max_acceleration_x:Number;
		
		[Editable (type="slider", min="10", max="5000")]
		public var drag_x:Number;
		
		[Editable (type="slider", min="100", max="1000")]
		public var acceleration_y:Number;
		
		private var spitOrigin:FlxPoint;
		// this is the px size from the left when the lama is facing right
		private static const SPIT_ORIGIN_PIXELS:Number = 40;
		private var targetOffset:FlxPoint;
		private var TARGET_DISTANCE:Number = 30;
		
		private static const FRAME_WIDTH:Number = 48;
		private static const FRAME_HEIGHT:Number = 64;
		
		private static const UPPER_TARGET_LIMIT_DEGREE:Number = 170;
		private static const LOWER_TARGET_LIMIT_DEGREE:Number = 60;
		// value needed, because the function rotatePoint() generates no exact results for the border values
		private var degreeThreshold:Number = 0;			
		// ATTENTION maybe change that in accordance to the range borders!
		private var rotationDifferenceInDegreesPerFrame:Number = 4;
		
		
		/** Gets increased by holding the space key - is in range between 0 and 100*/
		private var spitStrength:Number;
		private var spitStrengthBar:FlxBar;
		[Editable (type = "slider", min = "100", max = "300")]
		// factor for balancing that regulates the power multiplication of strength
		public var spitStrengthModifier:Number = 200;
		
		[Editable (type = "slider", min = "0.1", max = "10")]
		// factor for balancing that regulates the power multiplication of strength
		public var spitIncreasePerSecond:Number;
		
		[Editable (type = "slider", min = "0.1", max = "5")]
		// factor for balancing that regulates the power multiplication of strength
		public var spitCooldown:Number = 0.5;
		private var spitCooldownCounter:Number;
		
		private var spitCooldownArray:Array = new Array(spitCooldown, 0.2, 1, 1);
		// upgradeDuration for first upgrade doesnt make sense, no matter what value is set for that!
		private var upgradeDuration:Array = new Array(0, 10, 10, 10);
		private var upgradeDurationCounter:Number;
		
		// the spit animation in seconds, until the original random jump frame is set again
		private static const SPIT_ANIMATION_DURATION:Number = 0.1;
		private var spitAnimationCounter:Number;
		private var currentLamaJumpFrame:Number;
		
		private var ingameState:IngameState;
		
		//This function creates the ship, taking the list of bullets as a parameter
		public function Llama(INGAMESTATE:IngameState)
		{
			ingameState = INGAMESTATE;
			
			//super(FlxG.width/2-8, FlxG.height/2-8);
			//loadRotatedGraphic(LamaClass, 32, -1, false, true);
			lama = new FlxSprite(FlxG.width / 2, FlxG.height / 2);
			// set 3rd parameter to true because it must be flippable (by facing property)
			lama.loadGraphic(LamaClass, false, true, FRAME_WIDTH, FRAME_HEIGHT);			
			_thrust = 0;
			
			
			
			jumpUpVelocity = -560;
			
			max_acceleration_x = 1000;
			lama.acceleration.y = 800;
			acceleration_y = lama.acceleration.y
			lama.drag.x = 400;
			drag_x = lama.drag.x;
			add(lama);
			
			targetOffset = new FlxPoint(TARGET_DISTANCE, 0);
			// center of spitting where it should start, 39 from left, 31 from top
			spitOrigin = new FlxPoint(SPIT_ORIGIN_PIXELS, FRAME_HEIGHT - 31);
			
			// position doesnt matter, gets updated in update anyway
			target = new FlxSprite(0,0);
			target.loadGraphic(TargetClass);
			add(target);
			
			var barBorder:FlxSprite = new FlxSprite(FlxG.width - 40, 30);
			barBorder.loadGraphic(Bar1Class);
			add(barBorder);
			spitStrengthBar = new FlxBar(barBorder.x, barBorder.y, FlxBar.FILL_BOTTOM_TO_TOP, 32, 96);
			spitStrengthBar.createImageBar(null, Bar2Class, 0x00000000);
			add(spitStrengthBar);						
			spitStrength = 0;
			spitIncreasePerSecond = 200;
			
			upgrade = new FlxSprite(FlxG.width / 2, FlxG.height - 40);
			upgrade.loadGraphic(UpgradesClass, false, false, 32, 32);
			add(upgrade);
			
			lama.maxVelocity.x = 150;
			
			spitCooldownCounter = 0;
			spitAnimationCounter = 0;
			currentLamaJumpFrame = 0;			
			
			// change to this in the end, for testing now use the rapid fire upgrade from beginning
			setUpgradeType(UPGRADE_NONE);
			//setUpgradeType(UPGRADE_RAPIDFIRE);
			
			// this doesnt work, because th first frame always changes randomly !
			//lama.addAnimation("spit", [3, 0], 1 / (FlxG.framerate * 3) , false);			
		}
		
		//The main game loop function
		override public function update():void
		{	
			super.update();
			lama.acceleration.y = acceleration_y;
			lama.drag.x = drag_x;
			// updating the bar - old, which was the spitStrength
			//spitStrengthBar.percent = spitStrength;
			spitStrengthBar.percent = (spitCooldownCounter / spitCooldown) * 100;

			
			spitCooldownCounter += FlxG.elapsed;
			
			if (spitCooldownCounter > spitCooldown) {
				spitCooldownCounter = spitCooldown;
			}
			if (lama.frame == 3) {
				spitAnimationCounter += FlxG.elapsed;
				if (spitAnimationCounter >= SPIT_ANIMATION_DURATION) {
					spitAnimationCounter = 0;
					lama.frame = currentLamaJumpFrame;
				}
			}
			
			if (upgradeType != UPGRADE_NONE) {
				upgradeDurationCounter += FlxG.elapsed;
				if (upgradeDurationCounter > upgradeDuration[upgradeType]) {
					// upgrade is over 
					setUpgradeType(UPGRADE_NONE);
				}
			}
			
			if (lama.y > Globals.TRAMPOLIN_TOP - lama.height) {
				ingameState.trampolin.y = Globals.TRAMPOLIN_TOP + 5;
				ingameState.trampolin.velocity.y = -60;
				
				Globals.sfxPlayer.Trampolin();
				
				lama.y = Globals.TRAMPOLIN_TOP - lama.height + 5;
				lama.velocity.y = jumpUpVelocity;		
				
				//var currentFrame:Number = lama.frame;
				var randomFrame:Number = currentLamaJumpFrame;
				while (currentLamaJumpFrame == randomFrame) {
					var rand:Number = Math.random()*10;
					//trace(rand);
					randomFrame = Math.ceil(rand) % 3;				
				}
				lama.frame = randomFrame;
				currentLamaJumpFrame = randomFrame;	
			}				
			
			if(FlxG.keys.LEFT) {
				lama.acceleration.x = -max_acceleration_x;				
			} else if(FlxG.keys.RIGHT) {
				lama.acceleration.x = max_acceleration_x;
			} else {
				lama.acceleration.x = 0;
			}
			if (FlxG.keys.justPressed("LEFT")) {					
				if(lama.facing!=FlxObject.LEFT) {
					targetOffset.x *= -1;
					//46 is the width of 1 frame
					spitOrigin.x = FRAME_WIDTH - SPIT_ORIGIN_PIXELS;
				}
				lama.facing = FlxObject.LEFT;				
			} else if (FlxG.keys.justPressed("RIGHT")) {
				if (lama.facing != FlxObject.RIGHT) {
					targetOffset.x *= -1;
					spitOrigin.x = SPIT_ORIGIN_PIXELS;
				}
				lama.facing = FlxObject.RIGHT;				
			}			
						
			
			
			if (FlxG.keys.UP || FlxG.keys.DOWN) {
				
				var angleBefore:Number = FlxU.getAngle(targetOffset, new FlxPoint(0,0));
				//var angle:Number = FlxU.getAngle(new FlxPoint(target.x, target.y), new FlxPoint(lama.x, lama.y));
				//trace("angle before: " + angleBefore);
				
				// ATTENTION maybe change that in accordance to the range borders!
				var rotationDifferenceInDegrees:Number = rotationDifferenceInDegreesPerFrame;
				
				if (FlxG.keys.DOWN) {
					rotationDifferenceInDegrees *= -1;
				}
					
				if (lama.facing == FlxObject.LEFT)
					rotationDifferenceInDegrees *= -1;
					
				var rotatedPoint:FlxPoint;
				
				
				var newRotation:Number = angleBefore - rotationDifferenceInDegrees;
				//trace("newRotation: " + newRotation);
				if (Math.abs(newRotation) > (UPPER_TARGET_LIMIT_DEGREE-degreeThreshold)) {
					//var targetPoint
					//var tooMuchDegrees:Number = Math.abs(newRotation) - upperDegreeLimit;
					
					// 
					if (newRotation<0) {
						rotatedPoint = rotatePoint(0, -TARGET_DISTANCE, 0, 0, -UPPER_TARGET_LIMIT_DEGREE);
					} else {
						rotatedPoint = rotatePoint(0, -TARGET_DISTANCE, 0, 0, UPPER_TARGET_LIMIT_DEGREE);
					}
					rotatedPoint.y *= -1;
					//trace("fix set point x: " + rotatedPoint.x, ", y: " + rotatedPoint.y);										
					// newRotation might be 175, or -175; when 175 rotDif is +5, when -175 rotDif is -5
					//rotationDifferenceInDegrees = upperDegreeLimit-rotationDifferenceInDegrees;
				} else if (Math.abs(newRotation) < (LOWER_TARGET_LIMIT_DEGREE-degreeThreshold)) {
					if (newRotation<0) {
						rotatedPoint = rotatePoint(0, -TARGET_DISTANCE, 0, 0, -LOWER_TARGET_LIMIT_DEGREE);
					} else {
						rotatedPoint = rotatePoint(0, -TARGET_DISTANCE, 0, 0, LOWER_TARGET_LIMIT_DEGREE);
					}
					rotatedPoint.y *= -1;
				} else {
					// ATTENTION FlxU.rotatePoint is wrong!!!
					//var rotatedPoint:FlxPoint = FlxU.rotatePoint(targetOffset.x, targetOffset.y, 0, 0, 10)
					rotatedPoint = rotatePoint(targetOffset.x, targetOffset.y, 0, 0, rotationDifferenceInDegrees);				
				}								
				
								
				targetOffset = rotatedPoint;
				
				// gets updated next frame
				//target.x = lama.x + targetOffset.x;
				//target.y = lama.y + targetOffset.y;
				//trace("rotatedPoint x: " + rotatedPoint.x + ", y: " + rotatedPoint.y);
				
				//var angleAfter:Number = FlxU.getAngle(targetOffset.x, targetOffset.y);
				var angleAfter:Number = FlxU.getAngle(targetOffset, new FlxPoint(0,0));
				//angle = FlxU.getAngle(rotatedPoint, new FlxPoint(lama.x, lama.y));
				//trace("angle after: " + angleAfter + ", angle diff: " + (angleAfter-angleBefore));
			}			
			
			target.x = lama.x + spitOrigin.x + targetOffset.x - target.width/2;
			target.y = lama.y + spitOrigin.y + targetOffset.y - target.height/2;
			
			//FlxU.rotatePoint(90,0,0,0,angle,acceleration);
			//FlxU.getAngle()

			/*if (FlxG.keys.SPACE) {
				spitStrength += spitIncreasePerSecond * FlxG.elapsed;
				if (spitStrength > 100)
					spitStrength = 100;
			}*/
			//if(FlxG.keys.justReleased("SPACE"))
			if (FlxG.keys.SPACE) 
			{				
				//Space bar was pressed!  FIRE A BULLET
				/*var bullet:FlxSprite = (FlxG.state as PlayState).bullets.recycle() as FlxSprite;
				bullet.reset(x + (width - bullet.width)/2, y + (height - bullet.height)/2);
				bullet.angle = angle;
				FlxU.rotatePoint(150,0,0,0,bullet.angle,bullet.velocity);
				bullet.velocity.x += velocity.x;
				bullet.velocity.y += velocity.y;*/
				
				//trace("spitCooldownCounter: " + spitCooldownCounter);
				// only allow to spit when counter is higher than cooldown
				if(spitCooldownCounter>=spitCooldown) {
				
					var currentState:IngameState = FlxG.state as IngameState;
					
					Globals.sfxPlayer.Spit();
					var spit:Spit = currentState.spawnSpit(lama.x + spitOrigin.x, lama.y + spitOrigin.y);
					if (upgradeType == UPGRADE_MULTISPAWN)
						spit.setType(Spit.TYPE_MULTI_SPAWN);
					else if (upgradeType == UPGRADE_BIGSPIT)					
						spit.setType(Spit.TYPE_BIGSPIT);
						
					
					// this is needed, because with reset when reusing a spit from a pool, the shift for width/2 and height/2 would be lost!
					//spit.setCenterPosition(lama.x + spitOrigin.x, lama.y + spitOrigin.y);
					//var spit:Spit = currentState.spawnSpit(lama.x + spitOrigin.x, lama.y + spitOrigin.y);
					// 3rd parameter specifies how fast (the speed) the spit will reach the target, in pixels/second
					//FlxVelocity.moveTowardsObject(spit, target, spitStrength*spitStrengthModifier);

					//trace("diff x: " + (target.x - spit.x) + ", y: " + (target.y - spit.y));
					//trace("targetOffset.x: " + targetOffset.x + ", target.x: " + target.x + ", spit.x" + spit.x + ", spitOrigin.x: " + spitOrigin.x + ", lama.x: " + lama.x);
					//trace("targetOffset.y: " + targetOffset.y + ", target.y: " + target.y + ", spit.y" + spit.y + ", spitOrigin.y: " + spitOrigin.y + ", lama.y: " + lama.y);
					// ATTENTION: this method is BULLSHIT! takes into account the origin of source - wtf!? i never set that..
					//FlxVelocity.moveTowardsPoint(spit, new FlxPoint(spit.x + targetOffset.x, spit.y + targetOffset.y) , spitStrengthModifier);
										
					
					var angle:Number = FlxMath.asDegrees(Math.atan2(targetOffset.y, targetOffset.x));
					moveWithAngle(spit, angle, spitStrengthModifier);
					
					//trace("vx: " + spit.velocity.x + ", vy: " + spit.velocity.y);
					
					spitCooldownCounter = 0;
					spitAnimationCounter = 0;
					// set it to the spitting frame
					lama.frame = 3;
					
					// this would set the time,overwrites the speed
					//FlxVelocity.moveTowardsObject(spit, target, 180, 100);
					spitStrength = 0;
				}			
			}

		} // end of update
		
		public function setUpgradeType(UpgradeType:uint):void {
			trace("upgrade type set: " + UpgradeType);
			upgradeType = UpgradeType;
			spitCooldownCounter = spitCooldown; // can shoot instantly
			spitCooldown = spitCooldownArray[upgradeType];
			upgrade.frame = upgradeType;
			upgradeDurationCounter = 0;
		}
		
		static public function rotatePoint(X:Number, Y:Number, PivotX:Number, PivotY:Number, Angle:Number):FlxPoint {
			var flxp:FlxPoint = new FlxPoint();
			Angle *= 0.01745;
			var sin:Number = Math.sin(Angle);
			var cos:Number = Math.cos(Angle);
			var dx:Number = X - PivotX;
			var dy:Number = Y - PivotY;
			flxp.x = dx * cos + dy * sin;
			flxp.y = dy * cos - dx * sin;
			flxp.x += PivotX;
			flxp.y += PivotY;
			return flxp;
		}
		
		/**
		 * Find the angle (in radians) between an FlxSprite and an FlxPoint. The source sprite takes its x/y and origin into account.
		 * The angle is calculated in clockwise positive direction (down = 90 degrees positive, right = 0 degrees positive, up = 90 degrees negative)
		 * 
		 * @param	a			The FlxSprite to test from
		 * @param	target		The FlxPoint to angle the FlxSprite towards
		 * @param	asDegrees	If you need the value in degrees instead of radians, set to true
		 * 
		 * @return	Number The angle (in radians unless asDegrees is true)
		 */
		public static function angleBetweenPoint(source:FlxPoint, target:FlxPoint, asDegrees:Boolean = false):Number
        {
			var dx:Number = (target.x) - (source.x);
			var dy:Number = (target.y) - (source.y);
			
			if (asDegrees)
			{
				return FlxMath.asDegrees(Math.atan2(dy, dx));
			}
			else
			{
				return Math.atan2(dy, dx);
			}
        }
		
		public static function moveWithAngle(source:FlxSprite, angle:Number, speed:int):void
        {			
			var newV:FlxPoint = FlxVelocity.velocityFromAngle(angle, speed);
			source.velocity = newV;			
        }
		
	} // end of class llama
	
	
	}// end of package
