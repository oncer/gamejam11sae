package
{
	import org.flixel.*;
	
	public class MenuState extends FlxState
	{
		[Embed(source="../gfx/menu.png")] private var ImgMenu:Class;
		[Embed(source="../gfx/button_play.png")] private var ImgButtonPlay:Class;
		[Embed(source="../gfx/button_howto.png")] private var ImgButtonHowto:Class;
		
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
			
			_play = new FlxButton(400 - 75, 200);
			_play.loadGraphic(ImgButtonPlay, false, true, 150, 50);
			_howto = new FlxButton(400 - 75, 260);
			_howto.loadGraphic(ImgButtonHowto, false, true, 150, 50);
			add(_play);
			add(_howto);
			
			FlxG.mouse.show();
		}
	}
}
