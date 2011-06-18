package
{
	import org.flixel.*;
	
	public class ScoreText extends FlxText
	{
		
		public function ScoreText():void
		{
			super(0,0,100);
			this.size = 16;
			this.alignment = "center";
			this.exists = false;
		}
		
		public function init(X:int, Y:int, MULTIPLIER:int, SCORE:int):void
		{
			this.text = "" + SCORE + "x" + MULTIPLIER;
			this.exists = true;
		}
		
		override public function update():void
		{
			this.y -= FlxG.elapsed * 100;
			this.alpha -= FlxG.elapsed * 2;
			if (this.alpha <= 0)
			{
				this.exists = false;
			}
		}
	}
}
