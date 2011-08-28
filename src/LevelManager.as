package
{
	import org.flixel.*;
	
	public class LevelManager extends FlxBasic
	{
		private const SECONDS_BETWEEN_SPAWNS:Number = 5.382;
		private const SPAWN_BATCHES_PER_LEVEL:Number = 8;
		private const SECONDS_PER_LEVEL:Number = SPAWN_BATCHES_PER_LEVEL * SECONDS_BETWEEN_SPAWNS; // minimum time
		
		private var elapsedTime:Number; // total *time of all levels*, not game time, in seconds
		private var levelTime:Number;   // elapsed time in this level in seconds
		private var _isNewLevel:Boolean;
		private var currentLevel:int;
		private var lastSpawnTime:Number;
		private var spawnPool:Vector.<VisitorSpawnDesc>; // Vector of visitor types to spawn in this level
		private var spawnedVisitors:FlxGroup; // tracking for checking if all dead
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
			
			spawnPool = new Vector.<VisitorSpawnDesc>([]);
			spawnedVisitors = new FlxGroup();
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
		
		private function areAllSpawnsOut():Boolean
		{
			return spawnBatch >= SPAWN_BATCHES_PER_LEVEL;
		}
		
		private function areAllSpawnsDead():Boolean
		{
			return spawnedVisitors.countLiving() == 0;
		}
		
		public function isLevelElapsed():Boolean
		{
			return (areAllSpawnsOut() && areAllSpawnsDead()) || _isNewLevel;
		}
		
		private function beginLevel():void
		{
			levelTime = 0;
			spawnBatch = 0;
			lastSpawnTime = -SECONDS_BETWEEN_SPAWNS; // force initial spawn at level begin
			
			fillSpawnPool();
			spawnedVisitors.clear();
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
					
				case 3:
					return Vector.<int>([6]); // circus director
				
				case 4:
					return Vector.<int>([4]); // granny
					
				case 6:
					return Vector.<int>([0]); // child
					
				case 7:
					return Vector.<int>([7]); // tiger man
					
				case 8:
					return Vector.<int>([3]); // tourist
					
				case 10:
					return Vector.<int>([5]); // zombie lady
				
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
			var vbegin:int = spawnBatch * l / SPAWN_BATCHES_PER_LEVEL;
			var vend:int = (spawnBatch+1) * l / SPAWN_BATCHES_PER_LEVEL;
			
			for (var i:int = vbegin; i < Math.min(l, vend); i++)
			{
				var v:Visitor = getUnusedVisitor();
				if (v.exists) return; // not actually unused?! keep on screen until dead
				
				// distribute left/right at random. visitors evenly
				v.init(spawnPool[i].type,    // type
				       i-vbegin,             // spacing
				       spawnPool[i].facing,  // facing
				       Math.random() < spawnPool[i].floatingProbability); // isFloating
				spawnedVisitors.add(v);
			}
			
			spawnBatch++;
		}
		
		public function doSpawns(getUnusedVisitor:Function):void
		{
			if ((levelTime - lastSpawnTime) >= SECONDS_BETWEEN_SPAWNS)
			{
				doOneSpawn(getUnusedVisitor);
				lastSpawnTime += SECONDS_BETWEEN_SPAWNS;
			} else
			if (areAllSpawnsDead())
			{
				doOneSpawn(getUnusedVisitor);
				lastSpawnTime = levelTime;
			}
		}
		
		private function fillSpawnPool():void
		{
			spawnPool.length = 0;
			var level:int = getLevelNr();
			var i:int = 0;

			// usual visitor amount = 4 + level * 4

			switch (level)
			{

			case 0: // DEBUG: this should not happen.
				for (i = 0; i < 24; i++) spawnPool.push(new VisitorSpawnDesc(9)); // zombie: level 0 not allowed.

			case 1: // first visitors introduced, 8 total
				for (i = 0; i < 6; i++) spawnPool.push(new VisitorSpawnDesc(1,0,0)); // man
				for (i = 0; i < 2; i++) spawnPool.push(new VisitorSpawnDesc(6,0,0)); // man alt.
				assert(spawnPool.length == 8);
				break;

			case 2: // women introduced, 12 total
				for (i = 0; i < 3; i++) spawnPool.push(new VisitorSpawnDesc(1,0,0)); // man
				for (i = 0; i < 1; i++) spawnPool.push(new VisitorSpawnDesc(6,0,0)); // man alt.
				for (i = 0; i < 6; i++) spawnPool.push(new VisitorSpawnDesc(2,0,0)); // woman
				for (i = 0; i < 2; i++) spawnPool.push(new VisitorSpawnDesc(7,0,0)); // woman alt.
				assert(spawnPool.length == 12);
				break;

			case 3: // circus director, 16 total
				for (i = 0; i < 2; i++) spawnPool.push(new VisitorSpawnDesc(1,0,0)); // man
				for (i = 0; i < 2; i++) spawnPool.push(new VisitorSpawnDesc(6,0,0)); // man alt.
				for (i = 0; i < 2; i++) spawnPool.push(new VisitorSpawnDesc(2,0,0)); // woman
				for (i = 0; i < 2; i++) spawnPool.push(new VisitorSpawnDesc(7,0,0)); // woman alt.
				for (i = 0; i < 8; i++) spawnPool.push(new VisitorSpawnDesc(11,0,0)); // circus director
				assert(spawnPool.length == 16);
				break;

			case 4: // granny introduced. no alts, 20 total
				for (i = 0; i < 3; i++) spawnPool.push(new VisitorSpawnDesc(1,0,0)); // man
				for (i = 0; i < 2; i++) spawnPool.push(new VisitorSpawnDesc(6,0,0)); // man alt.
				for (i = 0; i < 3; i++) spawnPool.push(new VisitorSpawnDesc(2,0,0)); // woman
				for (i = 0; i < 2; i++) spawnPool.push(new VisitorSpawnDesc(7,0,0)); // woman alt.
				for (i = 0; i < 2; i++) spawnPool.push(new VisitorSpawnDesc(11,0,0)); // circus director
				for (i = 0; i < 8; i++) spawnPool.push(new VisitorSpawnDesc(4,0,0)); // granny
				assert(spawnPool.length == 20);
				break;

			case 5: // nothing new, 24 total
				for (i = 0; i < 5; i++) spawnPool.push(new VisitorSpawnDesc(1)); // man
				for (i = 0; i < 3; i++) spawnPool.push(new VisitorSpawnDesc(6)); // man alt.
				for (i = 0; i < 5; i++) spawnPool.push(new VisitorSpawnDesc(2)); // woman
				for (i = 0; i < 3; i++) spawnPool.push(new VisitorSpawnDesc(7)); // woman alt.
				for (i = 0; i < 3; i++) spawnPool.push(new VisitorSpawnDesc(11,0,0)); // circus director
				for (i = 0; i < 5; i++) spawnPool.push(new VisitorSpawnDesc(4)); // granny
				assert(spawnPool.length == 24);
				break;

			case 6: // children introduced. have a lot of them! 28 total
				for (i = 0; i < 2;  i++) spawnPool.push(new VisitorSpawnDesc(1)); // man
				for (i = 0; i < 1;  i++) spawnPool.push(new VisitorSpawnDesc(6)); // man alt.
				for (i = 0; i < 2;  i++) spawnPool.push(new VisitorSpawnDesc(2)); // woman
				for (i = 0; i < 1;  i++) spawnPool.push(new VisitorSpawnDesc(7)); // woman alt.
				for (i = 0; i < 2;  i++) spawnPool.push(new VisitorSpawnDesc(11)); // circus director
				for (i = 0; i < 2;  i++) spawnPool.push(new VisitorSpawnDesc(4)); // granny
				for (i = 0; i < 13; i++) spawnPool.push(new VisitorSpawnDesc(0)); // child
				for (i = 0; i < 5;  i++) spawnPool.push(new VisitorSpawnDesc(5)); // child alt.
				assert(spawnPool.length == 28);
				break;
				
			case 7: // tiger man, 32 total
				for (i = 0; i < 3; i++) spawnPool.push(new VisitorSpawnDesc(1)); // man
				for (i = 0; i < 1; i++) spawnPool.push(new VisitorSpawnDesc(6)); // man alt.
				for (i = 0; i < 3; i++) spawnPool.push(new VisitorSpawnDesc(2)); // woman
				for (i = 0; i < 1; i++) spawnPool.push(new VisitorSpawnDesc(7)); // woman alt.
				for (i = 0; i < 3;  i++) spawnPool.push(new VisitorSpawnDesc(11)); // circus director
				for (i = 0; i < 3; i++) spawnPool.push(new VisitorSpawnDesc(4)); // granny
				for (i = 0; i < 3; i++) spawnPool.push(new VisitorSpawnDesc(0)); // child
				for (i = 0; i < 1; i++) spawnPool.push(new VisitorSpawnDesc(5)); // child alt.
				for (i = 0; i < 14;  i++) spawnPool.push(new VisitorSpawnDesc(10)); // tiger man
				assert(spawnPool.length == 32);
				break;
				
			case 8: // tourists introduced, more than usual, 36 total
				for (i = 0; i < 2;  i++) spawnPool.push(new VisitorSpawnDesc(1)); // man
				for (i = 0; i < 1;  i++) spawnPool.push(new VisitorSpawnDesc(6)); // man alt.
				for (i = 0; i < 2;  i++) spawnPool.push(new VisitorSpawnDesc(2)); // woman
				for (i = 0; i < 1;  i++) spawnPool.push(new VisitorSpawnDesc(7)); // woman alt.
				for (i = 0; i < 2;  i++) spawnPool.push(new VisitorSpawnDesc(11)); // circus director
				for (i = 0; i < 2;  i++) spawnPool.push(new VisitorSpawnDesc(4)); // granny
				for (i = 0; i < 2;  i++) spawnPool.push(new VisitorSpawnDesc(0)); // child
				for (i = 0; i < 1;  i++) spawnPool.push(new VisitorSpawnDesc(5)); // child alt.
				for (i = 0; i < 3;  i++) spawnPool.push(new VisitorSpawnDesc(10)); // tiger man
				for (i = 0; i < 16; i++) spawnPool.push(new VisitorSpawnDesc(3)); // tourist
				for (i = 0; i < 4;  i++) spawnPool.push(new VisitorSpawnDesc(8)); // tourist alt.
				assert(spawnPool.length == 36);
				break;
				
			case 9: // nothing new, all equal, 40 total
				for (i = 0; i < 5; i++) spawnPool.push(new VisitorSpawnDesc(1)); // man
				for (i = 0; i < 1; i++) spawnPool.push(new VisitorSpawnDesc(6)); // man alt.
				for (i = 0; i < 6; i++) spawnPool.push(new VisitorSpawnDesc(2)); // woman
				for (i = 0; i < 1; i++) spawnPool.push(new VisitorSpawnDesc(7)); // woman alt.
				for (i = 0; i < 5;  i++) spawnPool.push(new VisitorSpawnDesc(11)); // circus director
				for (i = 0; i < 7; i++) spawnPool.push(new VisitorSpawnDesc(4)); // granny
				for (i = 0; i < 5; i++) spawnPool.push(new VisitorSpawnDesc(0)); // child
				for (i = 0; i < 1; i++) spawnPool.push(new VisitorSpawnDesc(5)); // child alt.
				for (i = 0; i < 3;  i++) spawnPool.push(new VisitorSpawnDesc(10)); // tiger man
				for (i = 0; i < 5; i++) spawnPool.push(new VisitorSpawnDesc(3)); // tourist
				for (i = 0; i < 1; i++) spawnPool.push(new VisitorSpawnDesc(8)); // tourist alt.
				assert(spawnPool.length == 40);
				break;
				
			case 10: // zombie rush, 44 total
				for (i = 0; i < 2;  i++) spawnPool.push(new VisitorSpawnDesc(1)); // man
				for (i = 0; i < 1;  i++) spawnPool.push(new VisitorSpawnDesc(6)); // man alt.
				for (i = 0; i < 2;  i++) spawnPool.push(new VisitorSpawnDesc(2)); // woman
				for (i = 0; i < 1;  i++) spawnPool.push(new VisitorSpawnDesc(7)); // woman alt.
				for (i = 0; i < 3;  i++) spawnPool.push(new VisitorSpawnDesc(11)); // circus director
				for (i = 0; i < 2;  i++) spawnPool.push(new VisitorSpawnDesc(4)); // granny
				for (i = 0; i < 2;  i++) spawnPool.push(new VisitorSpawnDesc(0)); // child
				for (i = 0; i < 1;  i++) spawnPool.push(new VisitorSpawnDesc(5)); // child alt.
				for (i = 0; i < 3;  i++) spawnPool.push(new VisitorSpawnDesc(10)); // tiger man
				for (i = 0; i < 2;  i++) spawnPool.push(new VisitorSpawnDesc(3)); // tourist
				for (i = 0; i < 1;  i++) spawnPool.push(new VisitorSpawnDesc(8)); // tourist alt.
				for (i = 0; i < 24; i++) spawnPool.push(new VisitorSpawnDesc(9)); // zombies
				assert(spawnPool.length == 44);
				break;
				
			default:
				var amount:int = getLevelNr() * 4 + 4;
				for (i = 0; i < amount; i++)
				{
					// equal distribution among the normal variants
					var type:int = Math.floor(Math.random() * Globals.N_VISITOR_TYPES);
					if ((type >= 5) && (type <= 9)) // type is rare
					{
						if (Math.random() < .4) type -= 5; // revert to common variation
					}
					spawnPool[i] = new VisitorSpawnDesc(type,0,.4);
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
					var tmp:VisitorSpawnDesc = spawnPool[i];
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

/*
 * Describes some properties of a to-be-spawned visitor.
 */
class VisitorSpawnDesc
{
	public var type:int;   // see Visitor.as for list of types
	public var facing:int; // 0 = random, LEFT or RIGHT
	public var floatingProbability:Number; // 0 = always ground, 1 = always float
	
	public function VisitorSpawnDesc (type:int, facing:int = 0, floatingProbability:Number = 0.4):void
	{
		this.type = type;
		this.facing = facing;
		this.floatingProbability = floatingProbability;
	}
}
