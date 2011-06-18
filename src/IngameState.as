/*
 * IngameState
 * In diesem State findet das eigentliche Game statt.
 * Hüpfendes Llama, aggressive Besucher, Action etc.
 */

package
{
    import org.flixel.*;
	import flash.system.fscommand;

	public class IngameState extends FlxState
	{
		//internal var llama:FlxSprite;
		
		[Embed(source="../gfx/map.png")] private var Background:Class;	//Graphic of the player's ship
		
		public static const MAX_VISITORS:uint = 1024;
		
		public var llama:Llama;			//Refers to the little player llama
		private var visitors:FlxGroup;
		
		private var difficulty:Number;
		private var lastSpawnTime:uint;
		
		override public function create():void
		{
			FlxG.debug = true; // enable debug console
			
			//add(new FlxText(0, 0, 100, "Hello, World!"));
			
			var bg:FlxSprite = new FlxSprite(0,0);			
			bg.loadGraphic(Background);
			add(bg);
			
			trace("alsk");
			
			difficulty = 1.0;
			lastSpawnTime = FlxG._game._total;
			
			// Initialize llama
			llama = new Llama();
			add(llama);
			
			// Initialize visitors
			visitors = new FlxGroup (MAX_VISITORS);
			add(visitors);
		}
		
		override public function update():void
		{
			super.update();
			
			var jumpUpAcceleration:int = -800;
			if (llama.acceleration.y == jumpUpAcceleration) {
				llama.acceleration.y = 200;
			}
			if (llama.y > 350) {
				llama.acceleration.y = jumpUpAcceleration;
			}
			
			// Visitors
			var spawnInterval:uint = 10000.0 / (difficulty + 40.0);
			var currentTime:uint = FlxG._game._total;
			
			while (lastSpawnTime < currentTime) 
			{
				spawnVisitor ();
				lastSpawnTime += spawnInterval;
			}
			
			//FlxG.log(llama.y);
			//trace("test");
			trace("lama y: " + llama.y);
			
			// for faster debugging
			if (FlxG.keys.ESCAPE) {
				trace("quit");
				fscommand("quit");
			}
		}
		
		private function spawnVisitor():void
		{
			visitors.add(new Visitor(difficulty));
		}
	}
}
