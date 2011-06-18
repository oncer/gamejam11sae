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
		private var jumpSpeed:Number;
		private var jumpHeight:Number; // not really height, just accel.y
		private var hitPoints:uint;
		private var state:uint;
		
		// Creates a new visitor. Type, position, speed, everything
		// is inferred from the current game difficulty.
		public function Visitor (difficulty:Number, facing:uint = 0)
		{
			super(0, Globals.GROUND_LEVEL - HEIGHT);
			walkSpeed = 50;
			climbSpeed = 50;
			jumpSpeed = 100;
			jumpHeight = -200;
			super.facing = facing;
			
			create(); // todo: this can also be used as revive() maybe
		}
		
		private function create():void
		{
			loadGraphic (VisitorImage, true, true, WIDTH, HEIGHT);
			addAnimation("walk", [0,1,2,3], Globals.ANIM_SPEED);
			addAnimation("climb", [7], Globals.ANIM_SPEED);
			addAnimation("jump", [0], Globals.ANIM_SPEED);
			addAnimation("fly", [4,5], .6);
			addAnimation("die", [6], Globals.ANIM_SPEED);
			play("walk");
			
			hitPoints = 1;
			state = STATE_WALKING;
			
			// set direction-dependent values
			if (facing == 0)
			{
				if (Math.random()*2 < 1) // enter from left side
				{
					velocity.x = walkSpeed;
					x = -WIDTH;
					facing = RIGHT;
				}
				else // enter from right side
				{
					velocity.x = -walkSpeed;
					x = FlxG.width + WIDTH;
					facing = LEFT;
				}
			}
			else if (facing == RIGHT) // enter from left side
			{
				velocity.x = walkSpeed;
				x = -WIDTH;
			} else // enter from right side
			{
				velocity.x = -walkSpeed;
				x = FlxG.width + WIDTH;
			}
		}
		
		public override function update():void
		{
			if (state == STATE_WALKING)
			{
				if ((facing == LEFT) && (x < Globals.CAGE_RIGHT))
				{
					state = STATE_CLIMBING;
					x = Globals.CAGE_RIGHT;
				}
				
				if ((facing == RIGHT) && (x > Globals.CAGE_LEFT - WIDTH))
				{
					state = STATE_CLIMBING;
					x = Globals.CAGE_LEFT - WIDTH;
				}
			}
			
			if (state == STATE_CLIMBING)
			{
				play("climb");
				velocity.x = 0;
				velocity.y = -climbSpeed;
				
				if (y < Globals.CAGE_TOP - HEIGHT)
				{
					state = STATE_JUMPING;
					velocity.y = jumpHeight;
				}
			}
			
			if (state == STATE_JUMPING)
			{
				if (facing == LEFT) 
				{
					velocity.x = -jumpSpeed;
				}
				else
				{
					velocity.x = jumpSpeed;
				}
				acceleration.y = 800;
				
				play("jump");
			}
		}
	}
}
