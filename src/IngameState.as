/*
 * IngameState
 * In diesem State findet das eigentliche Game statt.
 * Hüpfendes Llama, aggressive Besucher, Action etc.
 */

package
{
	import org.flixel.*;
	import flash.system.fscommand;
	//import com.divillysausages.gameobjeditor.Editor;
	import flash.utils.getTimer;

	public class IngameState extends FlxState
	{
		//internal var llama:FlxSprite;
		
		[Embed(source="../gfx/map.png")] private var BackgroundImage:Class; // Fullscreen bg
		[Embed(source="../gfx/cage.png")] private var CageImage:Class;
		[Embed(source="../gfx/life.png")] private var LifeImage:Class;
		
		//private var _editor:Editor;
		public var llama:Llama;  //Refers to the little player llama
		public var cage:FlxSprite;
		private var visitors:FlxGroup;
		private var spits:FlxGroup;
		private var flyingVisitors:FlxGroup; // can hit normal visitors for combos
		private var scoretexts:FlxGroup;
		private var scoreText:FlxText; // can hit normal visitors for combos
		private var livesDisplay:FlxGroup; // contains 3 llama heads
		
		private var lives:uint; // 0 == game over
		private var difficulty:Number;
		public var elapsedTime:Number; // total in seconds
		private var lastSpawnTime:Number;
		private var lastVisitor:uint; // most recent array index
		private var lastSpit:uint; // most recent array index
		private var lastScoreText:uint; // most recent array index
		
		private var ambientPlayer:AmbientPlayer;
		
		override public function create():void
		{
			/*trace("[loading editor] " + getTimer());
			_editor = new Editor(FlxG.stage);
			_editor.registerClass(FlxObject);
			_editor.registerClass(FlxSprite);
			_editor.registerClass(Llama);
			_editor.visible = true;
			FlxG.mouse.show();*/
			FlxG.mouse.hide();
			
			var bg:FlxSprite = new FlxSprite(0,0);
			bg.loadGraphic(BackgroundImage);
			add(bg);
			
			FlxG.score = 0;
			
			lives = 10;
			difficulty = Globals.INIT_DIFFICULTY;
			elapsedTime = 0.0;
			lastSpawnTime = elapsedTime;
			lastVisitor = 0;
			lastSpit = 0;
			lastScoreText = 0;
			
			var i:uint = 0;
			
			// Initialize llama
			llama = new Llama();
			//_editor.registerObject(llama);
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
			
			// Initialize score
			scoretexts = new FlxGroup (Globals.MAX_SCORETEXTS);
			for(i = 0; i < Globals.MAX_SCORETEXTS; i++)
			{
				scoretexts.add(new ScoreText());
			}
			add(scoretexts);

			// score display
			scoreText = new FlxText (FlxG.width-200, 15, 180, "SCORE", true);
			scoreText.alignment = "right";
			add(scoreText);
			
			// Flying visitors group
			flyingVisitors = new FlxGroup (Globals.MAX_FLYERS);
			
			livesDisplay = new FlxGroup (lives);
			for(i = 0; i < Globals.MAX_SPITS; i++)
			{
				var life:FlxSprite = new FlxSprite (10 + i * 40, 10);
				life.loadGraphic(LifeImage);
				livesDisplay.add(life);
			}
			add(livesDisplay);
			
			// sounds
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
			
			if (llama.lama.x < cage.x + 10) {
				llama.lama.x = cage.x + 10;
				llama.lama.velocity.x = 0;
			}
			
			if (llama.lama.x + llama.lama.width > cage.x + cage.width - 10) {
				llama.lama.x = cage.x + cage.width - llama.lama.width - 10;
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
			
			// Collision visitors vs. spit, visitors vs flying
			FlxG.overlap(visitors, spits, visitorsVsSpits, canSpitHit);
			FlxG.overlap(visitors, flyingVisitors, visitorsVsFlying, canFlyingHit);
			
			// Continually remove some from flying array if possible
			var trash:FlxBasic = flyingVisitors.getFirstAvailable();
			if (trash) flyingVisitors.remove(trash);
			
			//FlxG.log(llama.y);
			//trace("test");
			//trace("lama y: " + llama.lama.y);
			
			// for testing the different upgrades
			if (FlxG.keys.ONE) {				
				llama.setUpgradeType(Llama.UPGRADE_NONE);
			} else if (FlxG.keys.TWO) {
				llama.setUpgradeType(Llama.UPGRADE_RAPIDFIRE);
			} else if (FlxG.keys.THREE) {
				llama.setUpgradeType(Llama.UPGRADE_BIGSPIT);
			} else if (FlxG.keys.FOUR) {
				llama.setUpgradeType(Llama.UPGRADE_MULTISPAWN);
			} 
						
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
		
		public function spawnScoreText(X:Number, Y:Number, MULTIPLIER:int, SCORE:int):ScoreText
		{
			var s:ScoreText = scoretexts.members[lastScoreText++ % Globals.MAX_SCORETEXTS];
			s.init(X,Y,MULTIPLIER,SCORE);
			return s;
		}
		
		private function canSpitHit(visitor:FlxObject,spit:FlxObject):Boolean
		{
			var v:Visitor = visitor as Visitor;
			return v.canBeHit() && (spit as Spit).canHit(v);
		}
		
		private function visitorsVsSpits(victim:FlxObject,spit:FlxObject):void
		{
			var v:Visitor = victim as Visitor;
			var s:Spit = spit as Spit;
			s.hitSomething();
			v.getSpitOn(s);
			flyingVisitors.add(v);
			addScore(v.scorePoints);
			spawnScoreText(v.x + v.width/2, v.y, 1, v.scorePoints);
		}
		
		private function canFlyingHit(victim:FlxObject,flying:FlxObject):Boolean
		{ 
			return (flying as Visitor).canHitSomeone() && (victim as Visitor).canBeHit();
		}
		
		private function visitorsVsFlying(victim:FlxObject,flying:FlxObject):void
		{
			var v:Visitor = victim as Visitor;
			var f:Visitor = flying as Visitor;
			
			v.getHitByPerson(f);
			addScore(v.scorePoints * v.comboCounter);
			doCombo(v.comboCounter);
			spawnScoreText(v.x + v.width/2, v.y, v.comboCounter, v.scorePoints);
		}
		
		private function addScore (score:int):void
		{
			FlxG.score += score;
			scoreText.text = FlxG.score.toString();
		}
		
		private function doCombo (counter:uint):void
		{
		}
		
		public function loseLife ():void
		{
			lives--;
			livesDisplay.length = lives;
			if (lives <= 0)
			{
				FlxG.switchState(new GameoverState());
			}
		}
	} // end of class IngameState
} // end of package
