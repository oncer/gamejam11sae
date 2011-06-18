/* Global game vars */

package
{
	public class Globals
	{
		public static const MAX_VISITORS:uint = 256; // group capacity
		public static const MAX_SPITS:uint = 32; // group capacity
		public static const MAX_FLYERS:uint = 40; // group capacity, max. # of collision checked flying visitors
		public static const MAX_SCORETEXTS:uint = 256; // group capacity
		
		
		public static const GROUND_LEVEL:uint = 416; // y coord in pixels
		public static const INIT_DIFFICULTY:Number = 1.0;
		public static const DIFFICULTY_PER_SECOND:Number = 0.3;
		public static const ANIM_SPEED:Number = 10; // in fps
		public static const CAGE_LEFT:uint = 320;  // px boundary
		public static const CAGE_RIGHT:uint = 479; // px boundary
		public static const CAGE_TOP:uint = 256; // px boundary
		
		public static const FLY_TIMEOUT:Number = 1.3; // min fly time in seconds
	}
}
