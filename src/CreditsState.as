package
{
	import org.flixel.*;
	import flash.system.fscommand;
	
	public class CreditsState extends FlxState
	{
		[Embed(source="../gfx/credits.png")] private var BackgroundImage:Class;
	
		override public function create():void
		{
			add(new FlxSprite(0, 0, BackgroundImage));
			
			FlxG.mouse.show();
		}

		override public function update():void
		{
			super.update();
				
			if (FlxG.keys.any() || FlxG.mouse.justPressed())
			{
				anyKeyPressed();
			}
		}

		public function anyKeyPressed():void
		{
			FlxG.switchState(new MenuState());
		}
	}
}
