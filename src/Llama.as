package
{
	import org.flixel.*;

	//This is the class declaration for the little player ship that you fly around in
	public class Llama extends FlxSprite
	{
		[Embed(source="../gfx/lama.png")] private var ImgLlama:Class;	//Graphic of the player's ship
		
		//We use this number to figure out how fast the ship is flying
		protected var _thrust:Number;
		
		[Editable (type="slider", min="-2000", max="-100")]
		public var jumpUpVelocity:Number;
		
		[Editable (type="slider", min="100", max="1000")]
		public var acceleration_y:Number;
		
		[Editable (type="watch")]
		public var watch_y:Number;
		
		//This function creates the ship, taking the list of bullets as a parameter
		public function Llama()
		{
			super(FlxG.width/2-16, FlxG.height/2-16);
			loadGraphic(ImgLlama,false,true);
			//alterBoundingBox();
			_thrust = 0;
			//acceleration = new FlxPoint(0,200);
			acceleration_y = acceleration.y = 800;
			jumpUpVelocity = -560;
		}
		
		//The main game loop function
		override public function update():void
		{
			//wrap();
			watch_y = y;
			acceleration.y = acceleration_y;
			
			if (y > Globals.GROUND_LEVEL - height) {
				velocity.y = jumpUpVelocity;
			}
			
			if(FlxG.keys.LEFT)
				//angularVelocity -= 240;
				acceleration.x = -50;
			if(FlxG.keys.RIGHT)
				//angularVelocity += 240;
				acceleration.x = 50;
				
						
			//This is where thrust is handled
			//acceleration.x = 0;
			//acceleration.y = 0;
			//if(FlxG.keys.UP)
			//	FlxU.rotatePoint(90,0,0,0,angle,acceleration);

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
		}
	}
}
