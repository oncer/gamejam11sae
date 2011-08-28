package
{
	import org.flixel.*;
	
	public class HealthBar extends FlxGroup
	{
		[Embed(source="../gfx/life_bg.png")] private static var ImgLifeBG:Class;
		[Embed(source="../gfx/life_fg.png")] private static var ImgLifeFG:Class;
		
		private var bg:FlxSprite;
		private var fg:FlxSprite;
		private var _value:Number;
		
		public function HealthBar():void
		{
			bg = new FlxSprite(0, 0, ImgLifeBG);
			fg = new FlxSprite(0, 0, ImgLifeFG);
			
			bg.x = FlxG.width - bg.width - 16;
			bg.y = 16;
			fg.x = bg.x + 35;
			fg.y = bg.y + 4;
			add(bg);
			add(fg);
		}
		
		public function set value(v:Number):void
		{
			_value = v;
			fg.setSrcRect(0, 0, fg.width * v, fg.height);
		}
		public function get value():Number
		{
			return _value;
		}
	}
}
