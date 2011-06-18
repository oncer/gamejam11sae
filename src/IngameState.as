/*
 * IngameState
 * In diesem State findet das eigentliche Game statt.
 * Hüpfendes Llama, aggressive Besucher, Action etc.
 */

package
{
    import org.flixel.*;
	import flash.system.fscommand;
	import com.divillysausages.gameobjeditor.Editor;

	public class IngameState extends FlxState
	{
		//internal var llama:FlxSprite;
		
		[Embed(source="../gfx/map.png")] private var Background:Class;	//Graphic of the player's ship
		
		private var _editor:Editor;
		public var llama:Llama;			//Refers to the little player llama
		
		override public function create():void
		{
			_editor = new Editor(FlxG.stage);
			_editor.registerClass(Llama);
			_editor.visible = true;
			FlxG.mouse.show();
			
			var bg:FlxSprite = new FlxSprite(0,0);			
			bg.loadGraphic(Background);
			add(bg);
			
			trace("alsk");
			//Initialize the llama and add it to the layer
			llama = new Llama();
			_editor.registerObject(llama);
			add(llama);
		}
		
		override public function update():void
		{
			super.update();
			
			if (llama.acceleration.y == llama.jumpUpAcceleration) {
				llama.acceleration.y = 200;
			}
			if (llama.y > 350) {
				llama.acceleration.y = llama.jumpUpAcceleration;
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
	}
}
