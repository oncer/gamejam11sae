package
{
	import org.flixel.*;
	
	public class LevelManager extends FlxBasic
	{
		private const SECONDS_PER_LEVEL:Number = 60;
		
		private var elapsedTime:Number; // total in seconds
		private var _isNewLevel:Boolean;
		public var currentLevel:int;
		
		public function LevelManager():void
		{
			super();
			
			elapsedTime = 0;
			_isNewLevel = false;
			currentLevel = 1;
		}
		
		public override function update():void
		{
			super.update();
			elapsedTime += FlxG.elapsed;
			
			if (elapsedTime > currentLevel * SECONDS_PER_LEVEL)
			{
				currentLevel++;
				_isNewLevel = true;
			}
		}
		
		public function isNewLevel():Boolean
		{
			if (_isNewLevel)
			{
				_isNewLevel = false;
				return true;
			}
			else
			{
				return false;
			}
		}
		
		public function levelCompletion():Number
		{
			return (elapsedTime - (currentLevel-1) * SECONDS_PER_LEVEL) / SECONDS_PER_LEVEL;
		}
		
		public function getDifficulty():Number
		{
			var minLevelDifficulty:Number = currentLevel * 3;
			var maxLevelDifficulty:Number = currentLevel * 30;
			var range:Number = maxLevelDifficulty - minLevelDifficulty;
			
			return minLevelDifficulty + range * levelCompletion();
		}
	}
}
