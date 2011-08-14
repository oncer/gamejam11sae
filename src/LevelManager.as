package
{
	import org.flixel.*;
	
	public class LevelManager extends FlxBasic
	{
		private const SECONDS_PER_LEVEL:Number = 40; // minimum time
		private const SECONDS_BETWEEN_SPAWNS:Number = 5;
		
		private var elapsedTime:Number; // total *time of all levels*, not game time, in seconds
		private var levelTime:Number;   // elapsed time in this level in seconds
		private var _isNewLevel:Boolean;
		private var currentLevel:int;
		private var lastSpawnTime:Number;
		private var spawnPool:Vector.<VisitorSpawnDesc>; // Vector of visitor types to spawn in this level
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
			lastSpawnTime = -SECONDS_BETWEEN_SPAWNS; // force initial spawn at level begin
			
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
				v.init(spawnPool[i].type,    // type
				       i-vbegin,             // spacing
				       spawnPool[i].facing,  // facing
				       Math.random() < spawnPool[i].floatingProbability); // isFloating
			}
			
			spawnBatch++;
		}
		
		public function doSpawns(getUnusedVisitor:Function):void
		{
			if ((levelTime - lastSpawnTime) >= SECONDS_BETWEEN_SPAWNS)
			{
				doOneSpawn(getUnusedVisitor);
				lastSpawnTime += SECONDS_BETWEEN_SPAWNS;
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
				break;
				
			case 2: // women introduced, 12 total
				for (i = 0; i < 3; i++) spawnPool.push(new VisitorSpawnDesc(1,0,0)); // man
				for (i = 0; i < 1; i++) spawnPool.push(new VisitorSpawnDesc(6,0,0)); // man alt.
				for (i = 0; i < 6; i++) spawnPool.push(new VisitorSpawnDesc(2,0,0)); // woman
				for (i = 0; i < 2; i++) spawnPool.push(new VisitorSpawnDesc(7,0,0)); // woman alt.
				break;
				
			case 3: // nothing new, 16 total
				for (i = 0; i < 6; i++) spawnPool.push(new VisitorSpawnDesc(1,0,0)); // man
				for (i = 0; i < 2; i++) spawnPool.push(new VisitorSpawnDesc(6,0,0)); // man alt.
				for (i = 0; i < 6; i++) spawnPool.push(new VisitorSpawnDesc(2,0,0)); // woman
				for (i = 0; i < 2; i++) spawnPool.push(new VisitorSpawnDesc(7,0,0)); // woman alt.
				break;
				
			case 4: // granny introduced. no alts, 20 total
				for (i = 0; i < 4; i++) spawnPool.push(new VisitorSpawnDesc(1,0,0)); // man
				for (i = 0; i < 2; i++) spawnPool.push(new VisitorSpawnDesc(6,0,0)); // man alt.
				for (i = 0; i < 4; i++) spawnPool.push(new VisitorSpawnDesc(2,0,0)); // woman
				for (i = 0; i < 2; i++) spawnPool.push(new VisitorSpawnDesc(7,0,0)); // woman alt.
				for (i = 0; i < 8; i++) spawnPool.push(new VisitorSpawnDesc(4,0,0)); // granny
				break;
				
			case 5: // nothing new, 24 total
				for (i = 0; i < 6; i++) spawnPool.push(new VisitorSpawnDesc(1)); // man
				for (i = 0; i < 3; i++) spawnPool.push(new VisitorSpawnDesc(6)); // man alt.
				for (i = 0; i < 6; i++) spawnPool.push(new VisitorSpawnDesc(2)); // woman
				for (i = 0; i < 3; i++) spawnPool.push(new VisitorSpawnDesc(7)); // woman alt.
				for (i = 0; i < 6; i++) spawnPool.push(new VisitorSpawnDesc(4)); // granny
				break;
				
			case 6: // children introduced. have a lot of them! 28 total
				for (i = 0; i < 3;  i++) spawnPool.push(new VisitorSpawnDesc(1)); // 16 man
				for (i = 0; i < 1;  i++) spawnPool.push(new VisitorSpawnDesc(6)); // 4 man alt.
				for (i = 0; i < 3;  i++) spawnPool.push(new VisitorSpawnDesc(2)); // 16 woman
				for (i = 0; i < 1;  i++) spawnPool.push(new VisitorSpawnDesc(7)); // 4 woman alt.
				for (i = 0; i < 2;  i++) spawnPool.push(new VisitorSpawnDesc(4)); // 20 granny
				for (i = 0; i < 13; i++) spawnPool.push(new VisitorSpawnDesc(0)); // 40 child
				for (i = 0; i < 5;  i++) spawnPool.push(new VisitorSpawnDesc(5)); // 12 child alt.
				break;
				
			case 7: // nothing new, equal quantities all types, 32 total
				for (i = 0; i < 6; i++) spawnPool.push(new VisitorSpawnDesc(1)); // 27 man
				for (i = 0; i < 2; i++) spawnPool.push(new VisitorSpawnDesc(6)); // 5 man alt.
				for (i = 0; i < 6; i++) spawnPool.push(new VisitorSpawnDesc(2)); // 27 woman
				for (i = 0; i < 2; i++) spawnPool.push(new VisitorSpawnDesc(7)); // 5 woman alt.
				for (i = 0; i < 8; i++) spawnPool.push(new VisitorSpawnDesc(4)); // 32 granny
				for (i = 0; i < 6; i++) spawnPool.push(new VisitorSpawnDesc(0)); // 27 child
				for (i = 0; i < 2; i++) spawnPool.push(new VisitorSpawnDesc(5)); // 5 child alt.
				break;
				
			case 8: // tourists introduced, more than usual, 36 total
				for (i = 0; i < 3;  i++) spawnPool.push(new VisitorSpawnDesc(1)); // 17 man
				for (i = 0; i < 1;  i++) spawnPool.push(new VisitorSpawnDesc(6)); // 4 man alt.
				for (i = 0; i < 3;  i++) spawnPool.push(new VisitorSpawnDesc(2)); // 17 woman
				for (i = 0; i < 1;  i++) spawnPool.push(new VisitorSpawnDesc(7)); // 4 woman alt.
				for (i = 0; i < 4;  i++) spawnPool.push(new VisitorSpawnDesc(4)); // 21 granny
				for (i = 0; i < 3;  i++) spawnPool.push(new VisitorSpawnDesc(0)); // 21 child
				for (i = 0; i < 1;  i++) spawnPool.push(new VisitorSpawnDesc(5)); // 10 child alt.
				for (i = 0; i < 16; i++) spawnPool.push(new VisitorSpawnDesc(3)); // 40 tourist
				for (i = 0; i < 4;  i++) spawnPool.push(new VisitorSpawnDesc(8)); // 10 tourist alt.
				break;
				
			case 9: // nothing new, all equal, 40 total
				for (i = 0; i < 7; i++) spawnPool.push(new VisitorSpawnDesc(1)); // 25 man
				for (i = 0; i < 1; i++) spawnPool.push(new VisitorSpawnDesc(6)); // 7 man alt.
				for (i = 0; i < 7; i++) spawnPool.push(new VisitorSpawnDesc(2)); // 25 woman
				for (i = 0; i < 1; i++) spawnPool.push(new VisitorSpawnDesc(7)); // 7 woman alt.
				for (i = 0; i < 8; i++) spawnPool.push(new VisitorSpawnDesc(4)); // 32 granny
				for (i = 0; i < 7; i++) spawnPool.push(new VisitorSpawnDesc(0)); // 25 child
				for (i = 0; i < 1; i++) spawnPool.push(new VisitorSpawnDesc(5)); // 7 child alt.
				for (i = 0; i < 7; i++) spawnPool.push(new VisitorSpawnDesc(3)); // 25 tourist
				for (i = 0; i < 1; i++) spawnPool.push(new VisitorSpawnDesc(8)); // 7 tourist alt.
				break;
				
			case 10: // zombie rush, 44 total
				for (i = 0; i < 3;  i++) spawnPool.push(new VisitorSpawnDesc(1)); // 20 man
				for (i = 0; i < 1;  i++) spawnPool.push(new VisitorSpawnDesc(6)); // 5 man alt.
				for (i = 0; i < 3;  i++) spawnPool.push(new VisitorSpawnDesc(2)); // 20 woman
				for (i = 0; i < 1;  i++) spawnPool.push(new VisitorSpawnDesc(7)); // 5 woman alt.
				for (i = 0; i < 4;  i++) spawnPool.push(new VisitorSpawnDesc(4)); // 36 granny
				for (i = 0; i < 3;  i++) spawnPool.push(new VisitorSpawnDesc(0)); // 20 child
				for (i = 0; i < 1;  i++) spawnPool.push(new VisitorSpawnDesc(5)); // 5 child alt.
				for (i = 0; i < 3;  i++) spawnPool.push(new VisitorSpawnDesc(3)); // 20 tourist
				for (i = 0; i < 1;  i++) spawnPool.push(new VisitorSpawnDesc(8)); // 5 tourist alt.
				for (i = 0; i < 24; i++) spawnPool.push(new VisitorSpawnDesc(9)); // 40 zombies
				break;
				
			default:
				var amount:int = getLevelNr() * 4 + 4;
				for (i = 0; i < amount; i++)
				{
					// equal distribution among the normal variants
					var type:int = Math.floor(Math.random() * 5);
					if (Math.random() < .2) type += 5;
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
