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
		
		private function amountSpawns():uint
		{
			var difficulty:Number = getDifficulty();
			var spawnInterval:Number = 400.0 / (difficulty + 40.0);
			if (spawnInterval < 0.1) {
				spawnInterval = 0.1;
			}
			
			var amountPerInterval:uint = Math.max(2, Math.min(10, Math.round(difficulty/10 + 5)));
			var amount:uint = 0;
			
			while (lastSpawnTime < elapsedTime) 
			{
				lastSpawnTime += spawnInterval;
				amount += amountPerInterval;
			}
			
			return amount;
		}
		
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
		
		public function isLevelElapsed():Boolean
		{
			return _isNewLevel;
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
			var minLevelDifficulty:Number = currentLevel * 1;
			var maxLevelDifficulty:Number = currentLevel * 10;
			var range:Number = maxLevelDifficulty - minLevelDifficulty;
			
			return minLevelDifficulty + range * levelCompletion();
		}
		
		/*
		 * Returns a vector of the nr.s of visitors which are new in
		 * the currently starting level.
		 * Currently, only one visitor type is introduced per level.
		 */
		public function getLevelIntroductions():Vector.<int>
		{
			switch(currentLevel)
			{
				case 1:
					return Vector.<int>([1, 2]); // man
					
				case 2:
					return Vector.<int>([2]); // woman
					
				case 4:
					return Vector.<int>([4]); // granny
					
				case 6:
					return Vector.<int>([0]); // child
					
				case 8:
					return Vector.<int>([3]); // tourist
					
				case 10:
					return Vector.<int>([9]); // zombie lady
				
				default:
					return Vector.<int>([]); // nothing new
			}
		}
		
		public function doSpawns(getUnusedVisitor:Function):void
		{
			var amount:uint = amountSpawns();
			for (var i:uint = 0; i < amount; i++)
			{
				var v:Visitor = getUnusedVisitor();
				if (v.exists) return; // not actually unused?! keep on screen until dead
				
				// distribute left/right at random. visitors evenly
				var visitorType:int = Math.floor(Math.random() * 5);
				if (Math.random()*5 < 1) visitorType += 5; // rare variations like zombies
				v.init(visitorType, i, 0, Math.random() < 0.5);
			}
		}
	}
}
