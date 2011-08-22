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
		[Embed(source="../gfx/map/map_bg4_2.jpg")] private var map_bg4_2:Class;
		[Embed(source="../gfx/map/map_bg4_3.jpg")] private var map_bg4_3:Class;
		
		[Embed(source="../gfx/map/map_front_0.png")] private var map_front_0:Class;
		[Embed(source="../gfx/map/map_front_1.png")] private var map_front_1:Class;
		[Embed(source="../gfx/map/map_front_2.png")] private var map_front_2:Class;
		[Embed(source="../gfx/map/map_front_3.png")] private var map_front_3:Class;
		
		private var y_offset_array:Array = new Array(0, 104, 128, 168, 284);
		private var height_array:Array = new Array(240, 64, 96, 200, 216);
		
		private var bg1_array:Array = new Array(map_bg1_0, map_bg1_1, map_bg1_2, map_bg1_3);
		private var bg2_array:Array = new Array(map_bg2_0, map_bg2_1, map_bg2_2, map_bg2_3);
		private var bg3_array:Array = new Array(map_bg3_0, map_bg3_1, map_bg3_2, map_bg3_3);
		private var bg4_array:Array = new Array(map_bg4_0, map_bg4_1, map_bg4_2, map_bg4_3);
		private var front_array:Array = new Array(map_front_0, map_front_1, map_front_2, map_front_3);
		
		private var layer_arrays:Array = new Array(bg4_array, bg3_array, bg2_array, bg1_array, front_array);
		
		private var layers:Array;
		
		public static const TIME_MORNING:int = 0;
		public static const TIME_DAY:int = 1;
		public static const TIME_EVENING:int = 2;
		public static const TIME_NIGHT:int = 3;
		public static const NUM_TIME:int = 4;
		
		public static const NUM_FRAMES:int = 10;
		
		private var time:int; // current time, use TIME_* constant
		
		private var shift:Number; // number between 0.0 and 1.0
								 // 1.0 means blend_layers is in foreground
								 
		private var doShift:Boolean;
		
		public function LevelBackground(TIME:int):void
		{
			time = TIME;
			doShift = false;
			layers = new Array();
			for (var i:int = 0; i < NUM_TIME; i++) {
				layers[i] = new Array();
				_fillLayers(layers[i], i);
			}
			resetLayers();
		}
		
		public function next():void
		{
			time = (time + 1) % NUM_TIME;
			resetLayers();
		}
		
		public function startShift():void
		{
			doShift = true;
		}
		
		private function _fillLayers(LAYERS:Array, time:int):void
		{
			var i:int;
			var a:Array;
			var s:FlxSprite;
			for (i=0; i<layer_arrays.length; i++) {
				a = layer_arrays[i];
				if (i == 1 || i == 2) {
					s = new SpriteScrollerH(0, y_offset_array[i]);
				} else {
					s = new FlxSprite(0, y_offset_array[i]);
				}
				s.loadGraphic(a[time], true, false, 800, height_array[i]);
				LAYERS.push(s);
			}
		}
		
		private function resetLayers():void
		{
			clear();
			var tLast:int = time - 1;
			if (tLast < 0) tLast = NUM_TIME - 1;
			layers[time][1].x = layers[tLast][1].x;
			layers[time][2].x = layers[tLast][2].x;
			
			for (var i:int = 0; i < layers[time].length; i++) {
				add(layers[time][i]);
			}
			
			shift = 0.0;
		}
		
		public override function update():void
		{
			layers[time][1].x += 21.1 * FlxG.elapsed;
			layers[time][2].x += 45.3 * FlxG.elapsed;
			
			if (doShift) {
				shift += FlxG.elapsed;
				if (shift > 1.0) {
					next();
					doShift = false;
					shift = 0.0;
				}
			}
			super.update();
		}
		
		public override function draw():void
		{
			var s:FlxSprite;
			if (shift < 1.0) {
				for each (s in layers[time]) {
					s.frame = shift * NUM_FRAMES;
				}
			}
			super.draw();
		}
	}
}
