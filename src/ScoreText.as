package
{
	import org.flixel.*;
	
	public class ScoreText extends FlxGroup
	{
		[Embed(source="../gfx/fontdamage.png")] private static var ImgDamageFont:Class;
		
		private var timer:Number;
		
		private var fonts:Array;
		private static const CHARS:String = "x0123456789";
		private var font:FlxBitmapFont = null;
		
		
		public function ScoreText():void
		{
			fonts = new Array();
			fonts[0] = new FlxBitmapFont(ImgDamageFont, 16, 32, CHARS, 11, 0, 0, 0, 0,   [13,12, 9,13,13,12,13,13,13,13,13]);
			fonts[1] = new FlxBitmapFont(ImgDamageFont, 16, 32, CHARS, 11, 0, 0, 0, 32,  [13,12, 9,13,13,12,13,13,13,13,13]);
			fonts[2] = new FlxBitmapFont(ImgDamageFont, 16, 32, CHARS, 11, 0, 0, 0, 64,  [13,12, 9,13,13,12,13,13,13,13,13]);
			fonts[3] = new FlxBitmapFont(ImgDamageFont, 16, 32, CHARS, 11, 0, 0, 0, 96,  [16,14,11,16,16,14,16,16,16,16,16]);
			fonts[4] = new FlxBitmapFont(ImgDamageFont, 16, 32, CHARS, 11, 0, 0, 0, 128, [16,14,12,16,16,15,16,16,16,16,16]);
			for (var i:int = 0; i<5; i++) {
				fonts[i].customSpacingX = 1;
			}
			this.exists = false;
		}
		
		public function init(X:int, Y:int, MULTIPLIER:int, SCORE:int):void
		{
			var fontIdx:int = MULTIPLIER - 1;
			if (fontIdx > 4) fontIdx = 4;
			font = fonts[fontIdx];
			if (MULTIPLIER > 1) {
				font.text = "" + SCORE + "x" + MULTIPLIER;
			} else {
				font.text = "" + SCORE;
			}
			font.x = X - font.width / 2;
			font.y = Y - font.height;
			this.exists = true;
			timer = 0.7;
			
			font.alpha = 0;
			
			clear();
			add(font);
		}
		
		override public function update():void
		{
			timer -= FlxG.elapsed;
			if (timer > 0.5) {
				font.alpha += FlxG.elapsed * 5;
			} else if (timer > 0) {
				font.alpha = 1;
			} else {
				font.y -= FlxG.elapsed * 50;
				font.alpha -= FlxG.elapsed * 1;
			}
			if (font.alpha <= 0)
			{
				this.exists = false;
			}
		}
	}
}
