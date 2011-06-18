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
		
		private var walkSpeed:Number;
		private var climbSpeed:Number;
		private var hitPoints:uint;
		private var state:uint;
		
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
			loadGraphic (VisitorImage, true, true, WIDTH, HEIGHT);
			addAnimation("walk", [0,1,2,3], Globals.ANIM_SPEED);
			play("walk");
			
			hitPoints = 1;
			state = STATE_WALKING;
			
			if (Math.random()*2 < 1) // enter from left side
			{
				velocity.x = walkSpeed;
				x = -WIDTH;
				facing = RIGHT;
			}
			else  // enter from right side
			{
				velocity.x = -walkSpeed;
				x = FlxG.width + WIDTH;
				facing = LEFT;
			}
		}
		
		public override function update():void
		{
			if (state == STATE_WALKING)
			{
				if ((facing == LEFT) && (x < Globals.CAGE_RIGHT)) {
					state = STATE_CLIMBING;
					x = Globals.CAGE_RIGHT;
				}
				
				if ((facing == RIGHT) && (x > Globals.CAGE_LEFT - WIDTH)) {
					state = STATE_CLIMBING;
					x = Globals.CAGE_LEFT - WIDTH;
				}
			}
			
			if (state == STATE_CLIMBING)
			{
				velocity.x = 0;
				velocity.y = -50;
			}
		}
	}
}
