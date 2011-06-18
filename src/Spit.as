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
		
		public function Spit(center:FlxPoint) 
		{
			// the spit is 16x16
			super(center.x-8, center.y-8);
			loadGraphic(SpitClass);
		}
		
		override public function update():void
		{		
			super.update();
			
			//trace("spit vel x: " + velocity.x + ", y:" + velocity.y);
			//trace("spit acc x: " + acceleration.x + ", y:" + acceleration.y);
			if (y > FlxG.height)
				kill();
		}
		
	}

}