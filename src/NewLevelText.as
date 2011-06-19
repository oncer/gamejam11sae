package
{
	import org.flixel.*;
	
	public class NewLevelText extends FlxText
	{
		private var timer:Number;
		
		private const BASE_SIZE:Number = 30;
		private var currentSize:Number;
		private var baseX:Number;
		private var baseY:Number;
		
		public function TotalScoreText():void
		{
			super (FlxG.width/2-100, 100, 200);
			alignment = "center";
			text = "SCORE: 0";
			color = 0xffffff;
			size = BASE_SIZE;
			currentSize = BASE_SIZE;
		}
		
		public function setText(score:int, gain:int):void
		{
			text = "SCORE: " + score.toString();
			currentSize = Math.min(26, currentSize + gain);
		}
		
		override public function update():void
		{
			currentSize = (currentSize - BASE_SIZE) / Math.pow(2.0, FlxG.elapsed) + BASE_SIZE;
			size = currentSize;
			y = baseY - height/2;
			x = baseX + (currentSize - BASE_SIZE) / 4;
		}
	}
}
