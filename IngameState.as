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
		internal var llama:FlxSprite;
		
		override public function create():void
		{
			add(new FlxText(0, 0, 100, "Hello, World!"));
		}
	}
}
