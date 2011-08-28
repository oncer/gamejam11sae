package
{
	import org.flixel.*;
	import org.flixel.FlxObject;

	public class VisitorPattern
	{
		public static function walkClimbFactory(visitor:Visitor)
			:VisitorPattern
		{
			return new WalkClimbPattern(visitor);
		}
		
		public static function walkJumpClimbFactory(visitor:Visitor,
			jumpReach:Number = 0, jumpInterval:Number = 4,
			jumpHeight:Number = 100, jumpTime:Number = 1):VisitorPattern
		{
			return new WalkJumpClimbPattern(visitor, jumpReach, jumpInterval,
			                                jumpHeight, jumpTime);
		}
		
		public static function sinusFactory(visitor:Visitor, spacing:Number = 0,
			amplitude:Number = 60, frequency:Number = 2):VisitorPattern
		{
			return new SinusFloatPattern(visitor, spacing, amplitude, frequency);
		}
		
		public function update():void { }
		
		/*
		 * Returns an Object with the following members:
		 *   .location: current FlxPoint for the visitor
		 *   .velocity: current velocity
		 *   .state: at the end, this is used to set the state to e.g. climbing
		 *   .anim: string name of the animation to play for the visitor
		 */
		public function getInfo():Object { assert(false); return null; }
	}
}

import org.flixel.*;

const LEFT:uint = FlxObject.LEFT;
const RIGHT:uint = FlxObject.RIGHT;

class SinusFloatPattern extends VisitorPattern
{

	private var timeLeft:Number; // in seconds until cage reached
	
	private var visitor:Visitor;
	private var amplitude:Number;
	private var frequency:Number;
	private var xspeed:Number;
	
	public function SinusFloatPattern(visitor:Visitor, spacing:Number = 0,
		amplitude:Number = 60, frequency:Number = 2):void
	{
		this.visitor = visitor
		this.amplitude = amplitude;
		this.frequency = frequency;
		this.xspeed = 30;
		
		if (visitor.facing == LEFT)
		{
			timeLeft = (FlxG.width - Globals.CAGE_RIGHT) / xspeed;
		}
		else
		{
			timeLeft = Globals.CAGE_LEFT / xspeed;
		}
		
		timeLeft += spacing;
	}
	
	public override function update():void
	{
		timeLeft -= FlxG.elapsed;
	}
	
	public override function getInfo():Object
	{
		var location:FlxPoint = new FlxPoint();
		var velocity:FlxPoint = new FlxPoint();
		var state:uint;
		
		location.y = Globals.CAGE_TOP - visitor.height - amplitude +
			Math.cos(timeLeft * frequency) * amplitude;
		velocity.y = Math.sin(timeLeft * frequency) * amplitude;
				
		if (visitor.facing == LEFT)
		{
			location.x = Globals.CAGE_RIGHT + timeLeft * xspeed;
			velocity.x = -xspeed;
			
			if (location.x > Globals.CAGE_RIGHT)
			{
				state = Visitor.STATE_PATTERN;
			}
			else
			{
				state = Visitor.STATE_JUMPING;
				info.velocity.y = visitor.jumpHeight;
			}
		}
		
		if (visitor.facing == RIGHT)
		{
			location.x = Globals.CAGE_LEFT - visitor.width - timeLeft * xspeed;
			velocity.x = xspeed;
			
			if (location.x < Globals.CAGE_LEFT - visitor.width)
			{
				state = Visitor.STATE_PATTERN;
			}
			else
			{
				state = Visitor.STATE_JUMPING;
				info.velocity.y = visitor.jumpHeight;
			}
		}
		
		var info:Object = new Object();
		info.location = location;
		info.velocity = velocity;
		info.state = state;
		info.anim = "float";
		return info;
	}
}

class WalkClimbPattern extends VisitorPattern
{
	private const STATE_WALKING:uint = 0;
	private const STATE_CLIMBING:uint = 1;
	
	private var visitor:Visitor;
	private var state:int;
	
	public function WalkClimbPattern(visitor:Visitor):void
	{
		this.visitor = visitor;
		this.state = STATE_WALKING;
	}
	
	public override function update():void
	{
		if ((state == STATE_WALKING) && (distanceFromCage() <= 0))
		{
			state = STATE_CLIMBING;
		}
	}
	
	private function distanceFromCage():int
	{
		if (visitor.facing == LEFT)
		{
			return visitor.x - Globals.CAGE_RIGHT;
		}
		else
		{
			return Globals.CAGE_LEFT - visitor.width - visitor.x;
		}
	}
	
	private function getWalkInfo():Object
	{
		var info:Object = new Object();
		var vel_x:Number = visitor.walkSpeed * ((visitor.facing == RIGHT) ? 1 : -1);
		info.location = new FlxPoint(visitor.x, Globals.GROUND_LEVEL - visitor.height);
		info.velocity = new FlxPoint(vel_x, 0);
		info.state = Visitor.STATE_PATTERN;
		info.anim = "walk";
		return info;
	}
	
	private function getClimbInfo():Object
	{
		var info:Object = new Object();
		
		if (visitor.facing == LEFT)
		{
			info.location = new FlxPoint(Globals.CAGE_RIGHT, visitor.y);
		}
		else
		{
			info.location = new FlxPoint(Globals.CAGE_LEFT - visitor.width, visitor.y);
		}
		
		if (visitor.y < Globals.CAGE_TOP - visitor.height) // arrived at top
		{
			info.velocity = new FlxPoint(0, -visitor.jumpHeight);
			info.state = Visitor.STATE_JUMPING;
			info.anim = "jump";
		}
		else
		{
			info.velocity = new FlxPoint(0, -visitor.climbSpeed);
			info.state = Visitor.STATE_PATTERN;
			info.anim = "climb";
		}
		
		return info;
	}
	
	public override function getInfo():Object
	{
		if (state == STATE_WALKING)
		{
			return getWalkInfo();
		} else
		if (state == STATE_CLIMBING)
		{
			return getClimbInfo();
		} else
		{
			assert(false); // unknown state
			return null;
		}
	}
}

class WalkJumpClimbPattern extends VisitorPattern
{
	private const STATE_WALKING:uint = 0;
	private const STATE_JUMPING:uint = 1;
	private const STATE_CLIMBING:uint = 2;
	
	private var visitor:Visitor;
	private var state:int;
	private var jumpReach:Number;
	private var jumpInterval:Number;
	private var jumpHeight:Number;
	private var jumpTime:Number; // total time of one jump
	private var elapsed:Number; // time in seconds since last jump
	
	public function WalkJumpClimbPattern(visitor:Visitor, jumpReach:Number = 0,
		jumpInterval:Number = 4, jumpHeight:Number = 100, jumpTime:Number = 1):void
	{
		assert(jumpInterval > 0);
		assert(jumpHeight > 0);
		assert(jumpReach >= 0);
		assert((jumpTime > 0) && (jumpTime <= jumpInterval));
		
		this.visitor = visitor;
		this.state = STATE_WALKING;
		this.jumpReach = jumpReach;
		this.jumpInterval = jumpInterval;
		this.jumpHeight = jumpHeight;
		this.jumpTime = jumpTime;
		this.elapsed = 0;
	}
	
	public override function update():void
	{
		elapsed += FlxG.elapsed;
		
		if (state == STATE_WALKING)
		{
			if (mayJumpNow())
			{
				state = STATE_JUMPING;
				elapsed -= jumpInterval;
			}
			
			if (distanceFromCage() <= 0)
			{
				state = STATE_CLIMBING;
			}
		} else
		if (state == STATE_JUMPING)
		{
			if (elapsed >= jumpTime)
			{
				state = STATE_WALKING;
			}
		}
	}
	
	private function distanceFromCage():int
	{
		if (visitor.facing == LEFT)
		{
			return visitor.x - Globals.CAGE_RIGHT;
		}
		else
		{
			return Globals.CAGE_LEFT - visitor.width - visitor.x;
		}
	}
	
	private function mayJumpNow():Boolean
	{
		return (elapsed >= jumpInterval) && (distanceFromCage() > jumpReach);
	}
	
	private function haveArrivedAtCage():Boolean
	{
		return distanceFromCage() <= 0;
	}
	
	private function getWalkInfo():Object
	{
		var info:Object = new Object();
		var vel_x:Number = visitor.walkSpeed * ((visitor.facing == RIGHT) ? 1 : -1);
		info.location = new FlxPoint(visitor.x, Globals.GROUND_LEVEL - visitor.height);
		info.velocity = new FlxPoint(vel_x, 0);
		info.state = Visitor.STATE_PATTERN;
		info.anim = "walk";
		return info;
	}
	
	private function getJumpInfo():Object
	{
		var t:Number = elapsed / jumpTime; // 0 .. 1
		var vx:Number = jumpReach / jumpTime * ((visitor.facing == RIGHT) ? 1 : -1);
		var vy:Number = 4 * jumpHeight * (1 - t*2);
		var y:Number = 4 * jumpHeight * t * (1 - t);
		
		assert((y >= 0) && (y <= jumpHeight));
		// assert(Math.abs(vy) <= (jumpHeight / jumpReach)); // ?
		
		var info:Object = new Object();
		info.location = new FlxPoint(visitor.x, Globals.GROUND_LEVEL - visitor.height - y);
		info.velocity = new FlxPoint(vx, vy);
		info.state = Visitor.STATE_PATTERN;
		info.anim = "jump";
		return info;
	}
	
	private function getClimbInfo():Object
	{
		var info:Object = new Object();
		
		if (visitor.facing == LEFT)
		{
			info.location = new FlxPoint(Globals.CAGE_RIGHT, visitor.y);
		}
		else
		{
			info.location = new FlxPoint(Globals.CAGE_LEFT - visitor.width, visitor.y);
		}
		
		if (visitor.y < Globals.CAGE_TOP - visitor.height) // arrived at top
		{
			info.velocity = new FlxPoint(0, -visitor.jumpHeight);
			info.state = Visitor.STATE_JUMPING;
			info.anim = "jump";
		}
		else
		{
			info.velocity = new FlxPoint(0, -visitor.climbSpeed);
			info.state = Visitor.STATE_PATTERN;
			info.anim = "climb";
		}
		
		return info;
	}
	
	public override function getInfo():Object
	{
		if (state == STATE_WALKING)
		{
			return getWalkInfo();
		} else
		if (state == STATE_JUMPING)
		{
			return getJumpInfo();
		} else
		if (state == STATE_CLIMBING)
		{
			return getClimbInfo();
		} else
		{
			assert(false); // unknown state
			return null;
		}
	}
}
