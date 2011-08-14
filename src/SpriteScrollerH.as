package {
	import org.flixel.*;
	
	public class SpriteScrollerH extends FlxSprite
	{	
		private var sp1:FlxSprite;
		private var sp2:FlxSprite;
		
		public function SpriteScrollerH(X:Number, Y:Number):void
		{
			sp1 = new FlxSprite();
			sp2 = new FlxSprite();
			sp1.x = X; sp1.y = Y;
			sp2.x = X - sp1.width; sp2.y = Y;
			super(X,Y);
		}
		
		public override function loadGraphic (Graphic:Class,Animated:Boolean=false,Reverse:Boolean=false,Width:uint=0,Height:uint=0,Unique:Boolean=false):FlxSprite
		{
			sp1.loadGraphic(Graphic, Animated, Reverse, Width, Height, Unique);
			sp2.loadGraphic(Graphic, Animated, Reverse, Width, Height, Unique);
			return this;
		}
		
		public override function get frame():uint
		{
			return sp1.frame;
		}
		
		public override function set frame(Frame:uint):void
		{
			sp1.frame = sp2.frame = Frame;
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
			if (this.x > sp1.width) {
				this.x -= sp1.width;
			}
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
