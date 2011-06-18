package
{
	import org.flixel.*;

	// Visitors run towards the center and climb up on the cage.
	// When they reach the top and jump down the other side, you lose.
	public class Visitor extends FlxSprite
	{
		[Embed(source="../gfx/visitor1.png")]  private var Visitor1Image:Class;
		[Embed(source="../gfx/visitor2.png")]  private var Visitor2Image:Class;
		[Embed(source="../gfx/visitor3.png")]  private var Visitor3Image:Class;
		[Embed(source="../gfx/visitor4.png")]  private var Visitor4Image:Class;
		[Embed(source="../gfx/visitor5.png")]  private var Visitor5Image:Class;
		[Embed(source="../gfx/visitor6.png")]  private var Visitor6Image:Class;
		[Embed(source="../gfx/visitor7.png")]  private var Visitor7Image:Class;
		[Embed(source="../gfx/visitor8.png")]  private var Visitor8Image:Class;
		[Embed(source="../gfx/visitor9.png")]  private var Visitor9Image:Class;
		[Embed(source="../gfx/visitor10.png")] private var Visitor10Image:Class;
		
		private var visitorClasses:Array = new Array(Visitor1Image, Visitor2Image,
			Visitor3Image, Visitor4Image, Visitor5Image, Visitor6Image,
			Visitor7Image, Visitor8Image, Visitor9Image, Visitor10Image);
		
		private static const SPRITE_WIDTH:uint = 32;
		private static const SPRITE_HEIGHT:uint = 48;
		
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
		private var flyStartTime:Number; // timestamp of last start flying
		
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
			
			var visitorType:uint = Math.floor(Math.random()*5);
			if (Math.random()*5 < 1) visitorType += 5; // rare variations
			
			loadGraphic (visitorClasses[visitorType], true, true, SPRITE_WIDTH, SPRITE_HEIGHT);
			
			switch (visitorType)
			{
				case 0: // Child
				case 5:
					walkSpeed = 75;
					climbSpeed = 50;
					jumpSpeed = 100;
					jumpHeight = -200;
					width = 16;
					height = 21;
					offset.x = 8;
					offset.y = 27;
					break;
					
				case 1: // man with glasses & hat
				case 6:
					walkSpeed = 53;
					climbSpeed = 35;
					jumpSpeed = 130;
					jumpHeight = -250;
					width = 16;
					height = 28;
					offset.x = 8;
					offset.y = 20;
					break;
					
				case 2: // woman
				case 7:
					walkSpeed = 38;
					climbSpeed = 70;
					jumpSpeed = 130;
					jumpHeight = -250;
					width = 18;
					height = 25;
					offset.x = 7;
					offset.y = 23;
					break;
					
				case 3: // fat tourist
				case 8:
					walkSpeed = 30;
					climbSpeed = 28;
					jumpSpeed = 80;
					jumpHeight = -130;
					width = 18;
					height = 25;
					offset.x = 7;
					offset.y = 23;
					hitPoints = 2;
					break;
					
				case 4: // old lady
					walkSpeed = 25;
					climbSpeed = 45;
					jumpSpeed = 90;
					jumpHeight = -150;
					width = 16;
					height = 24;
					offset.x = 9;
					offset.y = 24;
					break;
					
				case 9: // zombie lady
					walkSpeed = 16;
					climbSpeed = 45;
					jumpSpeed = 90;
					jumpHeight = -150;
					width = 16;
					height = 24;
					offset.x = 9;
					offset.y = 24;
					hitPoints = 3;
					break;
					
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
				
				var flyTime:Number = (FlxG.state as IngameState).elapsedTime - flyStartTime;
				if ((flyTime >= Globals.FLY_TIMEOUT) && (Math.abs(velocity.x) < 10))
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
		
		public function canHitSomeone ():Boolean
		{
			return exists && (state == STATE_FLYING) && (Math.abs(velocity.x) >= 30);
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
			flyStartTime = (FlxG.state as IngameState).elapsedTime;
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
			flyStartTime = (FlxG.state as IngameState).elapsedTime;
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
