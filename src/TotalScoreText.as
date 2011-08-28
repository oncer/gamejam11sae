package
{
	import org.flixel.*;
	
	public class TotalScoreText extends FlxBitmapFont
	{
		private var timer:Number;
		
		private const BASE_SIZE:Number = 24;
		private var currentSize:Number;
		private var baseX:Number;
		private var baseY:Number;
		
		[Embed(source = "../gfx/font.png")] private static var fontClass:Class;
		private static const CHARS:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 :.!?-";
		private static const WIDTHS:Array = new Array(
			16, 16, 16, 16, 16, 16, 18, 16,
			 7, 14, 16, 16, 22, 18, 18, 16,
			19, 16, 16, 17, 17, 17, 22, 17,
			16, 20, 
			18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 
			10,  7,  7,  7, 18, 13
		); 
		
		public function TotalScoreText():void
		{
			super(fontClass, 32, 32, CHARS, 8, 0, 0, 0, 0, WIDTHS);
			customSpacingX = 1;
			x = 16;
			y = 16;
			text = "SCORE: 0";
			color = 0xffffff;
		}
		
		public function set score(SCORE:int):void
		{
			text = "SCORE: " + SCORE.toString();
		}
		
		override public function update():void
		{
			super.update();
		}
	}
}
