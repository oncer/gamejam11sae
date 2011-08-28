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
		[Embed(source="../gfx/cage.png")] private var CageImage:Class;
		[Embed(source="../gfx/soundsettings.png")] private var SoundSettingsImage:Class;
		
		//private var _editor:Editor;
		
		private var bg:LevelBackground;
		public var llama:Llama;  //Refers to the little player llama
		public var cage:FlxSprite;
		public var trampolin:Trampolin;
		private var visitors:FlxGroup;
		private var spits:FlxGroup;
		private var helicopter:Helicopter;
		private var flyingVisitors:FlxGroup; // can hit normal visitors for combos
		private var scoretexts:FlxGroup;
		private var totalScoreText:TotalScoreText;
		private var statsText:StatsText;
		private var lifesDisplay:HealthBar;
		private var levelManager:LevelManager;
		private var newLevelText:NewLevelText;
		private var visitorIntroTexts:FlxGroup;
		
		private var musicButton:FlxButton;
		private var sfxButton:FlxButton;
		private var pauseButton:FlxButton;
		
		private var stats:Statistics;
		private var lifes:uint;         // 0 == game over
		private var difficulty:Number;
		public var elapsedTime:Number;  // total in seconds
		private var lastVisitor:uint;   // most recent array index
		private var lastSpit:uint;      // most recent array index
		private var lastScoreText:uint; // most recent array index
		private var statsDisplayCountdown:Number; 
		
		private var lastHelicopterSpawnedCounter:Number;
		/** after this time (in seconds), the helicopter is started either from left or right */
		private static const DURATION_RESPAWN_HELICOPTER:Number = 25;
		
		private var ambientPlayer:AmbientPlayer;
		private var gameover:Boolean;
		
		override public function create():void
		{
			super.create();
						
			gameover = false;
			
			/*trace("[loading editor] " + getTimer());
			_editor = new Editor(FlxG.stage);
			_editor.registerClass(FlxObject);
			_editor.registerClass(FlxSprite);
			_editor.registerClass(Llama);
			_editor.visible = true;
			FlxG.mouse.show();*/
			
			bg = new LevelBackground(LevelBackground.TIME_DAY);
			add(bg);
			
			lifes = Globals.MAX_LIFES;
			elapsedTime = 0.0;
			lastVisitor = 0;
			lastSpit = 0;
			lastScoreText = 0;
			lastHelicopterSpawnedCounter = 0;
			
			var i:uint = 0;
			
			// Initialize trampolin
			trampolin = new Trampolin();
			add(trampolin.bgSprite);
			
			// Initialize llama
			llama = new Llama(this);
			//_editor.registerObject(llama);
			add(llama);
			
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
			
			lifesDisplay = new HealthBar();
			add(lifesDisplay);
			
			// sounds
			ambientPlayer = new AmbientPlayer();
			ambientPlayer.start();
			ambientPlayer.volume = 0.0; // disable music
			add(ambientPlayer);
			Globals.sfxPlayer = new SfxPlayer();
			Globals.sfxPlayer.volume = 0.0; // disable sfx
			add(Globals.sfxPlayer);
			
			// buttons
			var x:uint = 8, y:uint = FlxG.height - 40;
			pauseButton = new FlxButton(x, y);
			pauseButton.loadGraphic(SoundSettingsImage, false, false, 32, 32);
			pauseButton.onUp = pauseButtonPressed;
			pauseButton.on = false;
			add(pauseButton);
			x += 36;
			musicButton = new FlxButton(x, y);
			musicButton.loadGraphic(SoundSettingsImage, false, false, 32, 32);
			musicButton.onUp = musicButtonPressed;
			musicButton.on = (ambientPlayer.volume > 0);
			add(musicButton);
			x += 36;
			sfxButton = new FlxButton(x, y);
			sfxButton.loadGraphic(SoundSettingsImage, false, false, 32, 32);
			sfxButton.onUp = sfxButtonPressed;
			sfxButton.on = (Globals.sfxPlayer.volume > 0);
			add(sfxButton);
			
			
			// level manager determines current level, difficulty etc.
			levelManager = new LevelManager();
			add(levelManager);
			
			newLevelText = new NewLevelText();
			add(newLevelText);
			newLevelText.displayText(levelManager.getLevelNr()); // Level 1
			newLevelText.setDisappearHandler(this.showLevelIntro);
		}
		
		/**
		 * call this somewhere in update() to fix default FlxButton behaviour
		 */
		private function fixButtonFrames():void
		{
			if (!pauseButton.on && FlxG.paused) {
				pauseButton.on = true; // game paused by lost focus
			}
			if (pauseButton.on) {
				pauseButton.frame = 4;
			} else {
				pauseButton.frame = 5;
			}
			if (musicButton.on) {
				musicButton.frame = 0;
			} else {
				musicButton.frame = 1;
			}
			if (sfxButton.on) {
				sfxButton.frame = 2;
			} else {
				sfxButton.frame = 3;
			}
		}
		
		private function pauseButtonPressed():void
		{
			pauseButton.on = !pauseButton.on;
			if (pauseButton.on) {
				FlxG.paused = true;
			} else {
				FlxG.paused = false;
			}
		}
		
		private function musicButtonPressed():void
		{
			musicButton.on = !musicButton.on;
			if (musicButton.on) {
				ambientPlayer.volume = 1.0;
			} else {
				ambientPlayer.volume = 0.0;
			}
		}
		
		private function sfxButtonPressed():void
		{
			sfxButton.on = !sfxButton.on;
			if (sfxButton.on) {
				Globals.sfxPlayer.volume = 1.0;
			} else {
				Globals.sfxPlayer.volume = 0.0;
			}
		}
		
		private function isLevelCompletelyOver():Boolean
		{
			return levelManager.isLevelElapsed() &&
			       (visitors.countLiving() <= 0) &&
			       helicopter.isEverythingOut();
		}
		
		private function showLevelIntro():void
		{
			visitorIntroTexts.clear();

			var levelIntros:Vector.<int> = levelManager.getLevelIntroductions();
			for (var i:int = 0; i < levelIntros.length; i++)
			{
				visitorIntroTexts.add(new VisitorIntroText(levelIntros[i], i));
			}
		}
		
		private function startDisplayingStatistics():void
		{
			bg.startShift();
			statsText.playback(stats.getLevelNr());
			helicopter.active = false;
			llama.disableSpit();
		}
		
		private function stopDisplayingStatistics():void
		{
			bg.startShift();
			levelManager.gotoNextLevel ();
			stats.countLevel ();
			newLevelText.displayText(levelManager.getLevelNr());
			statsText.finishPlayback ();
			helicopter.active = true;
			llama.enableSpit();
		}
		
		override public function update():void
		{
			if (FlxG.paused) {
				pauseButton.update();
				musicButton.update();
				sfxButton.update();
				ambientPlayer.update();
				Globals.sfxPlayer.update();
				fixButtonFrames();
				return;
			}
			
			super.update();
			
			stats.update();
			
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
			
			/*if (trampolin.y < Globals.TRAMPOLIN_TOP) {
				trampolin.y = Globals.TRAMPOLIN_TOP;
				trampolin.velocity.y = 0;
			}*/
			
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
			FlxG.overlap(visitors, spits, visitorsVsSpits, canSpitAndVisitorHit);
			FlxG.overlap(visitors, flyingVisitors, visitorsVsFlying, canFlyingHit);
			FlxG.overlap(helicopter.getUpgradeSprite(), spits, upgradeVsSpits, canSpitAndUpgradeHit);
			
			// Continually remove some from flying array if possible
			var trash:FlxBasic = flyingVisitors.getFirstAvailable();
			if (trash) flyingVisitors.remove(trash);
			
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
			
			fixButtonFrames();
		} // end of update

		override public function draw():void
		{
			var __start__:int = flash.utils.getTimer();
			super.draw();
			Profiler.profiler.profile('IngameState.draw', flash.utils.getTimer() - __start__);
		}
		
		private function getUnusedVisitor():Visitor
		{
			return visitors.members[(lastVisitor++) % Globals.MAX_VISITORS];
		}
		
		/**
		 * parent: shares a hit counter with the spawned spit such that
		 *         hits are counted only once.
		 */
		public function spawnSpit(TYPE:int, X:Number, Y:Number, parent:Spit = null, isCombo:Boolean = false):Spit
		{
			var s:Spit = spits.members[lastSpit++ % Globals.MAX_SPITS];
			
			if (parent === null)
			{
				stats.countSpit();
				s.resetCreate (TYPE, X, Y, stats.countHit);
			}
			else
			{
				s.resetAsChild (TYPE, X, Y, parent);
				if (isCombo)
				{
					s.setCombo(2);
				}
			}
			
			return s;
		}
		
		public function spawnScoreText(X:Number, Y:Number, MULTIPLIER:int, SCORE:int):ScoreText
		{
			var s:ScoreText = scoretexts.members[lastScoreText++ % Globals.MAX_SCORETEXTS];
			s.init(X,Y,MULTIPLIER,SCORE);
			return s;
		}
		
		private function canSpitAndUpgradeHit(visitor:FlxObject,spit:FlxObject):Boolean
		{
			return (spit as Spit).canHit() && helicopter.canUpgradeHit();
		}
			
		private function canSpitAndVisitorHit(visitor:FlxObject,spit:FlxObject):Boolean
		{
			var v:Visitor = visitor as Visitor;
			return v.canBeHit() && (spit as Spit).canHit();
		}
		
		private function upgradeVsSpits(upgrade:FlxObject,spit:FlxObject):void
		{	
			// there is only 1 upgrade, so the 1st argument is never needed - this is only called if a collision with the upgrade occured			
			var s:Spit = spit as Spit;
			s.hitSomething();
			// +1, because 0 is the upgradetype_none - this is dependent on the animations in the picture; be aware of that!
			
			helicopter.upgradeHit(spit);
		}
		
		private function visitorsVsSpits(victim:FlxObject,spit:FlxObject):void
		{
			var v:Visitor = victim as Visitor;
			var s:Spit = spit as Spit;
			s.hitSomething();
			v.getSpitOn(s);
			flyingVisitors.add(v);
			trace("flyingVisitors count: " + flyingVisitors.length);
			
			Globals.sfxPlayer.Splotsh();
		}
		
		private function canFlyingHit(victim:FlxObject,flying:FlxObject):Boolean
		{
			return (flying as Visitor).canHitSomeone() && (victim as Visitor).canBeHit();
		}
		
		private function visitorsVsFlying(victim:FlxObject,flying:FlxObject):void
		{
			var v:Visitor = victim as Visitor;
			var f:Visitor = flying as Visitor;
			
			Globals.sfxPlayer.Splotsh();
			
			v.getHitByPerson(f);
		}
		
		public function causeScore (killed:Visitor, score:int, combo:int):void
		{
			stats.countKill(killed, score, combo);
			
			// total score display (top right)
			totalScoreText.score = stats.getTotalScore();
			
			// temporary points display everywhere
			spawnScoreText(killed.x + killed.width / 2, killed.y, combo, killed.scorePoints);
		}
		
		public function setUpgrade():void
		{
			var upgradeType:uint = helicopter.getUpgradeType();
			llama.setUpgradeType(upgradeType);
			stats.countUpgrade (upgradeType);
		}
		
		public function loseLife ():void
		{
			if (lifes > 0)
			{
				lifes--;
				lifesDisplay.value = (lifes as Number) / (Globals.MAX_LIFES as Number);
			}
			
			if (lifes <= 0 && !gameover)
			{
				Globals.sfxPlayer.Gameover();
				FlxG.fade(0xff000000, 2, gameOverFunction);
				gameover = true;
			}
		}
		
		private function gameOverFunction():void
		{
			trace(Profiler.profiler.stats);
			ambientPlayer.stop();
			FlxG.score = stats.getTotalScore(); // GameoverState picks score from there
			FlxG.switchState(new GameoverState());
		}
	
		/**
		 * Needs to be public, because also gets called from Spit when a MULTI_SPAWN spit hits the ground.
		 * @param	collidingSpit
		 */		
		public function spawnMultipleNewSpitsAtSpitPosition(collidingSpit:Spit, isCombo:Boolean):void {
			var speed:Number = 200;
			var y_threshold:Number = 10;
			var newSpit:Spit = spawnSpit(Spit.TYPE_DEFAULT, collidingSpit.x, collidingSpit.y - y_threshold, collidingSpit, isCombo);
			// 3rd parameter is the same like in Llama.spitStrengthModifier
			// angle 0 is to the right, 180 to the left, 270 up
			newSpit.velocity = FlxVelocity.velocityFromAngle(0, speed);
			
			newSpit = spawnSpit(Spit.TYPE_DEFAULT, collidingSpit.x, collidingSpit.y - y_threshold, collidingSpit, isCombo);
			newSpit.velocity = FlxVelocity.velocityFromAngle(180, speed);
			
			newSpit = spawnSpit(Spit.TYPE_DEFAULT, collidingSpit.x, collidingSpit.y - y_threshold, collidingSpit, isCombo);
			newSpit.velocity = FlxVelocity.velocityFromAngle(270-30, speed);
			
			newSpit = spawnSpit(Spit.TYPE_DEFAULT, collidingSpit.x, collidingSpit.y - y_threshold, collidingSpit, isCombo);
			newSpit.velocity = FlxVelocity.velocityFromAngle(270+30, speed);
		}
	} // end of class IngameState
} // end of package
