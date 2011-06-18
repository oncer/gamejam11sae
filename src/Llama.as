package
{
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.*;

	//This is the class declaration for the little player ship that you fly around in	
	public class Llama extends FlxGroup
	{
		[Embed(source = "../gfx/lama.png")] private var LamaClass:Class;
		[Embed(source = "../gfx/crosshair.png")] private var TargetClass:Class;
		[Embed(source="../gfx/flectrum.png")] private var HealthBarClass:Class;
		
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
		private var spitOriginFromGrahpic:Number = 40;
		private var targetOffset:FlxPoint;
		private var targetDistance:Number = 30;
		
		private var upperDegreeLimit:Number = 170;
		private var lowerDegreeLimit:Number = 60;
		// value needed, because the function rotatePoint() generates no exact results for the border values
		private var degreeThreshold:Number = 2;			
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
		// the spit animation in seconds, until the original random jump frame is set again
		private var spitAnimationDuration:Number = 0.6;
		private var spitAnimationCounter:Number;
		private var currentLamaJumpFrame:Number;
		
		[Editable (type="watch")]
		public var watch_y:Number;
		
		//This function creates the ship, taking the list of bullets as a parameter
		public function Llama()
		{
			//super(FlxG.width/2-8, FlxG.height/2-8);
			//loadRotatedGraphic(LamaClass, 32, -1, false, true);
			lama = new FlxSprite(FlxG.width / 2, FlxG.height / 2);
			// set 3rd parameter to true because it must be flippable (by facing property)
			lama.loadGraphic(LamaClass, false, true, 48, 64);			
			_thrust = 0;
			
			jumpUpVelocity = -560;
			
			max_acceleration_x = 1000;
			lama.acceleration.y = 800;
			acceleration_y = lama.acceleration.y
			lama.drag.x = 400;
			drag_x = lama.drag.x;
			add(lama);
			
			targetOffset = new FlxPoint(targetDistance, 0);
			// center of spitting where it should start, 39 from left, 31 from top
			spitOrigin = new FlxPoint(spitOriginFromGrahpic, 64 - 31);
			
			// position doesnt matter, gets updated in update anyway
			target = new FlxSprite(0,0);
			target.loadGraphic(TargetClass);
			add(target);
			
			spitStrengthBar = new FlxBar(FlxG.width-20, 20, FlxBar.FILL_BOTTOM_TO_TOP, 10, 100);
			spitStrengthBar.createImageBar(null, HealthBarClass, 0x88000000);
			add(spitStrengthBar);			
			spitStrength = 0;
			spitIncreasePerSecond = 200;
			
			lama.maxVelocity.x = 150;
			
			spitCooldownCounter = 0;
			spitAnimationCounter = 0;
			currentLamaJumpFrame = 0;
			
			// this doesnt work, because th first frame always changes randomly !
			//lama.addAnimation("spit", [3, 0], 1 / (FlxG.framerate * 3) , false);			
		}
		
		//The main game loop function
		override public function update():void
		{	
			super.update();
			watch_y = lama.y;
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
				if (spitAnimationCounter >= spitAnimationDuration) {
					spitAnimationCounter = 0;
					lama.frame = currentLamaJumpFrame;
				}
			}
			
			if (lama.y > Globals.GROUND_LEVEL - lama.height) {
				lama.y = Globals.GROUND_LEVEL - lama.height;
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
			
			target.x = lama.x + spitOrigin.x + targetOffset.x - target.width/2;
			target.y = lama.y + spitOrigin.y + targetOffset.y - target.height/2;			
			
			if(FlxG.keys.LEFT) {
				lama.acceleration.x = -max_acceleration_x;				
			} else if(FlxG.keys.RIGHT) {
				lama.acceleration.x = max_acceleration_x;
			} else {
				lama.acceleration.x = 0;
				//lama.velocity.x = 0;
			}
			if (FlxG.keys.justPressed("LEFT")) {					
				if(lama.facing!=FlxObject.LEFT) {
					targetOffset.x *= -1;
					//46 is the width of 1 frame
					spitOrigin.x = 46 - spitOriginFromGrahpic;
				}
				lama.facing = FlxObject.LEFT;				
			} else if (FlxG.keys.justPressed("RIGHT")) {
				if (lama.facing != FlxObject.RIGHT) {
					targetOffset.x *= -1;
					spitOrigin.x = spitOriginFromGrahpic;
				}
				lama.facing = FlxObject.RIGHT;				
			}			
						
			
			
			if (FlxG.keys.UP || FlxG.keys.DOWN) {
				
				var angleBefore:Number = FlxU.getAngle(targetOffset, new FlxPoint(0,0));
				//var angle:Number = FlxU.getAngle(new FlxPoint(target.x, target.y), new FlxPoint(lama.x, lama.y));
				trace("angle before: " + angleBefore);
				
				// ATTENTION maybe change that in accordance to the range borders!
				var rotationDifferenceInDegrees:Number = rotationDifferenceInDegreesPerFrame;
				
				if (FlxG.keys.DOWN) {
					rotationDifferenceInDegrees *= -1;
				}
					
				if (lama.facing == FlxObject.LEFT)
					rotationDifferenceInDegrees *= -1;
					
				var rotatedPoint:FlxPoint;
				
				
				var newRotation:Number = angleBefore - rotationDifferenceInDegrees;
				trace("newRotation: " + newRotation);
				if (Math.abs(newRotation) > (upperDegreeLimit-degreeThreshold)) {
					//var targetPoint
					//var tooMuchDegrees:Number = Math.abs(newRotation) - upperDegreeLimit;
					
					// 
					if (newRotation<0) {
						rotatedPoint = rotatePoint(0, -targetDistance, 0, 0, -upperDegreeLimit);
					} else {
						rotatedPoint = rotatePoint(0, -targetDistance, 0, 0, upperDegreeLimit);
					}
					rotatedPoint.y *= -1;
					//trace("fix set point x: " + rotatedPoint.x, ", y: " + rotatedPoint.y);										
					// newRotation might be 175, or -175; when 175 rotDif is +5, when -175 rotDif is -5
					//rotationDifferenceInDegrees = upperDegreeLimit-rotationDifferenceInDegrees;
				} else if (Math.abs(newRotation) < (lowerDegreeLimit-degreeThreshold)) {
					if (newRotation<0) {
						rotatedPoint = rotatePoint(0, -targetDistance, 0, 0, -lowerDegreeLimit);
					} else {
						rotatedPoint = rotatePoint(0, -targetDistance, 0, 0, lowerDegreeLimit);
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
				trace("rotatedPoint x: " + rotatedPoint.x + ", y: " + rotatedPoint.y);
				
				//var angleAfter:Number = FlxU.getAngle(targetOffset.x, targetOffset.y);
				var angleAfter:Number = FlxU.getAngle(targetOffset, new FlxPoint(0,0));
				//angle = FlxU.getAngle(rotatedPoint, new FlxPoint(lama.x, lama.y));
				trace("angle after: " + angleAfter + ", angle diff: " + (angleAfter-angleBefore));
			}
			
			
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
					var spit:Spit = currentState.spawnSpit(lama.x + spitOrigin.x, lama.y + spitOrigin.y);
					// 3rd parameter specifies how fast (the speed) the spit will reach the target, in pixels/second
					//FlxVelocity.moveTowardsObject(spit, target, spitStrength*spitStrengthModifier);
					FlxVelocity.moveTowardsObject(spit, target, spitStrengthModifier);
					
					spitCooldownCounter = 0;
					spitAnimationCounter = 0;
					// set it to the spitting frame
					lama.frame = 3;
					
					// this would set the time,overwrites the speed
					//FlxVelocity.moveTowardsObject(spit, target, 180, 100);
					spitStrength = 0;
				}			
			}
			
		}// end of update
		
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
		
	} // end of class llama
	
	
	}// end of package
