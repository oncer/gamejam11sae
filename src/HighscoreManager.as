package 
{
	import org.flixel.*;
	public class HighscoreManager
	{
		public static function load():void
		{
			var s:FlxSave = new FlxSave();
			s.bind("highscores");
			
			if (s.data.scores == null) {// || s.data.scores.length != 5) {
				trace("no highscore was saved before!");
				//s.data.scores = new Array(1000, 800, 500, 300, 100);				
				s.data.scores = new Array(1000, 100);				
			}
			FlxG.scores = s.data.scores.concat();
			s.close();
		}
		
		public static function save():void
		{
			var s:FlxSave = new FlxSave();
			s.bind("highscores");
			var scores:Array = FlxG.scores;
			s.data.scores = scores.concat();
			s.close();
		}
		
		public static function submitCurrentHighscore() {
			var scores = FlxG.scores;
			FlxG.scores.push(FlxG.score);
			FlxG.scores.sort(Array.NUMERIC);
			FlxG.scores.reverse();			
			save();
		}
	}
}
