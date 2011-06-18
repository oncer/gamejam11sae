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
		
		public static const MAX_VISITORS:uint = 1024;
		
		private var _editor:Editor;
		public var llama:Llama;			//Refers to the little player llama
		private var visitors:FlxGroup;
		
		private var difficulty:Number;
		private var elapsedTime:Number; // total in seconds
		private var lastSpawnTime:uint;
		
		override public function create():void
		{
			_editor = new Editor(FlxG.stage);
			_editor.registerClass(FlxObject);
			_editor.registerClass(FlxSprite);
			_editor.registerClass(Llama);
			_editor.visible = true;
			FlxG.mouse.show();
			
			var bg:FlxSprite = new FlxSprite(0,0);			
			bg.loadGraphic(Background);
			add(bg);
			
			trace("IngameState.onCreate()");
			
			difficulty = 1.0;
			elapsedTime = 0.0;
			lastSpawnTime = elapsedTime;
			
			// Initialize llama
			llama = new Llama();
			_editor.registerObject(llama);
			add(llama);
			
			// Initialize visitors
			visitors = new FlxGroup (MAX_VISITORS);
			add(visitors);
			
			/*var target:FlxPoint = new FlxPoint(110, 100);
			var pivot:FlxPoint = new FlxPoint(100, 100);
			//var rotatedPoint:FlxPoint = FlxU.rotatePoint(target.x, target.y, pivot.x, pivot.y, 0);
			var rotatedPoint:FlxPoint = rotatePoint(target.x, target.y, pivot.x, pivot.y, 180);
			trace("x: " + rotatedPoint.x + " y: " + rotatedPoint.y);*/
		}
		
		
		
		override public function update():void
		{
			// update time
			elapsedTime += FlxG.elapsed;
			
			super.update();
			
			if (llama.lama.y > 350) {
				llama.lama.velocity.y = llama.jumpUpVelocity;
			}
			
			// Visitors
			var spawnInterval:uint = 10000.0 / (difficulty + 40.0);
			
			while (lastSpawnTime < elapsedTime) 
			{
				spawnVisitor ();
				lastSpawnTime += spawnInterval;
			}
			
			//FlxG.log(llama.y);
			//trace("test");
			//trace("lama y: " + llama.lama.y);
			
			// for faster debugging
			if (FlxG.keys.ESCAPE) {
				trace("quit");
				fscommand("quit");
			}
		} // end of update
		
		
		function spawnVisitor():void
		{
			visitors.add(new Visitor(difficulty));
		}
	} // end of class IngameState
} // end of package
