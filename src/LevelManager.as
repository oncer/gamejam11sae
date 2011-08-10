package
{
	import org.flixel.*;
	
	public class LevelManager extends FlxBasic
	{
		private const SECONDS_PER_LEVEL:Number = 40; // minimum time
		
		private var elapsedTime:Number; // total *time of all levels*, not game time, in seconds
		private var levelTime:Number;   // elapsed time in this level in seconds
		private var _isNewLevel:Boolean;
		private var currentLevel:int;
		private var lastSpawnTime:Number;
		private var spawnPool:Vector.<int>; // Vector of visitor types to spawn in this level
		private var spawnBatch:int;
		
		private function amountSpawns():uint
		{
			var difficulty:Number = getDifficulty();
			var spawnInterval:Number = 400.0 / (difficulty + 40.0);
			if (spawnInterval < 0.1)
			{
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
			
			spawnPool = new Vector.<int>([]);
			beginLevel();
		}
		
		public override function update():void
		{
			super.update();
			
			if (!_isNewLevel)
			{
				elapsedTime += FlxG.elapsed;
				levelTime += FlxG.elapsed;
			
				if (levelTime > SECONDS_PER_LEVEL)
				{
					// NOTE: the following two lines might need to go if the
					//       time-centric level system changes.
					elapsedTime = currentLevel * SECONDS_PER_LEVEL;
					levelTime = SECONDS_PER_LEVEL;
					
					lastSpawnTime = elapsedTime; // prevent more spawn
					_isNewLevel = true;
				}
			}
		}
		
		public function isLevelElapsed():Boolean
		{
			return _isNewLevel;
		}
		
		private function beginLevel():void
		{
			levelTime = 0;
			spawnBatch = 0;
			lastSpawnTime = -999; // force initial spawn at level begin
			
			fillSpawnPool();
		}
		
		public function gotoNextLevel():void
		{
			_isNewLevel = false;
			currentLevel++;
			beginLevel();
		}
		
		// between 0 and 1, how much time has passed in the level
		public function levelCompletion():Number
		{
			var completion:Number = levelTime / SECONDS_PER_LEVEL;
			if (completion > 1.0) completion = 1.0;
			return completion;
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
					return Vector.<int>([1]); // man
					
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
		
		/*
		 * One spawn creates several visitors
		 */
		private function doOneSpawn(getUnusedVisitor:Function):void
		{
			var l:int = spawnPool.length;
			var vbegin:int = spawnBatch * l / 8;
			var vend:int = (spawnBatch+1) * l / 8;
			
			trace("doOneSpawn with " + (vend - vbegin).toString() + " visitors.");
			
			for (var i:int = vbegin; i < Math.min(l, vend); i++)
			{
				var v:Visitor = getUnusedVisitor();
				if (v.exists) return; // not actually unused?! keep on screen until dead
				
				// distribute left/right at random. visitors evenly
				v.init(spawnPool[i], i-vbegin, 0, Math.random() < 0.5);
			}
			
			spawnBatch++;
		}
		
		public function doSpawns(getUnusedVisitor:Function):void
		{
			if ((elapsedTime - lastSpawnTime) >= 5)
			{
				doOneSpawn(getUnusedVisitor);
				lastSpawnTime = elapsedTime;
			}
			/*
			var amount:uint = amountSpawns();
			for (var i:uint = 0; i < amount; i++)
			{
				var v:Visitor = getUnusedVisitor();
				if (v.exists) return; // not actually unused?! keep on screen until dead
				
				// distribute left/right at random. visitors evenly
				var visitorType:int = Math.floor(Math.random() * 5);
				if (Math.random()*5 < 1) visitorType += 5; // rare variations like zombies
				v.init(visitorType, i, 0, Math.random() < 0.5);
			} */
		}
		
		private function fillSpawnPool():void
		{
			spawnPool.length = 0;
			var level:int = getLevelNr();
			var i:int = 0;
			
			switch (level)
			{

			case 0: // DEBUG: this should not happen.
				for (i = 0; i < 24; i++)  spawnPool[i] = 9; // zombie: level 0 not allowed.

			case 1: // first visitors introduced
				for (i = 0; i < 24; i++)  spawnPool[i] = 1; // man
				for (i = 24; i < 32; i++) spawnPool[i] = 6; // man alt.
				break;
				
			case 2: // women introduced
				for (i = 0; i < 20; i++)  spawnPool[i] = 1; // man
				for (i = 20; i < 30; i++) spawnPool[i] = 6; // man alt.
				for (i = 30; i < 46; i++) spawnPool[i] = 2; // woman
				for (i = 46; i < 48; i++) spawnPool[i] = 7; // woman alt.
				break;
				
			case 3: // nothing new
				for (i = 0; i < 24; i++)  spawnPool[i] = 1; // man
				for (i = 24; i < 32; i++) spawnPool[i] = 6; // man alt.
				for (i = 32; i < 56; i++) spawnPool[i] = 2; // woman
				for (i = 56; i < 64; i++) spawnPool[i] = 7; // woman alt.
				break;
				
			case 4: // granny introduced. no alts
				for (i = 0; i < 24; i++)  spawnPool[i] = 1; // man
				for (i = 24; i < 32; i++) spawnPool[i] = 6; // man alt.
				for (i = 32; i < 56; i++) spawnPool[i] = 2; // woman
				for (i = 56; i < 64; i++) spawnPool[i] = 7; // woman alt.
				for (i = 64; i < 80; i++) spawnPool[i] = 4; // granny
				break;
				
			case 5: // nothing new
				for (i = 0; i < 27; i++)  spawnPool[i] = 1; // man
				for (i = 27; i < 38; i++) spawnPool[i] = 6; // man alt.
				for (i = 38; i < 65; i++) spawnPool[i] = 2; // woman
				for (i = 65; i < 76; i++) spawnPool[i] = 7; // woman alt.
				for (i = 76; i < 96; i++) spawnPool[i] = 4; // granny
				break;
				
			case 6: // children introduced. have a lot of them!
				for (i = 0; i < 16; i++)  spawnPool[i] = 1; // 16 man
				for (i = 16; i < 20; i++) spawnPool[i] = 6; // 4 man alt.
				for (i = 20; i < 36; i++) spawnPool[i] = 2; // 16 woman
				for (i = 36; i < 40; i++) spawnPool[i] = 7; // 4 woman alt.
				for (i = 40; i < 60; i++) spawnPool[i] = 4; // 20 granny
				for (i = 60; i < 100; i++) spawnPool[i] = 0; // 40 child
				for (i = 100; i < 112; i++) spawnPool[i] = 5; // 12 child alt.
				break;
				
			case 7: // nothing new, equal quantities all types
				for (i = 0; i < 27; i++)  spawnPool[i] = 1; // 27 man
				for (i = 27; i < 32; i++) spawnPool[i] = 6; // 5 man alt.
				for (i = 32; i < 59; i++) spawnPool[i] = 2; // 27 woman
				for (i = 59; i < 64; i++) spawnPool[i] = 7; // 5 woman alt.
				for (i = 64; i < 96; i++) spawnPool[i] = 4; // 32 granny
				for (i = 96; i < 123; i++) spawnPool[i] = 0; // 27 child
				for (i = 123; i < 128; i++) spawnPool[i] = 5; // 5 child alt.
				break;
				
			case 8: // tourists introduced, more than usual
				for (i = 0; i < 17; i++)  spawnPool[i] = 1; // 17 man
				for (i = 17; i < 21; i++) spawnPool[i] = 6; // 4 man alt.
				for (i = 21; i < 38; i++) spawnPool[i] = 2; // 17 woman
				for (i = 38; i < 42; i++) spawnPool[i] = 7; // 4 woman alt.
				for (i = 42; i < 63; i++) spawnPool[i] = 4; // 21 granny
				for (i = 63; i < 84; i++) spawnPool[i] = 0; // 21 child
				for (i = 84; i < 94; i++) spawnPool[i] = 5; // 10 child alt.
				for (i = 94; i < 134; i++) spawnPool[i] = 3; // 40 tourist
				for (i = 134; i < 144; i++) spawnPool[i] = 8; // 10 tourist alt.
				break;
				
			case 9: // nothing new, all equal
				for (i = 0; i < 25; i++)  spawnPool[i] = 1; // 25 man
				for (i = 25; i < 32; i++) spawnPool[i] = 6; // 7 man alt.
				for (i = 32; i < 57; i++) spawnPool[i] = 2; // 25 woman
				for (i = 57; i < 64; i++) spawnPool[i] = 7; // 7 woman alt.
				for (i = 42; i < 96; i++) spawnPool[i] = 4; // 32 granny
				for (i = 63; i < 121; i++) spawnPool[i] = 0; // 25 child
				for (i = 84; i < 128; i++) spawnPool[i] = 5; // 7 child alt.
				for (i = 94; i < 153; i++) spawnPool[i] = 3; // 25 tourist
				for (i = 134; i < 160; i++) spawnPool[i] = 8; // 7 tourist alt.
				break;
				
			case 10: // zombie rush
				for (i = 0; i < 20; i++)  spawnPool[i] = 1; // 20 man
				for (i = 20; i < 25; i++) spawnPool[i] = 6; // 5 man alt.
				for (i = 25; i < 45; i++) spawnPool[i] = 2; // 20 woman
				for (i = 45; i < 50; i++) spawnPool[i] = 7; // 5 woman alt.
				for (i = 50; i < 86; i++) spawnPool[i] = 4; // 36 granny
				for (i = 86; i < 106; i++) spawnPool[i] = 0; // 20 child
				for (i = 106; i < 111; i++) spawnPool[i] = 5; // 5 child alt.
				for (i = 111; i < 131; i++) spawnPool[i] = 3; // 20 tourist
				for (i = 131; i < 136; i++) spawnPool[i] = 8; // 5 tourist alt.
				for (i = 136; i < 176; i++) spawnPool[i] = 9; // 40 zombies
				break;
				
			default:
				var amount:int = getLevelNr() * 16 + 16;
				for (i = 0; i < amount; i++)
				{
					// equal distribution among the normal variants
					spawnPool[i] = Math.floor(Math.random() * 5);
					if (Math.random() < .2) spawnPool[i] += 5;
				}
				break;
			
			}
			
			shuffleSpawnPool();
		}
		
		private function shuffleSpawnPool():void
		{
			var l:int = spawnPool.length;
			for (var i:int = 0; i < l-1; i++)
			{
				var j:int = Math.floor(Math.random() * (l-i)) + i;
				if (i != j)
				{
					var tmp:int = spawnPool[i];
					spawnPool[i] = spawnPool[j];
					spawnPool[j] = tmp;
				}
			}
		}
		
		public function getLevelNr():int
		{
			return currentLevel;
		}
	}
}
