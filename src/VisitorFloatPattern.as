package
{
	import org.flixel.*;
	import org.flixel.FlxSprite;

	public class VisitorFloatPattern
	{
		public static function walkFactory(visitor:Visitor)
			:VisitorFloatPattern
		{
			return new WalkPattern(visitor);
		}
		
		public static function sinusFactory(visitor:Visitor, spacing:Number = 0,
			amplitude:Number = 60, frequency:Number = 2):VisitorFloatPattern
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

class SinusFloatPattern extends VisitorFloatPattern
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

class WalkPattern extends VisitorFloatPattern
{
	private const STATE_WALKING:uint = 0;
	private const STATE_CLIMBING:uint = 1;
	
	private var visitor:Visitor;
	private var state:int;
	
	public function WalkPattern(visitor:Visitor):void
	{
		this.visitor = visitor;
		this.state = STATE_WALKING;
	}
	
	public override function update():void
	{
		if (state == STATE_WALKING)
		{
			update_walking();
		}
	}
	
	private function update_walking():void
	{
		if ((visitor.facing == LEFT) &&
		    (visitor.x < Globals.CAGE_RIGHT))
		{
			state = STATE_CLIMBING;
		}
		
		if ((visitor.facing == RIGHT) &&
		    (visitor.x > Globals.CAGE_LEFT - visitor.width))
		{
			state = STATE_CLIMBING;
		}
	}
	
	public override function getInfo():Object
	{
		var info:Object = new Object();
		info.location = new FlxPoint();
		info.velocity = new FlxPoint();
		info.location.x = visitor.x;
		info.location.y = visitor.y;
		info.state = Visitor.STATE_PATTERN;
		
		if (state == STATE_WALKING)
		{
			info.location.y = Globals.GROUND_LEVEL - visitor.height;
			info.velocity.y = 0;
			info.velocity.x = visitor.walkSpeed * ((visitor.facing == RIGHT) ? 1 : -1);
			info.anim = "walk";
		} else
		if (state == STATE_CLIMBING)
		{
			if (visitor.facing == LEFT)
			{
				info.location.x = Globals.CAGE_RIGHT;
			}
			
			if (visitor.facing == RIGHT)
			{
				info.location.x = Globals.CAGE_LEFT - visitor.width;
			}
			
			info.velocity.x = 0;
			info.velocity.y = -visitor.climbSpeed;
			info.anim = "climb";
			
			if (visitor.y < Globals.CAGE_TOP - visitor.height)
			{
				info.state = Visitor.STATE_JUMPING;
				info.velocity.y = visitor.jumpHeight;
			}
		} else
		{
			assert(false); // unknown state
		}
		
		return info;
	}
}
