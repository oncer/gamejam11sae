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
		
		private var _scores:Array;
	
		override public function create():void
		{
			//_title = new FlxText(0, 10, 800, "Everybody loves the Llama in Busytown");
			//_title.size = 24;
			//_title.alignment = "center";
			//add(_title);
			_bg = new FlxSprite(0, 0, ImgMenu);
			add(_bg);
			
			_play = new FlxButton(200 - 75, 200, null, onPlay);
			_play.loadGraphic(ImgButtonPlay, false, true, 150, 50);
			_howto = new FlxButton(200 - 75, 260, null, onHowto);
			_howto.loadGraphic(ImgButtonHowto, false, true, 150, 50);
			add(_play);
			add(_howto);
			
			FlxG.mouse.show();
			
			//FlxG.scores = new Array(1000, 800, 500, 300, 100);
			//HighscoreManager.save();
			HighscoreManager.load();
			
			_scores = new Array();
			var x:int = 400;
			var y:int = 150;
			_scores.push(new FlxText(x, y, 400, "HIGHSCORES"));
			y += 10;
			for each (var score:int in FlxG.scores)
			{
				y += 20;
				_scores.push(new FlxText(x, y, 400, "" + score));
			}
			for each (var text:FlxText in _scores)
			{
				text.alignment = "center";
				text.size = 16;
				text.color = 0x000000;
				add(text);
			}
			_scores[0].color = 0x333333;
		}
				
		public function onPlay():void
		{
			FlxG.switchState(new IngameState());
		}
		
		public function onHowto():void
		{
		}
	}
}
