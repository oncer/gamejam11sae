/*
 * IngameState
 * In diesem State findet das eigentliche Game statt.
 * Hüpfendes Llama, aggressive Besucher, Action etc.
 */

package
{
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.*;
	import flash.system.fscommand;
	//import com.divillysausages.gameobjeditor.Editor;
	import flash.utils.getTimer;

	public class IngameState extends FlxState
	{
		//internal var llama:FlxSprite;
		
		//[Embed(source="../gfx/map.png")] private var BackgroundImage:Class; // Fullscreen bg
		[Embed(source="../gfx/cage.png")] private var CageImage:Class;
		[Embed(source="../gfx/trampolin.png")] private var TrampolinImage:Class;
		[Embed(source="../gfx/life.png")] private var LifeImage:Class;
		
		//private var _editor:Editor;
		
		private var bg:LevelBackground;
		public var llama:Llama;  //Refers to the little player llama
		public var cage:FlxSprite;
		public var trampolin:FlxSprite;
		private var visitors:FlxGroup;
		private var spits:FlxGroup;
		private var helicopter:Helicopter;
		private var flyingVisitors:FlxGroup; // can hit normal visitors for combos
		private var scoretexts:FlxGroup;
		private var totalScoreText:TotalScoreText;
		private var statsText:StatsText;
		private var livesDisplay:FlxGroup; // contains 3 llama heads
		private var levelManager:LevelManager;
		private var newLevelText:NewLevelText;
		private var visitorIntroTexts:FlxGroup;
		
		private var stats:Statistics;
		private var lives:uint;         // 0 == game over
		private var difficulty:Number;
		public var elapsedTime:Number;  // total in seconds
		private var lastVisitor:uint;   // most recent array index
		private var lastSpit:uint;      // most recent array index
		private var lastScoreText:uint; // most recent array index
		private var statsDisplayCountdown:Number; 
		
		private var lastHelicopterSpawnedCounter:Number;
		/** after this time (in seconds), the helicopter is started either from left or right */
		private var DURATION_RESPAWN_HELICOPTER:Number = 25;
		
		private var ambientPlayer:AmbientPlayer;
		private var gameover:Boolean;
		
		override public function create():void
		{
var __start__:int = flash.utils.getTimer();
			super.create();
						
			gameover = false;
			
			/*trace("[loading editor] " + getTimer());
			_editor = new Editor(FlxG.stage);
			_editor.registerClass(FlxObject);
			_editor.registerClass(FlxSprite);
			_editor.registerClass(Llama);
			_editor.visible = true;
			FlxG.mouse.show();*/
			FlxG.mouse.hide();
			
			bg = new LevelBackground(LevelBackground.TIME_DAY);
			add(bg);
			
			lives = 3;
			elapsedTime = 0.0;
			lastVisitor = 0;
			lastSpit = 0;
			lastScoreText = 0;
			lastHelicopterSpawnedCounter = 0;
			
			var i:uint = 0;
			
			// Initialize llama
			llama = new Llama(this);
			//_editor.registerObject(llama);
			add(llama);
			
			// Initialize trampolin
			trampolin = new FlxSprite (Globals.CAGE_LEFT, Globals.TRAMPOLIN_TOP);
			trampolin.loadGraphic(TrampolinImage);
			add(trampolin);

			helicopter = new Helicopter(this);
			add(helicopter);
			
			// Initialize visitors
			visitors = new FlxGroup (Globals.MAX_VISITORS);
			for(i = 0; i < Globals.MAX_VISITORS; i++)
			{
				visitors.add(new Visitor());
			}
			add(visitors);
			
			// Initialize cage
			cage = new FlxSprite (Globals.CAGE_LEFT, Globals.CAGE_TOP);
			cage.loadGraphic(CageImage);
			add(cage);

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
			
			// Initialize stats
			stats = new Statistics ();

			// total score display
			totalScoreText = new TotalScoreText();
			add(totalScoreText);
			
			// stats display (between levels)
			statsText = new StatsText(stats);
			add(statsText);
			
			// introductory texts for visitors
			visitorIntroTexts = new FlxGroup();
			add(visitorIntroTexts);
			
			// Flying visitors group
			flyingVisitors = new FlxGroup (Globals.MAX_FLYERS);
			
			livesDisplay = new FlxGroup (lives);
			for(i = 0; i < lives; i++)
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
			Globals.sfxPlayer = new SfxPlayer();
			add(Globals.sfxPlayer);
			
			// level manager determines current level, difficulty etc.
			levelManager = new LevelManager();
			add(levelManager);
			
			newLevelText = new NewLevelText();
			add(newLevelText);
			newLevelText.displayText(levelManager.getLevelNr()); // Level 1
			newLevelText.setDisappearHandler(this.showLevelIntro);
		Profiler.profiler.profile('IngameState.create', flash.utils.getTimer() - __start__);
}
		
		private function isLevelCompletelyOver():Boolean
		{
var __start__:int = flash.utils.getTimer();
			{ var __ret1__:* = levelManager.isLevelElapsed() &&
			       (visitors.countLiving() <= 0) &&
			       helicopter.isEverythingOut();
Profiler.profiler.profile('IngameState.isLevelCompletelyOver', flash.utils.getTimer() - __start__); return __ret1__; }
		Profiler.profiler.profile('IngameState.isLevelCompletelyOver', flash.utils.getTimer() - __start__);
}
		
		private function showLevelIntro():void
		{
var __start__:int = flash.utils.getTimer();
			visitorIntroTexts.clear();

			var levelIntros:Vector.<int> = levelManager.getLevelIntroductions();
			for (var i:int = 0; i < levelIntros.length; i++)
			{
				visitorIntroTexts.add(new VisitorIntroText(levelIntros[i], i));
			}
		Profiler.profiler.profile('IngameState.showLevelIntro', flash.utils.getTimer() - __start__);
}
		
		private function startDisplayingStatistics():void
		{
var __start__:int = flash.utils.getTimer();
			bg.startShift();
			statsText.playback(stats.getLevelNr());
			helicopter.active = false;
			llama.disableSpit();
		Profiler.profiler.profile('IngameState.startDisplayingStatistics', flash.utils.getTimer() - __start__);
}
		
		private function stopDisplayingStatistics():void
		{
var __start__:int = flash.utils.getTimer();
			bg.startShift();
			levelManager.gotoNextLevel ();
			stats.countLevel ();
			newLevelText.displayText(levelManager.getLevelNr());
			statsText.finishPlayback ();
			helicopter.active = true;
			llama.enableSpit();
		Profiler.profiler.profile('IngameState.stopDisplayingStatistics', flash.utils.getTimer() - __start__);
}
		
		override public function update():void
		{
var __start__:int = flash.utils.getTimer();

			var tm:int = flash.utils.getTimer();
			super.update();
			Profiler.profiler.profile('IngameState.update__super.update', flash.utils.getTimer() - tm);
			
			tm = flash.utils.getTimer();
			stats.update();
			Profiler.profiler.profile('IngameState.update__stats.update', flash.utils.getTimer() - tm);
			
			if (isLevelCompletelyOver())
			{
				if (statsText.canStartPlayback())
				{
					startDisplayingStatistics();
				} else
				if (statsText.canFinishPlayback())
				{
					stopDisplayingStatistics();
				}
			}
			else
			{
				lastHelicopterSpawnedCounter += FlxG.elapsed;
				if (lastHelicopterSpawnedCounter > DURATION_RESPAWN_HELICOPTER) {
					helicopter.startHelicopter();
					lastHelicopterSpawnedCounter = 0;
				}
			}
		
			// update time & difficulty
			// elapsedTime = SECONDS
			// difficulty = 1.0 + 0.3 * SECONDS
			elapsedTime += FlxG.elapsed;
			difficulty = levelManager.getDifficulty ();
			
			if (trampolin.y < Globals.TRAMPOLIN_TOP) {
				trampolin.y = Globals.TRAMPOLIN_TOP;
				trampolin.velocity.y = 0;
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
			levelManager.doSpawns(this.getUnusedVisitor);
			
			// Collision visitors vs. spit, visitors vs flying
			tm = flash.utils.getTimer();
			FlxG.overlap(visitors, spits, visitorsVsSpits, canSpitAndVisitorHit);
			Profiler.profiler.profile('IngameState.update__overlap(visitors,spits)', flash.utils.getTimer() - tm);
			tm = flash.utils.getTimer();
			FlxG.overlap(visitors, flyingVisitors, visitorsVsFlying, canFlyingHit);
			Profiler.profiler.profile('IngameState.update__overlap(visitors,flyingVisitors)', flash.utils.getTimer() - tm);
			tm = flash.utils.getTimer();
			FlxG.overlap(helicopter.getUpgradeSprite(), spits, upgradeVsSpits, canSpitAndUpgradeHit);
			Profiler.profiler.profile('IngameState.update__overlap(helicopter,spits)', flash.utils.getTimer() - tm);
			
			// Continually remove some from flying array if possible
			tm = flash.utils.getTimer();
			var trash:FlxBasic = flyingVisitors.getFirstAvailable();
			if (trash) flyingVisitors.remove(trash);
			Profiler.profiler.profile('IngameState.update__flyingVisitors_trash', flash.utils.getTimer() - tm);
			
			//FlxG.log(llama.y);
			//trace("test");
			//trace("lama y: " + llama.lama.y);
			
			// for testing the different upgrades
			/*if (FlxG.keys.ONE) {				
				llama.setUpgradeType(Llama.UPGRADE_NONE);
			} else if (FlxG.keys.TWO) {
				llama.setUpgradeType(Llama.UPGRADE_RAPIDFIRE);
			} else if (FlxG.keys.THREE) {
				llama.setUpgradeType(Llama.UPGRADE_BIGSPIT);
			} else if (FlxG.keys.FOUR) {
				llama.setUpgradeType(Llama.UPGRADE_MULTISPAWN);
			}*/
						
			// for faster debugging
			if (FlxG.keys.ESCAPE) {
				
				// create a new gameoverState every time... better would be to initialize it, and only create it once
				FlxG.fade(0xff000000, 1, gameOverFunction);
				
				// do not quit here
				//trace("quit");
				//fscommand("quit");
			}
			
			var currentLevel:int = stats.getLevelNr();
			var max_combos:int = stats.getLevelMaxCombo(currentLevel);
		Profiler.profiler.profile('IngameState.update', flash.utils.getTimer() - __start__);
} // end of update

		override public function draw():void
		{
			var __start__:int = flash.utils.getTimer();
			super.draw();
			Profiler.profiler.profile('IngameState.draw', flash.utils.getTimer() - __start__);
		}
		
		private function getUnusedVisitor():Visitor
		{
var __start__:int = flash.utils.getTimer();
			{ var __ret2__:* = visitors.members[(lastVisitor++) % Globals.MAX_VISITORS];
Profiler.profiler.profile('IngameState.getUnusedVisitor', flash.utils.getTimer() - __start__); return __ret2__; }
		Profiler.profiler.profile('IngameState.getUnusedVisitor', flash.utils.getTimer() - __start__);
}
		
		/**
		 * parent: shares a hit counter with the spawned spit such that
		 *         hits are counted only once.
		 */
		public function spawnSpit(X:Number, Y:Number, parent:Spit = null, isCombo:Boolean = false):Spit
		{
var __start__:int = flash.utils.getTimer();
			var s:Spit = spits.members[lastSpit++ % Globals.MAX_SPITS];
			
			if (parent === null)
			{
				stats.countSpit();
				s.resetCreate (X, Y, stats.countHit);
			}
			else
			{
				s.resetAsChild (X, Y, parent);
				if (isCombo)
				{
					s.setCombo(2);
				}
			}
			
			{ var __ret3__:* = s;
Profiler.profiler.profile('IngameState.spawnSpit', flash.utils.getTimer() - __start__); return __ret3__; }
		Profiler.profiler.profile('IngameState.spawnSpit', flash.utils.getTimer() - __start__);
}
		
		public function spawnScoreText(X:Number, Y:Number, MULTIPLIER:int, SCORE:int):ScoreText
		{
var __start__:int = flash.utils.getTimer();
			var s:ScoreText = scoretexts.members[lastScoreText++ % Globals.MAX_SCORETEXTS];
			s.init(X,Y,MULTIPLIER,SCORE);
			{ var __ret4__:* = s;
Profiler.profiler.profile('IngameState.spawnScoreText', flash.utils.getTimer() - __start__); return __ret4__; }
		Profiler.profiler.profile('IngameState.spawnScoreText', flash.utils.getTimer() - __start__);
}
		
		private function canSpitAndUpgradeHit(visitor:FlxObject,spit:FlxObject):Boolean
		{
var __start__:int = flash.utils.getTimer();
			{ var __ret5__:* = (spit as Spit).canHit() && helicopter.canUpgradeHit();
Profiler.profiler.profile('IngameState.canSpitAndUpgradeHit', flash.utils.getTimer() - __start__); return __ret5__; }
		Profiler.profiler.profile('IngameState.canSpitAndUpgradeHit', flash.utils.getTimer() - __start__);
}
			
		private function canSpitAndVisitorHit(visitor:FlxObject,spit:FlxObject):Boolean
		{
var __start__:int = flash.utils.getTimer();
			var v:Visitor = visitor as Visitor;
			{ var __ret6__:* = v.canBeHit() && (spit as Spit).canHit();
Profiler.profiler.profile('IngameState.canSpitAndVisitorHit', flash.utils.getTimer() - __start__); return __ret6__; }
		Profiler.profiler.profile('IngameState.canSpitAndVisitorHit', flash.utils.getTimer() - __start__);
}
		
		private function upgradeVsSpits(upgrade:FlxObject,spit:FlxObject):void
		{
var __start__:int = flash.utils.getTimer();			
			// there is only 1 upgrade, so the 1st argument is never needed - this is only called if a collision with the upgrade occured			
			var s:Spit = spit as Spit;
			s.hitSomething();
			// +1, because 0 is the upgradetype_none - this is dependent on the animations in the picture; be aware of that!
			
			helicopter.upgradeHit(spit);
		Profiler.profiler.profile('IngameState.upgradeVsSpits', flash.utils.getTimer() - __start__);
}
		
		private function visitorsVsSpits(victim:FlxObject,spit:FlxObject):void
		{
var __start__:int = flash.utils.getTimer();
			var v:Visitor = victim as Visitor;
			var s:Spit = spit as Spit;
			s.hitSomething();
			v.getSpitOn(s);
			flyingVisitors.add(v);
			trace("flyingVisitors count: " + flyingVisitors.length);
			
			Globals.sfxPlayer.Splotsh();
		Profiler.profiler.profile('IngameState.visitorsVsSpits', flash.utils.getTimer() - __start__);
}
		
		private function canFlyingHit(victim:FlxObject,flying:FlxObject):Boolean
		{
var __start__:int = flash.utils.getTimer(); 
			{ var __ret7__:* = (flying as Visitor).canHitSomeone() && (victim as Visitor).canBeHit();
Profiler.profiler.profile('IngameState.canFlyingHit', flash.utils.getTimer() - __start__); return __ret7__; }
		Profiler.profiler.profile('IngameState.canFlyingHit', flash.utils.getTimer() - __start__);
}
		
		private function visitorsVsFlying(victim:FlxObject,flying:FlxObject):void
		{
var __start__:int = flash.utils.getTimer();
			var v:Visitor = victim as Visitor;
			var f:Visitor = flying as Visitor;
			
			Globals.sfxPlayer.Splotsh();
			
			v.getHitByPerson(f);
		Profiler.profiler.profile('IngameState.visitorsVsFlying', flash.utils.getTimer() - __start__);
}
		
		public function causeScore (killed:Visitor, score:int, combo:int):void
		{
var __start__:int = flash.utils.getTimer();
			stats.countKill(killed, score, combo);
			
			// total score display (top right)
			totalScoreText.setText(stats.getTotalScore(), combo * 2.1);
			
			// temporary points display everywhere
			spawnScoreText(killed.x + killed.width / 2, killed.y, combo, killed.scorePoints);
		Profiler.profiler.profile('IngameState.causeScore', flash.utils.getTimer() - __start__);
}
		
		public function setUpgrade():void
		{
var __start__:int = flash.utils.getTimer();
			var upgradeType:uint = helicopter.getUpgradeType();
			llama.setUpgradeType(upgradeType + 1);
			stats.countUpgrade (upgradeType);
		Profiler.profiler.profile('IngameState.setUpgrade', flash.utils.getTimer() - __start__);
}
		
		public function loseLife ():void
		{
var __start__:int = flash.utils.getTimer();
			if (lives > 0)
			{
				lives--;
				livesDisplay.length = lives;
			}
			
			if (lives <= 0 && !gameover)
			{
				Globals.sfxPlayer.Gameover();
				FlxG.fade(0xff000000, 2, gameOverFunction);
				gameover = true;
			}
		Profiler.profiler.profile('IngameState.loseLife', flash.utils.getTimer() - __start__);
}
		
		private function gameOverFunction():void
		{
var __start__:int = flash.utils.getTimer();
			trace(Profiler.profiler.stats);
			ambientPlayer.stop();
			FlxG.score = stats.getTotalScore(); // GameoverState picks score from there
			FlxG.switchState(new GameoverState());
		Profiler.profiler.profile('IngameState.gameOverFunction', flash.utils.getTimer() - __start__);
}
	
		/**
		 * Needs to be public, because also gets called from Spit when a MULTI_SPAWN spit hits the ground.
		 * @param	collidingSpit
		 */		
		public function spawnMultipleNewSpitsAtSpitPosition(collidingSpit:Spit, isCombo:Boolean):void {
var __start__:int = flash.utils.getTimer();
			var speed:Number = 200;
			var y_threshold:Number = 10;
			var newSpit:Spit = spawnSpit(collidingSpit.x, collidingSpit.y - y_threshold, collidingSpit, isCombo);
			// 3rd parameter is the same like in Llama.spitStrengthModifier
			// angle 0 is to the right, 180 to the left, 270 up
			newSpit.velocity = FlxVelocity.velocityFromAngle(0, speed);
			
			newSpit = spawnSpit(collidingSpit.x, collidingSpit.y - y_threshold, collidingSpit, isCombo);
			newSpit.velocity = FlxVelocity.velocityFromAngle(180, speed);
			
			newSpit = spawnSpit(collidingSpit.x, collidingSpit.y - y_threshold, collidingSpit, isCombo);
			newSpit.velocity = FlxVelocity.velocityFromAngle(270-30, speed);
			
			newSpit = spawnSpit(collidingSpit.x, collidingSpit.y - y_threshold, collidingSpit, isCombo);
			newSpit.velocity = FlxVelocity.velocityFromAngle(270+30, speed);
		Profiler.profiler.profile('IngameState.spawnMultipleNewSpitsAtSpitPosition', flash.utils.getTimer() - __start__);
}
	} // end of class IngameState
} // end of package
