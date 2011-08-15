package
{
	import org.flixel.*;

	public class VisitorFloatPattern
	{
		public static function sinusFactory(visitorWidth:int, visitorHeight:int, 
			spacing:Number = 0, amplitude:Number = 60, frequency:Number = 2, 
			xspeed:Number = 30, facing:int = 0):VisitorFloatPattern
		{
			return new SinusFloatPattern(visitorWidth, visitorHeight,
			                             spacing, amplitude, frequency,
			                             xspeed, facing);
		}
		
		public function update():void { }
		
		/*
		 * Returns an Object with the following members:
		 *   .location: current FlxPoint for the visitor
		 *   .velocity: current velocity
		 *   .state: at the end, this is used to set the state to e.g. climbing
		 */
		public function getInfo():Object { return null; }
	}
}

import org.flixel.*;

const LEFT:uint = FlxObject.LEFT;
const RIGHT:uint = FlxObject.RIGHT;

class SinusFloatPattern extends VisitorFloatPattern
{

	private var timeLeft:Number; // in seconds until cage reached
	
	private var visitorWidth:int;
	private var visitorHeight:int;
	private var amplitude:Number;
	private var frequency:Number;
	private var xspeed:Number;
	private var facing:int;
	
	public function SinusFloatPattern(visitorWidth:int, visitorHeight:int, spacing:Number = 0, amplitude:Number = 60, frequency:Number = 2, xspeed:Number = 30, facing:int = 0):void
	{
		this.visitorWidth = visitorWidth;
		this.visitorHeight = visitorHeight;
		this.amplitude = amplitude;
		this.frequency = frequency;
		this.xspeed = xspeed;
		
		if (facing == 0) 
		{
			facing = (Math.random() < .5) ? FlxObject.LEFT : FlxObject.RIGHT;
		} 
		this.facing = facing;
		
		if (facing == LEFT)
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
		
		location.y = Globals.CAGE_TOP - visitorHeight - amplitude +
			Math.cos(timeLeft * frequency) * amplitude;
		velocity.y = Math.sin(timeLeft * frequency) * amplitude;
				
		if (facing == LEFT)
		{
			location.x = Globals.CAGE_RIGHT + timeLeft * this.xspeed;
			velocity.x = -xspeed;
			
			if (location.x > Globals.CAGE_RIGHT)
			{
				state = Visitor.STATE_FLOATING;
			}
			else
			{
				state = Visitor.STATE_CLIMBING;
			}
		}
		
		if (facing == RIGHT)
		{
			location.x = Globals.CAGE_LEFT - visitorWidth - timeLeft * this.xspeed;
			velocity.x = xspeed;
			
			if (location.x < Globals.CAGE_LEFT - visitorWidth)
			{
				state = Visitor.STATE_FLOATING;
			}
			else
			{
				state = Visitor.STATE_CLIMBING;
			}
		}
		
		var info:Object = new Object();
		info.location = location;
		info.velocity = velocity;
		info.state = state;
		return info;
	}
}
