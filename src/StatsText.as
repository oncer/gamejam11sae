package
{
	import org.flixel.*;
	
	public class StatsText extends FlxText
	{
		private var timeToNextText:Number; // in seconds
		private var statistics:Statistics;
		private var levelNr:int;
		private var textPage:int;   // Which group of info is printed atm
		private var textStage:int;  // How many items of info are printed
		private var nextItem:int;   // Index of combo, visitor or upgrade
		
		private const TEXTSTAGE_SECONDS:Number = .4;
		private const WHOLETEXT_SECONDS:Number = 7;
		private const FONT_SIZE:Number = 18;
		private const LEFT_X:uint = 300;
		private const TOP_Y:uint = 100;
		private const COLOR:uint = 0xeeee9f;
		private const SHADOW:uint = 0x333333;
		
		public function StatsText(stats:Statistics)
		{
			super (LEFT_X, TOP_Y, FlxG.width);
			alignment = "left";
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
			text = "Level Statistics\n";
			revive();
			visible = true;
		}
		
		override public function update():void
		{
			var i:int = 0;
			var visitorsScore:int;
			
			timeToNextText -= FlxG.elapsed;
			
			if (timeToNextText <= 0)
			{
				timeToNextText = TEXTSTAGE_SECONDS;
				
				switch (textStage)
				{
					case 0:
						text += "Hit Rate: " + (statistics.getLevelHitRatio(levelNr) * 100).toFixed(0) + "%\n";
						break;
						
					case 1:
						text += "Visitors killed: " + statistics.getLevelKills(levelNr).toString() + "\n";
						break;
						
					case 2:
						text += "Upgrades: " + statistics.getLevelUpgrades(levelNr).toString() + "\n";
						break;
						
					case 3:
						text += "Highest Combo: x" + statistics.getLevelMaxCombo(levelNr).toString() + "\n";
						break;
						
					case 4:
						text += "Score: " + statistics.getLevelScore(levelNr).toString() + "             \n";
						break;
						
					case 5:
						visitorsScore = 0;
						for (i = 0; i < Globals.N_VISITOR_TYPES; i++)
						{
							visitorsScore += Globals.VISITOR_POINTS[i] * statistics.getLevelKillsOfVisitorType(i, levelNr);
						}
						text += "   * Basic: " + visitorsScore.toString() + "\n";
						break;
						
					case 6:
						visitorsScore = 0;
						for (i = 0; i < Globals.N_VISITOR_TYPES; i++)
						{
							visitorsScore += Globals.VISITOR_POINTS[i] * statistics.getLevelKillsOfVisitorType(i, levelNr);
						}
						text += "   * Combo: " + (statistics.getLevelScore(levelNr) - visitorsScore).toString() + "\n";
						timeToNextText = WHOLETEXT_SECONDS;
						break;
						
					default:
						kill();
						break;
				}
				
				textStage++;
				
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
	}
}
