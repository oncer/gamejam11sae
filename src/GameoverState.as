package
{
	import org.flixel.*;
	
	public class GameoverState extends FlxState
	{
		[Embed(source="../gfx/gameover.png")] private var BackgroundImage:Class;
		
		private var _bg:FlxSprite;
	
		override public function create():void
		{
			trace("GameoverState.create()");
			
			trace("reached score: " + FlxG.score);
			HighscoreManager.submitCurrentHighscore();
			
			
			add(new FlxSprite(0, 0, BackgroundImage));
			
			FlxG.mouse.show();
			
			HighscoreManager.load();
				
			var _scores:Array = new Array();
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
				trace("to add highscore: " + score);
				_scores.push(new FlxText(x, y, 400, "" + score));
			}
			for each (var text:FlxText in _scores)
			{
				text.alignment = "center";
				text.size = 16;
				text.color = 0x000000;
				text.shadow = 0xccccff;
				add(text);
			}
			_scores[0].color = 0x333333;
			_scores[0].shadow = 0xccccff;
		}

		override public function update():void
		{
			super.update();
				
			if (FlxG.keys.any())
			{
				anyKeyPressed();
			}
		}

		public function anyKeyPressed():void
		{
			FlxG.switchState(new MenuState());
		}
	}
}
