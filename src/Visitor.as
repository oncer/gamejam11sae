package
{
	import org.flixel.*;

	// Visitors run towards the center and climb up on the cage.
	// When they reach the top and jump down the other side, you lose.
	public class Visitor extends FlxSprite
	{
		[Embed(source="../gfx/visitor1.png")] private var Visitor1Image:Class;
		[Embed(source="../gfx/visitor2.png")] private var Visitor2Image:Class;
		[Embed(source="../gfx/visitor3.png")] private var Visitor3Image:Class;
		[Embed(source="../gfx/visitor4.png")] private var Visitor4Image:Class;
		
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
			hitPoints = 1;
			
			var visitorType:Number = Math.random()*4;
			if (visitorType < 1) // Child
			{
				walkSpeed = 50;
				climbSpeed = 50;
				jumpSpeed = 100;
				jumpHeight = -200;
				loadGraphic (Visitor1Image, true, true, WIDTH, HEIGHT);
				width = 16;
				height = 21;
				offset.x = 8;
				offset.y = 27;
			} else 
			if (visitorType < 2) // man with glasses & hat
			{
				walkSpeed = 35;
				climbSpeed = 35;
				jumpSpeed = 130;
				jumpHeight = -250;
				loadGraphic (Visitor2Image, true, true, WIDTH, HEIGHT);
				width = 16;
				height = 28;
				offset.x = 8;
				offset.y = 20;
			} else
			if (visitorType < 3) // woman
			{
				walkSpeed = 25;
				climbSpeed = 70;
				jumpSpeed = 130;
				jumpHeight = -250;
				loadGraphic (Visitor3Image, true, true, WIDTH, HEIGHT);
				width = 18;
				height = 25;
				offset.x = 7;
				offset.y = 23;
			} else // fat tourist
			{
				walkSpeed = 17;
				climbSpeed = 28;
				jumpSpeed = 80;
				jumpHeight = -130;
				loadGraphic (Visitor4Image, true, true, WIDTH, HEIGHT);
				width = 18;
				height = 25;
				offset.x = 7;
				offset.y = 23;
				hitPoints = 2;
			} 
			
			super.facing = facing;
		}
		
		public override function revive():void
		{
			super.revive();
			
			addAnimation("walk", [0,1,2,3], Globals.ANIM_SPEED);
			addAnimation("climb", [7], Globals.ANIM_SPEED);
			addAnimation("jump", [0], Globals.ANIM_SPEED);
			addAnimation("fly", [4,5], 1.2, false);
			addAnimation("die", [6], Globals.ANIM_SPEED, false);
			play("walk");
			
			state = STATE_WALKING;
			
			// set direction-dependent values
			if (facing == 0)
			{
				if (Math.random()*2 < 1) // enter from left side
				{
					x = -width;
					facing = RIGHT;
				}
				else // enter from right side
				{
					x = FlxG.width + width;
					facing = LEFT;
				}
			}
			else if (facing == RIGHT) // enter from left side
			{
				x = -width;
			} else // enter from right side
			{
				x = FlxG.width + width;
			}
		}
		
		public override function update():void
		{
			acceleration.x = 0;
			acceleration.y = 0;
			drag.x = 0;
			
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
			
			if (state == STATE_DYING)
			{
				update_dying();
			}
		}
		
		private function update_walking():void
		{
			y = Globals.GROUND_LEVEL - height;
			velocity.y = 0;
			play("walk");
			
			if (facing == LEFT)
			{
				velocity.x = -walkSpeed;
				
				if (x < Globals.CAGE_RIGHT)
				{
					state = STATE_CLIMBING;
					x = Globals.CAGE_RIGHT;
				}
			}
			
			if (facing == RIGHT)
			{
				velocity.x = walkSpeed;
				
				if (x > Globals.CAGE_LEFT - width)
				{
					state = STATE_CLIMBING;
					x = Globals.CAGE_LEFT - width;
				}
			}
		}
		
		private function update_climbing():void
		{
			play("climb");
			velocity.x = 0;
			velocity.y = -climbSpeed;
			
			if (y < Globals.CAGE_TOP - height)
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
			drag.x = 50;
			
			if (y > Globals.GROUND_LEVEL - height)
			{
				y = Globals.GROUND_LEVEL - height;
				velocity.y = -velocity.y * .4;
				
				if (Math.abs(velocity.x) < 10)
				{
					if (hitPoints <= 0)
					{
						state = STATE_DYING;
						flicker(1);
					}
					else
					{
						state = STATE_WALKING;
						if (x < FlxG.width/2)
						{
							facing = RIGHT;
						}
						else
						{
							facing = LEFT;
						}
					}
				}
			}
		}
		
		private function update_dying():void
		{
			velocity.x = 0;
			velocity.y = 0;
			y = Globals.GROUND_LEVEL - height;
			play("die");
			
			if (!flickering)
			{
				exists = false;
			}
		}
		
		// visitors can be hit by spit as long
		// as they are not already being hit
		public function canBeHit ():Boolean
		{
			return (state != STATE_FLYING) && (state != STATE_DYING);
		}
		
		public function getSpitOn (spit:Spit):void
		{
			if (hitPoints > 0) hitPoints--;
			state = STATE_FLYING;
			play("fly");
			velocity.x = spit.velocity.x;
			velocity.y = spit.velocity.y;
			
			if (y > Globals.GROUND_LEVEL - height - 2) // if standing on ground
			{
				velocity.x /= 2;
			}
		}
		
		public function getHitByPerson (flying:Visitor):void
		{
			if (hitPoints > 0) hitPoints--;
			state = STATE_FLYING;
			play("fly");
			velocity.x = flying.velocity.x * .7;
			velocity.y = flying.velocity.y * .7;
			
			if (y > Globals.GROUND_LEVEL - height - 2) // if standing on ground
			{
				velocity.x /= 2;
			}
		}
	}
}
