package
{
	import org.flixel.*;
	
	public class TotalScoreText extends FlxText
	{
		private var timer:Number;
		
		private const BASE_SIZE:Number = 20;
		private var currentSize:Number;
		private var baseX:Number;
		private var baseY:Number;
		
		public function TotalScoreText():void
		{
			baseX = FlxG.width - 235;
			baseY = 30;
			super (baseX, baseY - height/2, 200);
			alignment = "right";
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
			x = baseX + (currentSize - BASvE_SIZE) / 4;
			
			var overSize:Number = Math.floor((currentSize - BASE_SIZE) * 25);
			color = 0x10000 * (0xFF - overSize) + 0xFF00 + (0xFF - overSize);
		}
	}
}
