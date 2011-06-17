package
{
    import org.flixel.*;

	public class StartState extends FlxState
	{	
		override public function create():void
		{
			add(new FlxText(0, 0, 100, "Hello, World!"));
		}
	}
}
