package 
{
	import org.flixel.*;
	public class HighscoreManager
	{
		public static function load():void
		{
			var s:FlxSave = new FlxSave();
			s.bind("highscores");
			
			if (s.data.scores == null || s.data.scores.length != 5) {
				s.data.scores = new Array(1000, 800, 500, 300, 100);
			}
			FlxG.scores = s.data.scores.concat();
			s.close();
		}
		
		public static function save():void
		{
			var s:FlxSave = new FlxSave();
			s.bind("highscores");
			s.data.scores = FlxG.scores.concat();
			s.close();
		}
	}
}
