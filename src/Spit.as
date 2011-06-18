package  
{
	import org.flixel.FlxSprite;
	import org.flixel.*;
	
	/**
	 * ...
	 * @author Chris
	 */
	public class Spit extends FlxSprite 
	{
		
		[Embed(source="../gfx/spit.png")] private var SpitClass:Class;
		
		private var _canHit:Boolean;
		
		public function Spit(center:FlxPoint) 
		{
			// the spit is 16x16
			super(center.x-8, center.y-8);
			loadGraphic(SpitClass);
			acceleration.y = 200;
			exists = false;
			_canHit = true;
		}
		
		override public function update():void
		{		
			super.update();
			
			//trace("spit vel x: " + velocity.x + ", y:" + velocity.y);
			//trace("spit acc x: " + acceleration.x + ", y:" + acceleration.y);
			if (y > FlxG.height)
				kill();
		}
		
		public override function revive():void
		{
			_canHit = true;
			super.revive();
		}
		
		public function canHit (visitor:Visitor):Boolean
		{
			return _canHit;
		}
		
		public function hitSomething ():void
		{
			velocity.x /= 1.5;
			velocity.y = 0;
			_canHit = false;
		}
	}

}
