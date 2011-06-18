package
{
	import org.flixel.*;

	// Visitors run towards the center and climb up on the cage.
	// When they reach the top and jump down the other side, you lose.
	public class Visitor extends FlxSprite
	{
		[Embed(source="../gfx/visitor1.png")] private var Visitor1Image:Class;
		[Embed(source="../gfx/visitor2.png")] private var Visitor2Image:Class;
		
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
		
		public function Visitor()
		{
			super(0,0);
			exists = false;
		}
		
		// This function resets all values to represent a NEW visitor.
		// Type, position, speed, everything
		// is inferred from the current game difficulty.
		public function init (difficulty:Number, facing:uint = 0):void
		{
			var visitorType:Number = Math.random()*2;
			if (visitorType < 1) // Child
			{
				walkSpeed = 50;
				climbSpeed = 50;
				jumpSpeed = 100;
				jumpHeight = -200;
				loadGraphic (Visitor1Image, true, true, WIDTH, HEIGHT);
			} else // man with glasses & hat
			{
				walkSpeed = 35;
				climbSpeed = 35;
				jumpSpeed = 130;
				jumpHeight = -250;
				loadGraphic (Visitor2Image, true, true, WIDTH, HEIGHT);
			} 
			
			y = Globals.GROUND_LEVEL - HEIGHT;
			velocity.y = 0;
			acceleration.y = 0;
			super.facing = facing;
		}
		
		public override function revive():void
		{
			super.revive();
			
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
				update_walking();
			}
			
			// not 'else if' because state may have changed in update_walking
			if (state == STATE_CLIMBING)
			{
				update_climbing();
			}
			
			if (state == STATE_JUMPING)
			{
				update_jumping();
			}
			
			if (state == STATE_FLYING)
			{
				update_flying();
			}
		}
		
		private function update_walking():void
		{
			play("walk");
			
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
		
		private function update_climbing():void
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
		
		private function update_jumping():void
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
			
			if (y > FlxG.height)
			{
				exists = false;
			}
		}
		
		private function update_flying():void
		{
			acceleration.y = 200;
			play("fly");
			
			if (y > FlxG.height)
			{
				exists = false;
			}
		}
		
		public function getSpitOn (spit:Spit):void
		{
			state = STATE_FLYING;
			velocity.x = spit.velocity.x;
			velocity.y = spit.velocity.y;
		}
	}
}
