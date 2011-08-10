package
{
	import org.flixel.*;
	
	public class StatsText extends FlxText
	{
		private var timeToNextText:Number; // in seconds
		private var statistics:Statistics;
		private var levelNr:int;
		private var textPage:int;  // Which group of info is printed atm
		private var textStage:int; // How many items of info are printed
		private var nextItem:int;  // Index of combo, visitor or upgrade
		
		private const TITLE_TEXT:String = "Level Statistics\n";
		private const TEXTSTAGE_SECONDS:Number = 1;
		private const FONT_SIZE:Number = 18;
		private const TOP_Y:uint = 100;
		private const COLOR:uint = 0xeeee9f;
		private const SHADOW:uint = 0x333333;
		
		public function StatsText(stats:Statistics)
		{
			super (0, TOP_Y, FlxG.width);
			alignment = "center";
			color = COLOR;
			shadow = SHADOW;
			size = FONT_SIZE;
			timeToNextText = 0;
			visible = false;
			alive = false;
			statistics = stats;
		}
		
		public function playback(levelNr:int):void
		{
			this.levelNr = levelNr;
			timeToNextText = TEXTSTAGE_SECONDS;
			textPage = 0;
			textStage = 0;
			nextItem = 0;
			text = TITLE_TEXT;
			revive();
			visible = true;
		}
		
		override public function update():void
		{
			var printed:Boolean = false;
			var i:int = 0;
			
			timeToNextText -= FlxG.elapsed;
			
			if (timeToNextText <= 0)
			{
				if (textPage == 0) // display score, hit ratio & kills
				{
					if (textStage == 0)
					{
						var levelScore:uint = statistics.getLevelScore(levelNr);
						text += "Score: " + levelScore.toString() + "\n";
					} else
					if (textStage == 1)
					{
						text += "Hit ratio: " + 
						        statistics.getLevelSpitCount(levelNr).toString() + "/" + 
						        statistics.getLevelHitCount(levelNr).toString() + " (" +
						        (statistics.getLevelHitRatio(levelNr) * 100).toFixed(0) + "%)\n";
					} else // print visitor kills
					{
						for (i = nextItem; i < Globals.N_VISITOR_TYPES; i++)
						{
							var kills:int = statistics.getLevelKillsOfVisitorType(i, levelNr);
							if (kills > 0)
							{
								text += "Visitor " + i.toString() +
								        " killed: " + kills.toString() + "\n";
								printed = true;
								nextItem = i+1;
								break;
							}
						}
						
						if (!printed)
						{
							text = TITLE_TEXT;
							textPage++;
							textStage = 0;
							nextItem = 0;
							return;
						}
					} 
					
					textStage++;
				} else
				if (textPage == 1) // display combos & upgrades
				{
					if (textStage == 0) // print combos
					{
						var maxCombo:int = statistics.getLevelMaxCombo(levelNr);
						
						for (i = Math.max(nextItem,2); i <= maxCombo; i++)
						{
							var combos:uint = statistics.getLevelComboCount(i, levelNr);
							if (combos > 0)
							{
								text += "x" + i.toString() +
								        " combo: " + combos.toString() + "\n";
								printed = true;
								nextItem = i+1;
								break;
							}
						}
						
						if (!printed)
						{
							textStage++;
							nextItem = 0;
							return;
						}
					} else // print upgrades
					{
						for (i = nextItem; i <= Globals.N_UPGRADE_TYPES; i++)
						{
							var upgrades:int = statistics.getLevelUpgradesOfType(i, levelNr);
							if (upgrades > 0)
							{
								text += "Upgrade " + i.toString() +
								        ": " + upgrades.toString() + "\n";
								printed = true;
								nextItem = i+1;
								break;
							}
						}
						
						if (!printed)
						{
							kill(); // nothing more to display
						}
					}
				}
				
				timeToNextText = TEXTSTAGE_SECONDS;
			}
		}
		
		private function appendMoreText():void
		{
			textStage++;
		}
		
		public function canStartPlayback():Boolean
		{
			return !visible;
		}
		
		public function canFinishPlayback():Boolean
		{
			return !alive;
		}
		
		public function finishPlayback():void
		{
			visible = false;
		}
		
		/*
		 * 
			_debug_statsText.text = "Current Stats:\n" +
				"score: " + stats.getLevelScore(currentLevel) + "\n" +
				"spits: " + stats.getLevelSpitCount(currentLevel) + "\n" +
				"hits: " + stats.getLevelHitCount(currentLevel) + "\n" +
				"ratio: " + stats.getLevelHitRatio(currentLevel) + "\n" +
				"kills: " + stats.getLevelKills(currentLevel) + "\n" +
				"max-combo: " + max_combos + "\n" +
				"upgrades: " + stats.getLevelUpgrades(currentLevel) + "\n" +
				"child killed: " + stats.getLevelKillsOfVisitorType(0, currentLevel) + "\n" +
				"2x combos: " + stats.getLevelComboCount(2, currentLevel) + "\n" +
				"rapid upgrades: " + stats.getLevelUpgradesOfType(0, currentLevel);
				*/
	}
}
