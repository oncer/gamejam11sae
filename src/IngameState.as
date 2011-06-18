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
		public var llama:Llama;  //Refers to the little player llama
		private var visitors:FlxGroup;
		
		private var difficulty:Number;
		private var elapsedTime:Number; // total in seconds
		private var lastSpawnTime:uint;
		private var lastVisitor:uint; // most recent array index
		
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
			
			difficulty = Globals.INIT_DIFFICULTY;
			elapsedTime = 0.0;
			lastSpawnTime = elapsedTime;
			lastVisitor = 0;
			
			// Initialize llama
			llama = new Llama();
			_editor.registerObject(llama);
			add(llama);
			
			// Initialize visitors
			visitors = new FlxGroup (Globals.MAX_VISITORS);
			for(var i:uint = 0; i < Globals.MAX_VISITORS; i++)
			{
				visitors.add(new Visitor());
			}
			add(visitors);
		}
		
		
		
		override public function update():void
		{
			// update time & difficulty
			elapsedTime += FlxG.elapsed;
			difficulty = Globals.INIT_DIFFICULTY + elapsedTime * Globals.DIFFICULTY_PER_SECOND;
			
			super.update();
			
			if (llama.lama.y > 350) {
				llama.lama.velocity.y = llama.jumpUpVelocity;
			}
			
			// Visitors
			var spawnInterval:uint = 100.0 / (difficulty + 40.0);
			
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
		
		
		private function spawnVisitor():void
		{
			var v:Visitor = visitors.members[lastVisitor % Globals.MAX_VISITORS];
			
			if (v.exists) return; // keep on screen until dead
			
			lastVisitor++;
			
			// distribute left/right somewhat randomly, but avoid long streaks
			if (visitors.length % 6 == 0) 
			{
				v.init(difficulty, FlxObject.LEFT);
			} else
			if (visitors.length % 6 == 3) 
			{
				v.init(difficulty, FlxObject.RIGHT);
			} else
			{
				v.init(difficulty);
			}
			
			v.revive();
		}
	} // end of class IngameState
} // end of package
