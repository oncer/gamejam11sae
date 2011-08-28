	package
{
	import org.flixel.*;
	
	public class Trampolin extends FlxSprite
	{
		[Embed(source="../gfx/trampolin_back.png")] private var ImgTrampolinBack:Class;
		[Embed(source="../gfx/trampolin_front.png")] private var ImgTrampolinFront:Class;
		[Embed(source="../gfx/trampolin_dent.png")] private var ImgTrampolinDent:Class;
		
		public var bgSprite:FlxSprite;
		private var dent:FlxSprite;
		public static const DENT_OFFSET:uint = 19;
		public static const DENT_HEIGHT:uint = 10;
		
		public function Trampolin():void
		{
			super(Globals.CAGE_LEFT, Globals.TRAMPOLIN_TOP);
			loadGraphic(ImgTrampolinFront);
			bgSprite = new FlxSprite(x, y, ImgTrampolinBack);
			dent = new FlxSprite(x, y + DENT_OFFSET, ImgTrampolinDent);
			dent.visible = false;
		}
		
		public function setDent(X:Number, H:Number):void
		{
			H -= DENT_OFFSET;
			if (H <= 0) {
				dent.visible = false;
				return;
			} else {
				var h:Number = Math.min(DENT_HEIGHT, H);
				dent.setSrcRect(0, DENT_HEIGHT - h, dent.width, h);
				dent.x = X;
				dent.visible = true;
			}
		}
		
		override public function preUpdate():void
		{
			super.preUpdate();
			dent.preUpdate();
		}
		
		override public function update():void
		{
			super.update();
			dent.update();
		}
		
		override public function postUpdate():void
		{
			super.postUpdate();
			dent.postUpdate();
		}
		
		override public function draw():void
		{
			if (dent.visible) dent.draw();
			super.draw();
		}
	}
}
