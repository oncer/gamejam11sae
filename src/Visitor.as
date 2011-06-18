package
{
	import org.flixel.*;

	// Visitors run towards the center and climb up on the cage.
	// When they reach the top and jump down the other side, you lose.
	public class Visitor extends FlxSprite
	{
		[Embed(source="../gfx/visitor1.png")] private var VisitorImage:Class;
		
		public static const STATE_WALKING:uint = 1;
		public static const STATE_CLIMBING:uint = 2;
		public static const STATE_JUMPING:uint = 3;
		public static const STATE_FLYING:uint = 4;
		public static const STATE_DYING:uint = 5;
		
		private var walkSpeed:Number;
		private var climbSpeed:Number;
		private var hitPoints:uint;
		private var state:uint;
		
		// Creates a new visitor. Type, position, speed, everything
		// is inferred from the current game difficulty.
		public function Visitor (difficulty:Number)
		{
			var fromLeft:Boolean; // enter from left side or from right side
			
			if (Math.random() >= .5)
				fromLeft = true;
			else
				fromLeft = false;
			
			super(0, Globals.GROUND_LEVEL);
			loadGraphic(VisitorImage,true,false,32,48);
			velocity.x = 200;
		}
		
		override public function update():void
		{
		}
	}
}
