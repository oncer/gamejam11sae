package
{
	import org.flixel.*;

	//This is the class declaration for the little player ship that you fly around in	
	public class Llama extends FlxGroup
	{
		[Embed(source="../gfx/lama.png")] private var ImgLlama:Class;	//Graphic of the player's ship
		[Embed(source = "../gfx/lama.png")] private var LamaClass:Class;	//Graphic of the player's ship
		[Embed(source="../gfx/crosshair.png")] private var TargetClass:Class;	//Graphic of the player's ship
		
		//We use this number to figure out how fast the ship is flying
		protected var _thrust:Number;
		
		public var lama:FlxSprite;		
		private var target:FlxSprite;
		public var jumpUpAcceleration : int;	
		
		[Editable (type = "slider", min = "-2000", max = "-100")]
		public var jumpUpVelocity:Number;	
		
		[Editable (type="slider", min="100", max="1000")]
		public var acceleration_y:Number;
		
		private var targetOffset:FlxPoint;
		//private var targetYOffset:Number;
		
		[Editable (type="watch")]
		public var watch_y:Number;
		
		//This function creates the ship, taking the list of bullets as a parameter
		public function Llama()
		{
			//super(FlxG.width/2-8, FlxG.height/2-8);
			//loadRotatedGraphic(LamaClass, 32, -1, false, true);
			lama = new FlxSprite(FlxG.width/2, FlxG.height/2);
			lama.loadGraphic(LamaClass);			
			//alterBoundingBox();
			_thrust = 0;
			//acceleration = new FlxPoint(0,200);
			
			jumpUpVelocity = -200;
			jumpUpAcceleration = -800;
			
			lama.acceleration.y = 200;			
			acceleration_y = lama.acceleration.y
			add(lama);
			
			targetOffset = new FlxPoint(0, -40);
			// position doesnt matter, gets updated in update anyway
			target = new FlxSprite(0,0);
			target.loadGraphic(TargetClass);
			add(target);
		}
		
		//The main game loop function
		override public function update():void
		{
			//wrap();			
			super.update();
			watch_y = lama.y;
			lama.acceleration.y = acceleration_y;
			
			if (lama.acceleration.y == jumpUpAcceleration) {
				lama.acceleration.y = 200;
			}
			if (lama.y > Globals.GROUND_LEVEL - lama.height) {
				lama.velocity.y = jumpUpVelocity;
			} if (lama.y > Globals.GROUND_LEVEL - lama.height) {
				lama.acceleration.y = jumpUpAcceleration;
			}
			
			target.x = lama.getMidpoint().x + targetOffset.x;
			target.y = lama.getMidpoint().y + targetOffset.y;
			
			if(FlxG.keys.LEFT)
				//angularVelocity -= 240;
				lama.acceleration.x = -50;
			if(FlxG.keys.RIGHT)
				//angularVelocity += 240;
				lama.acceleration.x = 50;
				
						
			var rotationDifferenceInDegrees:Number = 10;
				
			//This is where thrust is handled
			//acceleration.x = 0;
			//acceleration.y = 0;
			if (FlxG.keys.UP || FlxG.keys.DOWN) {
				
				var angleBefore:Number = FlxU.getAngle(targetOffset, new FlxPoint(0,0));
				//var angle:Number = FlxU.getAngle(new FlxPoint(target.x, target.y), new FlxPoint(lama.x, lama.y));
				trace("angle before: " + angleBefore);
						
			
				if (FlxG.keys.DOWN)
					rotationDifferenceInDegrees *= -1;
					
				// ATTENTION FlxU.rotatePoint is wrong!!!
				//var rotatedPoint:FlxPoint = FlxU.rotatePoint(targetOffset.x, targetOffset.y, 0, 0, 10)
				var rotatedPoint:FlxPoint = rotatePoint(targetOffset.x, targetOffset.y, 0, 0, rotationDifferenceInDegrees);				
								
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
			
			//FlxVelocity.moveTowardsObject(blue, green, 180);
			//	FlxU.rotatePoint(90,0,0,0,angle,acceleration);
			//FlxU.getAngle()

			if(FlxG.keys.justPressed("SPACE"))
			{
				//Space bar was pressed!  FIRE A BULLET
				/*var bullet:FlxSprite = (FlxG.state as PlayState).bullets.recycle() as FlxSprite;
				bullet.reset(x + (width - bullet.width)/2, y + (height - bullet.height)/2);
				bullet.angle = angle;
				FlxU.rotatePoint(150,0,0,0,bullet.angle,bullet.velocity);
				bullet.velocity.x += velocity.x;
				bullet.velocity.y += velocity.y;*/
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
