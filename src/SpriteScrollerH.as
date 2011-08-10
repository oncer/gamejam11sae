package {
	import org.flixel.*;
	
	public class SpriteScrollerH extends FlxGroup
	{
		public var offset:Number;
		
		private var sp1:FlxSprite;
		private var sp2:FlxSprite;
		
		public var alpha:Number = 1.0;
		
		public function SpriteScrollerH(SPRITE:Class):void
		{
			offset = 0;
			sp1 = new FlxSprite(0, 0, SPRITE);
			sp2 = new FlxSprite(-sp1.width, 0, SPRITE);
			add(sp1);
			add(sp2);
		}
		
		public function setBlendMode(BLEND:String):void
		{
			sp1.blend = BLEND;
			sp2.blend = BLEND;
		}
		
		public override function update():void
		{
			sp1.x = offset;
			sp2.x = offset - sp1.width;
			super.update();
		}
		
		public override function draw():void
		{
			sp1.alpha = sp2.alpha = this.alpha;
			super.draw();
		}
	}
}
