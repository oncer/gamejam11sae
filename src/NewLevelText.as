package
{
	import org.flixel.*;
	
	public class NewLevelText extends FlxText
	{
		private var timeToLive:Number;
		private const BASE_SIZE:Number = 30;
		
		public function NewLevelText():void
		{
			super (FlxG.width/2-100, 100, 200);
			alignment = "center";
			color = 0xffffff;
			size = 30;
			timeToLive = 5;
		}
		
		public function displayText(level:int):void
		{
			text = "Level " + level.toString();
			timeToLive = 5;
			exists = true;
		}
		
		override public function update():void
		{
			timeToLive -= FlxG.elapsed;
			if (timeToLive < 0) exists = false;
		}
	}
}
