package
{
	import org.flixel.*;
	
	/**
	 * The Statistics class keeps a record of all the important numbers 
	 * in the game which we (might) want to evaluate later.
	 * Examples are score, kills, combos and hit ratio.
	 */
	public class Statistics
	{
		private var elapsedTime:Number;            // total *time of all levels*, not game time, in seconds
		private var totalStats:StatisticsSingle;          // holds stats across all levels
		private var levelStats:Vector.<StatisticsSingle>; // holds stats by level, [0] == first lvl
		
		private function currentLevelStats():StatisticsSingle
		{
			return levelStats[levelStats.length-1];
		}
		
		public function Statistics()
		{
			elapsedTime = 0;
			totalStats = new StatisticsSingle();
			levelStats = new Vector.<StatisticsSingle>();
			levelStats[0] = new StatisticsSingle();
		}
		
		/**
		 * Keeping track of the elapsed time is important for
		 * statistics because we reserve the option to calculate
		 * time spent per level.
		 */
		public function update():void
		{
			elapsedTime += FlxG.elapsed;
		}
		
		
		/**
		 * Counting spits, meaning the number of spit objects
		 * which leave the llama on keypress.
		 */
		public function countSpit():void
		{
			totalStats.spits++;
			currentLevelStats().spits++;
		}
		
		/**
		 * Counting hits is important for the hit ratio.
		 * This also counts hits which do not kill.
		 * See also getHitCount().
		 */
		public function countHit():void
		{
			totalStats.hits++;
			currentLevelStats().hits++;
		}
		
		/**
		 * This counts kills by visitor type, total score,
		 * score per level, count per combo multiplier all in one.
		 */
		public function countKill(killed:Visitor, score:int, combo:int):void
		{
			for each (var stats:StatisticsSingle in [totalStats, currentLevelStats()])
			{
				stats.score += score * combo;
				stats.kills[killed.getType()]++;
				if (stats.combos[combo] == undefined)
					stats.combos[combo] = 1;
				else
					stats.combos[combo]++;
			}
		}
		
		/**
		 * This is called at the *end* of every level.
		 * We do not use an extra levelNr counter var since
		 * we always have levelStats.length.
		 * See also getLevelNr()
		 */
		public function countLevel():void
		{
			levelStats[levelStats.length] = new StatisticsSingle();
		}
		
		/**
		 * Counts upgrades by type.
		 */
		public function countUpgrade(upgradeType:uint):void
		{
			totalStats.upgrades[upgradeType]++;
			currentLevelStats().upgrades[upgradeType]++;
		}
		
		
		/**
		 * The current game score
		 */
		public function getTotalScore():uint
		{
			return totalStats.score;
		}
		
		/**
		 * Total amount of spits spit.
		 */
		public function getSpitCount():uint
		{
			return totalStats.spits;
		}
		
		/**
		 * Total amount of spits which scored their target(s):
		 *   visitors and upgrade boxes.
		 * Usage with upgrades:
		 * - A burst spit counts as exactly one hit if *any* of
		 *   the burst pieces hit any target.
		 * - A large spit counts as exactly one hit
		 *   if it hits any visitor.
		 */
		public function getHitCount():uint
		{
			return totalStats.hits;
		}
		
		/**
		 * Hits / (Hits + Misses)
		 */
		public function getHitRatio():Number
		{
			return totalStats.hits / totalStats.spits;
		}
		
		/**
		 * Total count of visitors killed
		 */
		public function getTotalKills():uint
		{
			var sum:int = 0;
			for (var i:int = 0; i < totalStats.kills.length; i++)
				sum += totalStats.kills[i];
			return sum;
		}
		
		/**
		 * Count of visitors of that type killed
		 */
		public function getKillsOfVisitorType(visitorType:int):uint
		{
			return totalStats.kills[visitorType];
		}
		
		/**
		 * The highest achieved combo
		 */
		public function getMaxCombo():int
		{
			return totalStats.combos.length - 1;
		}
		
		/**
		 * Returns the number of combos achieved with the given
		 * multiplier.
		 */
		public function getComboCount(comboMultiplier:int):uint
		{
			return totalStats.combos[comboMultiplier];
		}
		
		/**
		 * The total amount of upgrades collected
		 */
		public function getTotalUpgrades():uint
		{
			var sum:uint = 0;
			for (var i:uint = 0; i < Globals.N_UPGRADE_TYPES; i++)
				sum += totalStats.upgrades[i];
			return sum;
		}
		
		/**
		 * The amount of upgrades of the specific type collected
		 */
		public function getUpgradesOfType(upgradeType:uint):uint
		{
			return totalStats.upgrades[upgradeType];
		}
		
		
		private function statsOfLevel(levelNr:int):StatisticsSingle
		{
			if ((levelNr >= 0) && (levelNr < levelStats.length))
			{
				//return levelStats[levelNr-1];
				return totalStats;
			}
			else
			{
				return totalStats;
			}
		}
		
		/**
		 * The amount of points collected in this level
		 * levelStats is a 0-based vector while levelNr is 1-based.
		 */
		public function getLevelScore(levelNr:int):uint
		{
			var s:StatisticsSingle = statsOfLevel(levelNr);
			return statsOfLevel(levelNr).score;
		}
		
		/**
		 * Total amount of spits spit in this level.
		 * levelStats is a 0-based vector while levelNr is 1-based.
		 */
		public function getLevelSpitCount(levelNr:int):uint
		{
			return statsOfLevel(levelNr).spits;
		}
		
		/**
		 * Total amount of hits scored on visitors and upgrade boxes
		 * in this level.
		 * levelStats is a 0-based vector while levelNr is 1-based.
		 */
		public function getLevelHitCount(levelNr:int):uint
		{
			return statsOfLevel(levelNr).hits;
		}
		
		/**
		 * LevelHits / (LevelHits + LevelMisses)
		 * levelStats is a 0-based vector while levelNr is 1-based.
		 */
		public function getLevelHitRatio(levelNr:int):Number
		{
			return statsOfLevel(levelNr).hits / statsOfLevel(levelNr).spits;
		}
		
		/**
		 * Total count of visitors killed in this level
		 * levelStats is a 0-based vector while levelNr is 1-based.
		 */
		public function getLevelKills(levelNr:int):uint
		{
			var sum:int = 0;
			var killsArray:Vector.<int> = statsOfLevel(levelNr).kills;
			for (var i:int = 0; i < killsArray.length; i++)
				sum += killsArray[i];
			return sum;
		}
		
		/**
		 * Count of visitors of that type killed in this level
		 * levelStats is a 0-based vector while levelNr is 1-based.
		 */
		public function getLevelKillsOfVisitorType(visitorType:int, levelNr:int):uint
		{
			return statsOfLevel(levelNr).kills[visitorType];
		}
		
		/**
		 * The highest achieved combo in this level
		 * levelStats is a 0-based vector while levelNr is 1-based.
		 */
		public function getLevelMaxCombo(levelNr:int):int
		{
			return statsOfLevel(levelNr).combos.length - 1;
		}
		
		/**
		 * Returns the number of combos achieved with the given
		 * multiplier in this level.
		 * levelStats is a 0-based vector while levelNr is 1-based.
		 */
		public function getLevelComboCount(comboMultiplier:int, levelNr:int):uint
		{
			return statsOfLevel(levelNr).combos[comboMultiplier];
		}
		
		/**
		 * The total amount of upgrades collected in this level
		 * levelStats is a 0-based vector while levelNr is 1-based.
		 */
		public function getLevelUpgrades(levelNr:int):uint
		{
			var sum:uint = 0;
			for (var i:uint = 0; i < Globals.N_UPGRADE_TYPES; i++)
				sum += statsOfLevel(levelNr).upgrades[i];
			return sum;
		}
		
		/**
		 * The amount of upgrades of the specific type collected
		 * in this level
		 * levelStats is a 0-based vector while levelNr is 1-based.
		 */
		public function getLevelUpgradesOfType(upgradeType:uint, levelNr:int):uint
		{
			return statsOfLevel(levelNr).upgrades[upgradeType];
		}
		
		/**
		 * Returns the number of the current level, or, after the
		 * game is over, which level the player died on.
		 * levelStats is a 0-based vector while this number is 1-based.
		 */
		public function getLevelNr():int
		{
			return levelStats.length;
		}
	}
}
