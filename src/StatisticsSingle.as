package
{
	/**
	 * Structure which holds a number of statistical values which
	 * may apply to a single level or the game in total.
	 */
	public class StatisticsSingle
	{
		public var score:int;
		public var spits:uint;
		public var hits:uint;
		public var combos:Array;          // combo count by multiplier. sparse!
		public var kills:Vector.<int>;    // kills by visitor type
		public var upgrades:Vector.<int>; // combo count by multiplier
		
		public function StatisticsSingle():void
		{
			score = 0;
			spits = 0;
			hits = 0;
			combos = new Array();
			var i:uint;
			
			kills = new Vector.<int>();
			for (i = 0; i < Globals.N_VISITOR_TYPES; i++)
				kills[i] = 0;
			
			upgrades = new Vector.<int>();
			for (i = 0; i < Globals.N_UPGRADE_TYPES; i++)
				upgrades[i] = 0;
		}
	}
}
