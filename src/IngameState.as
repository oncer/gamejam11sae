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
		
		[Embed(source="../gfx/map.png")] private var BackgroundImage:Class; // Fullscreen bg
		[Embed(source="../gfx/cage.png")] private var CageImage:Class;
		
		private var _editor:Editor;
		public var llama:Llama;  //Refers to the little player llama
		public var cage:FlxSprite;
		private var visitors:FlxGroup;
		private var spits:FlxGroup;
		
		private var difficulty:Number;
		private var elapsedTime:Number; // total in seconds
		private var lastSpawnTime:Number;
		private var lastVisitor:uint; // most recent array index
		private var lastSpit:uint; // most recent array index
		
		private var ambientPlayer:AmbientPlayer;
		
		override public function create():void
		{
			_editor = new Editor(FlxG.stage);
			_editor.registerClass(FlxObject);
			_editor.registerClass(FlxSprite);
			_editor.registerClass(Llama);
			_editor.visible = true;
			FlxG.mouse.show();
			
			var bg:FlxSprite = new FlxSprite(0,0);
			bg.loadGraphic(BackgroundImage);
			add(bg);
			
			trace("IngameState.onCreate()");
			
			difficulty = Globals.INIT_DIFFICULTY;
			elapsedTime = 0.0;
			lastSpawnTime = elapsedTime;
			lastVisitor = 0;
			lastSpit = 0;
			
			var i:uint = 0;
			
			// Initialize llama
			llama = new Llama();
			_editor.registerObject(llama);
			add(llama);
			
			// Initialize cage
			cage = new FlxSprite (Globals.CAGE_LEFT, Globals.CAGE_TOP);
			cage.loadGraphic(CageImage);
			add(cage);
			
			// Initialize visitors
			visitors = new FlxGroup (Globals.MAX_VISITORS);
			for(i = 0; i < Globals.MAX_VISITORS; i++)
			{
				visitors.add(new Visitor());
			}
			add(visitors);

			// Initialize spits
			spits = new FlxGroup (Globals.MAX_SPITS);
			for(i = 0; i < Globals.MAX_SPITS; i++)
			{
				spits.add(new Spit(new FlxPoint(0,0)));
			}
			add(spits);
			
			ambientPlayer = new AmbientPlayer();
			ambientPlayer.start();
			add(ambientPlayer);
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
			
			if (llama.lama.x < cage.x) {
				llama.lama.x = cage.x;
				llama.lama.velocity.x = 0;
			}
			
			if (llama.lama.x + llama.lama.width > cage.x + cage.width) {
				llama.lama.x = cage.x + cage.width - llama.lama.width;
				llama.lama.velocity.x = 0;
			}
			
			// Visitors
			var spawnInterval:Number = 100.0 / (difficulty + 40.0);
			if (spawnInterval < 0.1) {
				spawnInterval = 0.1;
			}
			
			while (lastSpawnTime < elapsedTime) 
			{
				spawnVisitor ();
				lastSpawnTime += spawnInterval;
			}
			
			// Collision visitors vs. spit
			FlxG.overlap(visitors, spits, visitorsVsSpits, canSpitHit);
			
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
		
		public function spawnSpit(X:Number, Y:Number):Spit
		{
			var s:Spit = spits.members[lastSpit++ % Globals.MAX_SPITS];
			s.reset(X,Y);
			return s;
		}
		
		private function canSpitHit(visitor:FlxObject,spit:FlxObject):Boolean
		{
			return (spit as Spit).canHit(visitor as Visitor);
		}
		
		private function visitorsVsSpits(visitor:FlxObject,spit:FlxObject):void
		{
			var v:Visitor = visitor as Visitor;
			var s:Spit = spit as Spit;
			s.hitSomething();
			v.getSpitOn(s);
		}
	} // end of class IngameState
} // end of package
