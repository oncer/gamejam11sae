package
{
	import org.flixel.*;
	
	public class LevelManager extends FlxBasic
	{
		private const SECONDS_PER_LEVEL:Number = 40;
		
		private var elapsedTime:Number; // total *time of all levels*, not game time, in seconds
		private var _isNewLevel:Boolean;
		public var currentLevel:int;
		private var lastSpawnTime:Number;
		
		public function LevelManager():void
		{
			super();
			
			elapsedTime = 0;
			_isNewLevel = false;
			currentLevel = 1;
			lastSpawnTime = 0;
		}
		
		public override function update():void
		{
			super.update();
			
			if (!_isNewLevel)
			{
				elapsedTime += FlxG.elapsed;
			
				if (elapsedTime > currentLevel * SECONDS_PER_LEVEL)
				{
					elapsedTime = currentLevel * SECONDS_PER_LEVEL;
					lastSpawnTime = elapsedTime;
					_isNewLevel = true;
				}
			}
		}
		
		public function isLevelElapsed ():Boolean
		{
			return _isNewLevel;
		}
		
		public function amountSpawns():uint
		{
			var difficulty:Number = getDifficulty();
			var spawnInterval:Number = 400.0 / (difficulty + 40.0);
			if (spawnInterval < 0.1) {
				spawnInterval = 0.1;
			}
			
			var amountPerInterval:uint = Math.max(5, Math.min(10, Math.round(difficulty/10 + 5)));
			var amount:uint = 0;
			
			while (lastSpawnTime < elapsedTime) 
			{
				lastSpawnTime += spawnInterval;
				amount += amountPerInterval;
			}
			
			return amount;
		}
		
		public function gotoNextLevel():void
		{
			_isNewLevel = false;
			currentLevel++;
		}
		
		// between 0 and 1, how much time has passed in the level
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
