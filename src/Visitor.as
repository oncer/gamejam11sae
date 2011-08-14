package
{
	import flash.utils.*;
	import org.flixel.*;

	// Visitors run towards the center and climb up on the cage.
	// When they reach the top and jump down the other side, you lose.
	public class Visitor extends FlxSprite
	{
		[Embed(source="../gfx/visitor1.png")]  private static const Visitor1Image:Class;
		[Embed(source="../gfx/visitor2.png")]  private static const Visitor2Image:Class;
		[Embed(source="../gfx/visitor3.png")]  private static const Visitor3Image:Class;
		[Embed(source="../gfx/visitor4.png")]  private static const Visitor4Image:Class;
		[Embed(source="../gfx/visitor5.png")]  private static const Visitor5Image:Class;
		[Embed(source="../gfx/visitor6.png")]  private static const Visitor6Image:Class;
		[Embed(source="../gfx/visitor7.png")]  private static const Visitor7Image:Class;
		[Embed(source="../gfx/visitor8.png")]  private static const Visitor8Image:Class;
		[Embed(source="../gfx/visitor9.png")]  private static const Visitor9Image:Class;
		[Embed(source="../gfx/visitor10.png")] private static const Visitor10Image:Class;
		
		[Embed(source="../gfx/spitparticle.png")] private var SpitParticleClass:Class;
		
		private static const visitorClasses:Array = new Array(Visitor1Image, Visitor2Image,
			Visitor3Image, Visitor4Image, Visitor5Image, Visitor6Image,
			Visitor7Image, Visitor8Image, Visitor9Image, Visitor10Image);
		
		public static const STATE_WALKING:uint = 0;
		public static const STATE_FLOATING:uint = 1;
		public static const STATE_CLIMBING:uint = 2;
		public static const STATE_JUMPING:uint = 3;
		public static const STATE_FLYING:uint = 4;
		public static const STATE_DYING:uint = 5;
		
		private var walkSpeed:Number;
		private var floatSpeed:Number;
		private var climbSpeed:Number;
		private var jumpSpeed:Number;
		private var jumpHeight:Number; // not really height, just velocity.y
		public var scorePoints:int; // killing this visitor is worth this much
		public var comboCounter:int; // visitors colliding drive this up
		private var state:uint;
		private var flyStartTime:Number; // timestamp of last start flying
		private var floatTime:Number; // timestamp of last start flying
		private var hasReachedGoal:Boolean; // then player loses a life
		private var visitorType:int;
		private var floatPattern:VisitorFloatPattern;
		
		private var explosion:FlxEmitter;
		
		public function Visitor():void
		{
			super(-50,-50);
			exists = false;
			addAnimation("walk", [0,1,2,3], Globals.ANIM_SPEED);
			addAnimation("float", [7], Globals.ANIM_SPEED);
			addAnimation("climb", [7], Globals.ANIM_SPEED);
			addAnimation("jump", [0], Globals.ANIM_SPEED);
			addAnimation("fly", [4,5], 1.2, false);
			addAnimation("die", [6], Globals.ANIM_SPEED, false);
		}
		
		// This function resets all values to represent a NEW visitor.
		// Type, position, speed, everything
		// is inferred from the current game difficulty.
		// spacing: adds additional distance from the screen border to make
		//     the visitor appear on stage later.
		public function init (visitorType:int, spacing:uint, facing:uint = 0, isFloating:Boolean = false):void
		{
			trace("Visitor.init spacing=" + spacing.toString());
			
			var __start__:int = flash.utils.getTimer();
			health = 1;
			comboCounter = 1;
			hasReachedGoal = false;
			floatTime = 0;
			
			this.visitorType = visitorType;
			
			loadGraphic (visitorClasses[visitorType], true, true,
				Globals.VISITOR_SPRITE_WIDTH, Globals.VISITOR_SPRITE_HEIGHT);
			floatSpeed = 30;
			scorePoints = Globals.VISITOR_POINTS[visitorType];
			
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
					walkSpeed = 30;
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
					walkSpeed = 32;
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
					walkSpeed = 26;
					climbSpeed = 28;
					jumpSpeed = 80;
					jumpHeight = -130;
					width = 18;
					height = 25;
					offset.x = 7;
					offset.y = 23;
					health = 2;
					break;
					
				case 4: // old lady
					walkSpeed = 21;
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
					health = 3;
					break;
					
			}
			
			var distanceFromScreenBorder:Number = walkSpeed * spacing;
			
			// set direction-dependent values
			if (facing == 0)
			{
				if (Math.random() < .5) // enter from left side
				{
					x = -distanceFromScreenBorder - width;
					facing = RIGHT;
				}
				else // enter from right side
				{
					x = FlxG.width + distanceFromScreenBorder;
					facing = LEFT;
				}
			}
			else if (facing == RIGHT) // enter from left side
			{
				x = -distanceFromScreenBorder;
			} else // enter from right side
			{
				x = FlxG.width + distanceFromScreenBorder;
			}
			
			super.facing = facing;
			
			explosion = new FlxEmitter();
			explosion.makeParticles(SpitParticleClass, 20, 16, true, 0);
			
			if (isFloating)
			{
				state = STATE_FLOATING;
				floatPattern = VisitorFloatPattern.sinusFactory(width, height, spacing, 60, 2, 30, facing);
				update_floating();
			}
			else
			{
				state = STATE_WALKING;
				update_walking();
			}
			
			revive();
			Profiler.profiler.profile('Visitor.init', flash.utils.getTimer() - __start__);
		}
		
		override public function revive():void
		{
			super.revive();
			play("walk");
		}
		
		override public function update():void
		{
			var __start__:int = flash.utils.getTimer();
			acceleration.x = 0;
			acceleration.y = 0;
			drag.x = 0;
			
			if (state == STATE_WALKING)
			{
				update_walking();
			}
			
			if (state == STATE_FLOATING)
			{
				update_floating();
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
			
			explosion.at(this);
			explosion.update();
			Profiler.profiler.profile('Visitor.update', flash.utils.getTimer() - __start__);
		}
		
		override public function draw():void
		{
			super.draw();
			explosion.draw();
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
		
		private function update_floating():void
		{
			play("float");
			floatPattern.update();
			
			var info:Object = floatPattern.getInfo();
			x = info.location.x;
			y = info.location.y;
			velocity = info.velocity;
			state = info.state;
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
			
			if (y > Globals.VISITOR_GOAL_Y)
			{
				alpha = Math.max(0, (Globals.VISITOR_GOAL_Y - y + 100) / 100);
				
				if (!hasReachedGoal)
				{
					hasReachedGoal = true;
					(FlxG.state as IngameState).loseLife ();
				}
			}
			
			if (y > FlxG.height)
			{
				exists = false
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
					comboCounter = 1; // reset; next time we fly, combo is back to 1
					
					if (health <= 0)
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
		
		private function startSpitExplosion():void
		{
			var d:Number = 50;
			var x1:Number = velocity.x - d;
			var x2:Number = velocity.x + d;
			var y1:Number = velocity.y - d * 1.5;
			var y2:Number = velocity.y + d * 0.5;
			explosion.setXSpeed(Math.min(x1,x2), Math.max(x1,x2));
			explosion.setYSpeed(Math.min(y1,y2), Math.max(y1,y2));
			explosion.gravity = acceleration.y;
			explosion.start(true,0.5);
		}
		
		private function scream():void
		{
			if (visitorType == 0 || visitorType == 5) {
				Globals.sfxPlayer.ScreamKid();
			} else if (visitorType == 1 || visitorType == 3 ||
					   visitorType == 6 || visitorType == 8) {
				Globals.sfxPlayer.ScreamMan();
			} else if (visitorType == 4 || visitorType == 9) {
				Globals.sfxPlayer.ScreamOldWoman();
			} else if (visitorType == 2 || visitorType == 7) {
				Globals.sfxPlayer.ScreamWoman();
			}
		}
		
		public function getSpitOn (spit:Spit):void
		{
			scream();
			if (health > 0)
			{
				health -= 1;
			}
			
			state = STATE_FLYING;
			flyStartTime = (FlxG.state as IngameState).elapsedTime;
			play("fly");
			velocity.x = spit.velocity.x;
			velocity.y = spit.velocity.y;
			
			comboCounter = spit.getCombo();
			
			if (y > Globals.GROUND_LEVEL - height - 2) // if standing on ground
			{
				velocity.x /= 2;
			}
			
			if (health <= 0)
			{
				(FlxG.state as IngameState).causeScore(this, scorePoints, comboCounter);
			}
			
			startSpitExplosion(); // particle effects
		}
		
		public function getHitByPerson (flying:Visitor):void
		{
			scream();
			if (health > 0)
			{
				health -= 1;
			}
			
			state = STATE_FLYING;
			flyStartTime = (FlxG.state as IngameState).elapsedTime;
			play("fly");
			velocity.x = flying.velocity.x * .7;
			velocity.y = flying.velocity.y * .7;
			
			if (y > Globals.GROUND_LEVEL - height - 2) // if standing on ground
			{
				velocity.x /= 2;
			}
			
			startSpitExplosion(); // particle effects
			
			comboCounter = flying.comboCounter + 1;
			
			if (flying.health <= 0)
			{
				flying.comboCounter++;
			}
			
			if (health <= 0)
			{
				(FlxG.state as IngameState).causeScore(this, scorePoints, comboCounter);
			}
		}
		
		public function getType():int
		{
			return visitorType;
		}
		
		public static function getTypeImage(visitorType:int):Class
		{
			return visitorClasses[visitorType];
		}
		
		public function jumpIntoCage():void
		{
		}
	}
}
