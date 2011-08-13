package {
	import org.flixel.*;
	
	public class SpriteScrollerH extends FlxSprite
	{	
		private var sp1:FlxSprite;
		private var sp2:FlxSprite;
		
		public function SpriteScrollerH(X:Number, Y:Number, SPRITE:Class):void
		{
			super(X,Y);
			sp1 = new FlxSprite(X, Y, SPRITE);
			sp2 = new FlxSprite(X - sp1.width, Y, SPRITE);
		}
		
		public function setBlendMode(BLEND:String):void
		{
			sp1.blend = BLEND;
			sp2.blend = BLEND;
		}
		
		public override function update():void
		{
			sp1.blend = sp2.blend = this.blend;
			sp1.alpha = sp2.alpha = this.alpha;
			sp1.x = this.x;
			sp2.x = this.x - sp1.width;
			sp1.update();
			sp2.update();
			super.update();
		}
		
		public override function draw():void
		{
			sp1.draw();
			sp2.draw();
		}
	}
}
