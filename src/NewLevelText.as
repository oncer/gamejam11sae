package
{
	import org.flixel.*;
	
	public class NewLevelText extends FlxText
	{
		private const BASE_SIZE:Number = 30;
		
		private var timeToLive:Number;
		private var onDisappear:Function = null;
		
		public function NewLevelText():void
		{
			super (FlxG.width/2-100, 100, 200);
			alignment = "center";
			color = 0xffffff;
			size = 30;
			timeToLive = 5;
			onDisappear = null;
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
			if (timeToLive < 0) 
			{
				if (onDisappear != null) onDisappear();
				exists = false;
			}
		}
		
		public function setDisappearHandler(onDisappear:Function):void
		{
			this.onDisappear = onDisappear;
		}
	}
}
