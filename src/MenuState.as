package
{
	import org.flixel.*;
	
	public class MenuState extends FlxState
	{
		[Embed(source="../gfx/menu.png")] private var ImgMenu:Class;
		
		private var _title:FlxText;
		private var _bg:FlxSprite;
		
		private var _play:FlxButton;
		private var _howto:FlxButton;
	
		override public function create():void
		{
			//_title = new FlxText(0, 10, 800, "Everybody loves the Llama in Busytown");
			//_title.size = 24;
			//_title.alignment = "center";
			//add(_title);
			_bg = new FlxSprite(0, 0, ImgMenu);
			add(_bg);
			
			_play = new FlxButton(400, 100, "PLAY");
			_howto = new FlxButton(400, 200, "HOW TO PLAY");
			add(_play);
			add(_howto);
		}
	}
}
