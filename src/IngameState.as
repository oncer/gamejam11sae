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
		[Embed(source="../gfx/trampolin.png")] private var TrampolinImage:Class;
		[Embed(source="../gfx/life.png")] private var LifeImage:Class;
		
		//private var _editor:Editor;
		public var llama:Llama;  //Refers to the little player llama
		public var cage:FlxSprite;
		public var trampolin:FlxSprite;
		private var visitors:FlxGroup;
		private var spits:FlxGroup;
		private var helicopter:Helicopter;
		private var flyingVisitors:FlxGroup; // can hit normal visitors for combos
		private var scoretexts:FlxGroup;
		private var totalScoreText:TotalScoreText;
		private var livesDisplay:FlxGroup; // contains 3 llama heads
		private var levelManager:LevelManager;
		private var newLevelText:NewLevelText;
		
		private var lives:uint; // 0 == game over
		private var difficulty:Number;
		public var elapsedTime:Number; // total in seconds
		private var lastVisitor:uint; // most recent array index
		private var lastSpit:uint; // most recent array index
		private var lastScoreText:uint; // most recent array index
		
		private var lastHelicopterSpawnedCounter:Number;
		/** after this time (in seconds), the helicopter is started either from left or right */
		private var DURATION_RESPAWN_HELICOPTER:Number = 25;
		
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

			// total score display
			totalScoreText = new TotalScoreText ();
			add(totalScoreText);
			
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
			add(Globals.sfxPlayer);
			
			// level manager determines current level, difficulty etc.
			levelManager = new LevelManager();
			add(levelManager);
			
			newLevelText = new NewLevelText();
			add(newLevelText);
		}
		
		override public function update():void
		{
			super.update();
			
			if (levelManager.isLevelElapsed() && (visitors.countLiving() <= 0))
			{
				levelManager.gotoNextLevel ();
				newLevelText.displayText(levelManager.currentLevel);
			}
			
			// update time & difficulty
			// elapsedTime = SECONDS
			// difficulty = 1.0 + 0.3 * SECONDS
			elapsedTime += FlxG.elapsed;
			difficulty = levelManager.getDifficulty ();
			
			lastHelicopterSpawnedCounter += FlxG.elapsed;			
			if (lastHelicopterSpawnedCounter > DURATION_RESPAWN_HELICOPTER) {
				helicopter.startHelicopter();
				lastHelicopterSpawnedCounter = 0;
			}
			
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
			spawnVisitors (levelManager.amountSpawns());
			
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
				FlxG.switchState(new GameoverState());
				
				// do not quit here
				//trace("quit");
				//fscommand("quit");
			}
		} // end of update
		
		
		private function spawnVisitors (amount:uint):void
		{
			trace("spawn");
			
			for (var i:uint = 0; i < amount; i++)
			{
				var v:Visitor = visitors.members[lastVisitor % Globals.MAX_VISITORS];
				
				if (v.exists) return; // keep on screen until dead
				
				lastVisitor++;
				
				// distribute left/right somewhat randomly, but avoid long streaks
				if (lastVisitor % 6 == 0) 
				{
					v.init(levelManager.currentLevel, i, FlxObject.LEFT);
				} else
				if (lastVisitor % 6 == 3) 
				{
					v.init(levelManager.currentLevel, i, FlxObject.RIGHT);
				} else
				{
					v.init(levelManager.currentLevel, i);
				}
			}
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
			
			Globals.sfxPlayer.Splotsh();
			
			if (s.isType(Spit.TYPE_MULTI_SPAWN))
			{
				spawnMultipleNewSpitsAtSpitPosition(s);				
			}
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
			FlxG.score += score * combo;
			
			// total score display (top right)
			totalScoreText.setText(FlxG.score, combo * 2.1);
			
			// temporary points display everywhere
			spawnScoreText(killed.x + killed.width / 2, killed.y, combo, killed.scorePoints);
		}
		
		public function setUpgrade():void
		{
			llama.setUpgradeType(helicopter.getUpgradeType() + 1);
		}
		
		public function loseLife ():void
		{
			if (lives > 0)
			{
				lives--;
				livesDisplay.length = lives;
			}
			
			if (lives <= 0)
			{
				FlxG.fade(0xff000000, 3, gameOverFunction);
			}
		}
		
		private function gameOverFunction():void
		{
			FlxG.switchState(new GameoverState());
		}
	
		/**
		 * Needs to be public, because also gets called from Spit when a MULTI_SPAWN spit hits the ground.
		 * @param	collidingSpit
		 */		
		public function spawnMultipleNewSpitsAtSpitPosition(collidingSpit:Spit):void {
			var speed:Number = 200;
			var y_threshold:Number = 10;
			var newSpit:Spit = spawnSpit(collidingSpit.x, collidingSpit.y - y_threshold);
			// 3rd parameter is the same like in Llama.spitStrengthModifier
			// angle 0 is to the right, 180 to the left, 270 up
			Llama.moveWithAngle(newSpit, 0, speed);
			
			newSpit = spawnSpit(collidingSpit.x, collidingSpit.y - y_threshold);
			Llama.moveWithAngle(newSpit, 180, speed);
			
			newSpit = spawnSpit(collidingSpit.x, collidingSpit.y - y_threshold);
			Llama.moveWithAngle(newSpit, 270-30, speed);
			
			newSpit = spawnSpit(collidingSpit.x, collidingSpit.y - y_threshold);
			Llama.moveWithAngle(newSpit, 270+30, speed);
		}
	} // end of class IngameState
} // end of package
