package{
	import org.flixel.*;
	
	public class LevelBackground extends FlxGroup
	{
		[Embed(source="../gfx/map/map_bg1_0.png")] private var map_bg1_0:Class;
		[Embed(source="../gfx/map/map_bg1_1.png")] private var map_bg1_1:Class;
		[Embed(source="../gfx/map/map_bg1_2.png")] private var map_bg1_2:Class;
		[Embed(source="../gfx/map/map_bg1_3.png")] private var map_bg1_3:Class;
		
		[Embed(source="../gfx/map/map_bg2_0.png")] private var map_bg2_0:Class;
		[Embed(source="../gfx/map/map_bg2_1.png")] private var map_bg2_1:Class;
		[Embed(source="../gfx/map/map_bg2_2.png")] private var map_bg2_2:Class;
		[Embed(source="../gfx/map/map_bg2_3.png")] private var map_bg2_3:Class;
		
		[Embed(source="../gfx/map/map_bg3_0.png")] private var map_bg3_0:Class;
		[Embed(source="../gfx/map/map_bg3_1.png")] private var map_bg3_1:Class;
		[Embed(source="../gfx/map/map_bg3_2.png")] private var map_bg3_2:Class;
		[Embed(source="../gfx/map/map_bg3_3.png")] private var map_bg3_3:Class;
		
		[Embed(source="../gfx/map/map_bg4_0.png")] private var map_bg4_0:Class;
		[Embed(source="../gfx/map/map_bg4_1.png")] private var map_bg4_1:Class;
		[Embed(source="../gfx/map/map_bg4_2.png")] private var map_bg4_2:Class;
		[Embed(source="../gfx/map/map_bg4_3.png")] private var map_bg4_3:Class;
		
		[Embed(source="../gfx/map/map_front_0.png")] private var map_front_0:Class;
		[Embed(source="../gfx/map/map_front_1.png")] private var map_front_1:Class;
		[Embed(source="../gfx/map/map_front_2.png")] private var map_front_2:Class;
		[Embed(source="../gfx/map/map_front_3.png")] private var map_front_3:Class;
		
		private var bg1_array:Array = new Array(map_bg1_0, map_bg1_1, map_bg1_2, map_bg1_3);
		private var bg2_array:Array = new Array(map_bg2_0, map_bg2_1, map_bg2_2, map_bg2_3);
		private var bg3_array:Array = new Array(map_bg3_0, map_bg3_1, map_bg3_2, map_bg3_3);
		private var bg4_array:Array = new Array(map_bg4_0, map_bg4_1, map_bg4_2, map_bg4_3);
		private var front_array:Array = new Array(map_front_0, map_front_1, map_front_2, map_front_3);
		
		private var layer_arrays:Array = new Array(bg4_array, bg3_array, bg2_array, bg1_array, front_array);
		
		private var layers:Array;
		private var blend_layers:Array;
		
		public static const TIME_MORNING:int = 0;
		public static const TIME_DAY:int = 1;
		public static const TIME_EVENING:int = 2;
		public static const TIME_NIGHT:int = 3;
		public static const NUM_TIME:int = 4;
		
		private var time:int; // current time, use TIME_* constant
		
		public var shift:Number; // number between 0.0 and 1.0
								 // 1.0 means blend_layers is in foreground
		
		public function LevelBackground(TIME:int):void
		{
			time = TIME;
			resetLayers();
		}
		
		public function next():void
		{
			time = (time + 1) % NUM_TIME;
			resetLayers();
		}
		
		private function resetLayers():void
		{
			clear();
			layers = new Array();
			blend_layers = new Array();
			
			var a:Array;
			var s:SpriteScrollerH;
			for each (a in layer_arrays) {
				s = new SpriteScrollerH(a[time]);
				layers.push(s);
			}
			var tNext:int = (time + 1) % NUM_TIME;
			for each (a in layer_arrays) {
				s = new SpriteScrollerH(a[tNext]);
				blend_layers.push(s);
			}
			
			for (var i:int = 0; i < layers.length; i++) {
				add(layers[i]);
				add(blend_layers[i]);
			}
			
			shift = 0.0;
		}
		
		public override function update():void
		{
			super.update();
		}
		
		public override function draw():void
		{
			var s:SpriteScrollerH;
			for each (s in blend_layers) {
				s.alpha = 1.0;
			}
			for each (s in blend_layers) {
				s.alpha = shift;
			}
			super.draw();
		}
	}
}
