package
{
	import org.flixel.*;
	import flash.system.fscommand;
	
	public class MenuState extends FlxState
	{
		[Embed(source="../gfx/menu.png")] private var ImgMenu:Class;
		[Embed(source="../gfx/button_play.png")] private var ImgButtonPlay:Class;
		[Embed(source="../gfx/button_credits.png")] private var ImgButtonCredits:Class;
		[Embed(source="../gfx/button_howto.png")] private var ImgButtonHowto:Class;
		
		private var _title:FlxText;
		private var _bg:FlxSprite;
		
		private var _play:FlxButton;
		private var _credits:FlxButton;
		private var _howto:FlxButton;
		
		private var _scores:Array;
		private var timeout:Number;
	
		override public function create():void
		{
			//_title = new FlxText(0, 10, 800, "Everybody loves the Llama in Busytown");
			//_title.size = 24;
			//_title.alignment = "center";
			//add(_title);
			_bg = new FlxSprite(0, 0, ImgMenu);
			add(_bg);
			
			_play = new FlxButton(320, 304, null, onPlay);
			_play.loadGraphic(ImgButtonPlay, false, true, 160, 48);
			add(_play);
			
			_credits = new FlxButton(320, 368, null, onCredits);
			_credits.loadGraphic(ImgButtonCredits, false, true, 160, 48);
			add(_credits);
			
			FlxG.mouse.show();
			
			//FlxG.scores = new Array(1000, 800, 500, 300, 100);
			//HighscoreManager.save();
			HighscoreManager.load();
			
			_scores = new Array();
			var x:int = 400;
			var y:int = 150;
			_scores.push(new FlxText(x, y, 400, "HIGHSCORES"));
			y += 10;
			// TODO the non-copy does not work, does not take the real values!?!
			//for each (var score:int in FlxG.scores)
			var scores:Array = FlxG.scores;
			for each (var score:int in scores)			
			{
				y += 20;
				_scores.push(new FlxText(x, y, 400, "" + score));
			}
			for each (var text:FlxText in _scores)
			{
				text.alignment = "center";
				text.size = 16;
				text.color = 0x000000;
				text.shadow = 0xffffcc;
				add(text);
			}
			_scores[0].color = 0x333333;
			_scores[0].shadow = 0xffffcc;
			
			timeout = 0.5; // do not allow to leave screen while this is > 0
		}
		
		public override function update():void
		{
			super.update();
				
			if (timeout > 0)
			{
				timeout -= FlxG.elapsed;
			}
			else
			{
				if (FlxG.keys.ESCAPE)
				{
					fscommand("quit");
					//FlxG.switchState(null);
				} else
				if (FlxG.keys.any())
				{
					onPlay();
				}
			}
		}
		
		public function onPlay():void
		{
			var ingameState:IngameState = new IngameState();
			FlxG.switchState(ingameState);
		}
		
		public function onCredits():void
		{
			var creditsState:CreditsState = new CreditsState();
			FlxG.switchState(creditsState);
		}
	}
}
