/* Global game vars */

package
{
	public class Globals
	{
		public static const MAX_VISITORS:uint = 256; // group capacity
		public static const MAX_SPITS:uint = 32; // group capacity
		public static const MAX_FLYERS:uint = 40; // group capacity, max. # of collision checked flying visitors
		public static const MAX_SCORETEXTS:uint = 256; // group capacity
		
		public static const GROUND_LEVEL:int = 416; // y coord in pixels
		public static const FLOAT_LEVEL:Number = 150; // y coord in pixels
		public static const ANIM_SPEED:Number = 10; // in fps
		public static const CAGE_LEFT:int = 320;  // px boundary
		public static const CAGE_RIGHT:int = 479; // px boundary
		public static const CAGE_TOP:int = 256; // px boundary
		public static const TRAMPOLIN_TOP:int = 368;
		public static const VISITOR_GOAL_Y:int = 320; // px value
		public static const N_VISITOR_TYPES:int = 10;
		public static const N_UPGRADE_TYPES:uint = 3;
		
		public static const FLY_TIMEOUT:Number = 1.3; // min fly time in seconds
		
		public static const VISITOR_POINTS:Vector.<int> = Vector.<int>([
			40, // child
			15, // man with glasses & hat
			15, // woman
			30, // fat tourist
			10, // old lady
			40, // child
			15, // man with glasses & hat
			15, // woman
			30, // fat tourist
			100 // zombie lady
		]);
		
		public static var sfxPlayer:SfxPlayer;
	}
}
