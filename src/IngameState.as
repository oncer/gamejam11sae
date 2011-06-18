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
		
		public var llama:Llama;			//Refers to the little player llama
		
		override public function create():void
		{
			FlxG.debug = true; // enable debug console
			
			//add(new FlxText(0, 0, 100, "Hello, World!"));
			
			var bg:FlxSprite = new FlxSprite(0,0);			
			bg.loadGraphic(Background);
			add(bg);
			
			trace("IngameState.onCreate()");
			//Initialize the llama and add it to the layer
			llama = new Llama();
			add(llama);
			
			/*var target:FlxPoint = new FlxPoint(110, 100);
			var pivot:FlxPoint = new FlxPoint(100, 100);
			//var rotatedPoint:FlxPoint = FlxU.rotatePoint(target.x, target.y, pivot.x, pivot.y, 0);
			var rotatedPoint:FlxPoint = rotatePoint(target.x, target.y, pivot.x, pivot.y, 180);
			trace("x: " + rotatedPoint.x + " y: " + rotatedPoint.y);*/
		}
		
		
		
		override public function update():void
		{
			super.update();
			
			var jumpUpAcceleration:int = -800;
			if (llama.lama.acceleration.y == jumpUpAcceleration) {
				llama.lama.acceleration.y = 200;
			}
			if (llama.lama.y > 350) {
				llama.lama.acceleration.y = jumpUpAcceleration;
			}
			
			//FlxG.log(llama.y);
			//trace("test");
			//trace("lama y: " + llama.lama.y);
			
			// for faster debugging
			if (FlxG.keys.ESCAPE) {
				trace("quit");
				fscommand("quit");
			}
		}
	}
}
