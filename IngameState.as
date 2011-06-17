/*
 * IngameState
 * In diesem State findet das eigentliche Game statt.
 * Hüpfendes Llama, aggressive Besucher, Action etc.
 */

package
{
    import org.flixel.*;

	public class IngameState extends FlxState
	{
		//internal var llama:FlxSprite;
		
		public var llama:Llama;			//Refers to the little player llama
		
		override public function create():void
		{
			FlxG.debug = true; // enable debug console
			
			add(new FlxText(0, 0, 100, "Hello, World!"));
			
			trace("alsk");
			//Initialize the llama and add it to the layer
			llama = new Llama();
			add(llama);
		}
		
		override public function update():void
		{
			var jumpUpAcceleration:int = -800;
			if (llama.acceleration.y == jumpUpAcceleration) {
				llama.acceleration.y = 200;
			}
			if (llama.y > 350) {
				llama.acceleration.y = jumpUpAcceleration;
			}
			
			FlxG.log(llama.y);
			//trace("test");
			trace(llama.y);
			super.update();
		}
	}
}