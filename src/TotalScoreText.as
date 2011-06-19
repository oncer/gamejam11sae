package
{
	import org.flixel.*;
	
	public class ScoreText extends FlxText
	{
		private var timer:Number;
		
		private const var BASE_SIZE:Number = 20;
		private var currentSize:Number;
		
		public function ScoreText():void
		{
			super(0,0,100);
			this.size = BASE_SIZE;
			this.alignment = "center";
			this.exists = false;
		}
		
		public override function create():void
		{
			super.create();
			
			this.size = BASE_SIZE;
		}
		
		public function init(X:int, Y:int, MULTIPLIER:int, SCORE:int):void
		{
			if (MULTIPLIER > 1) {
				this.text = "" + SCORE + "x" + MULTIPLIER;
			} else {
				this.text = "" + SCORE;
			}
			this.x = X - this.width / 2;
			this.y = Y - this.height;
			this.exists = true;
			timer = 0.7;
			
			switch (MULTIPLIER)
			{
				case 1:
					this.color = 0xffffff; break;
				case 2:
					this.color = 0xffff00; break;
				case 3:
					this.color = 0xffcc00; break;
				case 4:
					this.color = 0xff5500; break;
				default:
					this.color = 0xff0000; break;
			}
			
			this.alpha = 0;
		}
		
		override public function update():void
		{
			timer -= FlxG.elapsed;
			if (timer > 0.5) {
				this.alpha += FlxG.elapsed * 5;
			} else if (timer > 0) {
				this.alpha = 1;
			} else {
				this.y -= FlxG.elapsed * 50;
				this.alpha -= FlxG.elapsed * 1;
			}
			if (this.alpha <= 0)
			{
				this.exists = false;
			}
		}
	}
}
