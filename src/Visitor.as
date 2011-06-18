package
{
	import org.flixel.*;

	// Visitors run towards the center and climb up on the cage.
	// When they reach the top and jump down the other side, you lose.
	public class Visitor extends FlxSprite
	{
		[Embed(source="../gfx/visitor1.png")] private var VisitorImage:Class;
		
		private static const WIDTH:uint = 32;
		private static const HEIGHT:uint = 48;
		
		private static const STATE_WALKING:uint = 0;
		private static const STATE_CLIMBING:uint = 1;
		private static const STATE_JUMPING:uint = 2;
		private static const STATE_FLYING:uint = 3;
		private static const STATE_DYING:uint = 4;
		
		private static const DIR_LEFT:uint = 1; // coming from right
		private static const DIR_RIGHT:uint = 2; // coming from left
		
		private var walkSpeed:Number;
		private var climbSpeed:Number;
		private var hitPoints:uint;
		private var state:uint;
		private var direction:uint;
		
		// Creates a new visitor. Type, position, speed, everything
		// is inferred from the current game difficulty.
		public function Visitor (difficulty:Number)
		{
			super(0, Globals.GROUND_LEVEL - HEIGHT);
			walkSpeed = 50;
			climbSpeed = 50;
			
			create(); // todo: this can also be used as revive() maybe
		}
		
		private function create():void
		{
			loadGraphic(VisitorImage,true,false,WIDTH,HEIGHT);
			
			hitPoints = 1;
			state = STATE_WALKING;
			direction = 0;
			
			if (Math.random() >= .5) // enter from left side
			{
				direction = DIR_RIGHT;
				velocity.x = walkSpeed;
				x = 0;
			}
			else  // enter from right side
			{
				direction = DIR_LEFT;
				velocity.x = -walkSpeed;
				x = FlxG.width;
			}
		}
		
		override public function update():void
		{
		}
	}
}
