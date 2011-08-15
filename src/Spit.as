package  
{
	import flash.utils.*;
	import org.flixel.FlxSprite;
	import org.flixel.*;
	
	/**
	 * ...
	 * @author Chris
	 */
	public class Spit extends FlxSprite
	{
		public static const TYPE_DEFAULT:uint = 0;
		public static const TYPE_BIGSPIT:uint = 1;
		public static const TYPE_MULTI_SPAWN:uint = 2;
		
		private var spitType:uint;
		
		[Embed(source="../gfx/spit.png")] private var SpitClass:Class;
		[Embed(source="../gfx/spitfloor.png")] private var SpitFloorClass:Class;
		[Embed(source = "../gfx/spitparticle.png")] private var SpitParticleClass:Class;
		[Embed(source="../gfx/spitbig.png")] private var SpitBigClass:Class;
		
		private var _canHit:Boolean;
		
		private var particles:FlxEmitter;
		private var explosion:FlxEmitter;
		private var gfxFloor:FlxSprite;
		private var gfxDefault:FlxSprite;
		private var gfxBig:FlxSprite;
		
		private var floorTimer:Number;
		private var floorDead:Boolean;
		
		private var hitTrigger:OnceTrigger;
		
		private var bigsize:Number;
		private var onGround:Boolean;
		private var combo:int;
		
		public function Spit(center:FlxPoint) 
		{
			// the spit is 16x16
			super();
			gfxDefault = new FlxSprite(0,0);
			gfxDefault.loadRotatedGraphic(SpitClass, 16, -1, true, true);
			gfxBig = new FlxSprite(0,0);
			gfxBig.loadRotatedGraphic(SpitBigClass, 32, -1, true, true);
			
			exists = false;
			_canHit = true;
			onGround = false;
			
			gfxFloor = new FlxSprite(0,0);
			gfxFloor.loadGraphic(SpitFloorClass);
			
			spitType = TYPE_DEFAULT;
			combo = 1;
		}
		
		private function initParticles():void
		{
			particles = new FlxEmitter();
			particles.makeParticles (SpitParticleClass, 16, 0, true, 0);
			particles.setRotation(0, 0);
			particles.setYSpeed(-50, 100);
			particles.setXSpeed(-20, 20);
			particles.gravity = 100;
			particles.start (false,0.3,0.05,0);
		}
		
		private function commonReset(X:Number, Y:Number):void
		{
			super.reset(X,Y);
			initParticles();
			bigsize = 1.0;
			scale = new FlxPoint(bigsize, bigsize);
			gfxFloor.visible = false;
			floorTimer = 0;
			floorDead = false;
			velocity.x = 0;
			velocity.y = 0;
			acceleration.x = 0;
			acceleration.y = 200;
			drag.x = drag.y = 0;
			combo = 1;
			
			setCenterPosition(X, Y);
			
			setType(TYPE_DEFAULT);
		}
		
		public function resetAsChild(X:Number, Y:Number, parent:Spit):void
		{
			commonReset(X, Y);
			hitTrigger = parent.hitTrigger;
		}
		
		public function resetCreate(X:Number, Y:Number, onHitSomething:Function):void
		{
			commonReset (X, Y);
			hitTrigger = new OnceTrigger(onHitSomething);
		}
		
		override public function preUpdate():void
		{
			super.preUpdate();
			gfxFloor.preUpdate();
		}
		
		public function setCenterPosition(X:Number, Y:Number):void {
			if (isType(TYPE_BIGSPIT)) {
				x = X - gfxBig.width / 2;
				y = Y - gfxBig.height / 2;
			} else {
				x = X - gfxDefault.width / 2;
				y = Y - gfxDefault.height / 2;
			}
		}
		
		override public function update():void
		{
			super.update();
			particles.at(this);
			particles.update();
			
			if (spitType == TYPE_BIGSPIT) {
				if (velocity.x > 0) {
					gfxBig.angle += FlxG.elapsed * 360;
					if (gfxBig.angle >= 360) {
						gfxBig.angle -= 360;
					}
				} else {
					gfxBig.angle -= FlxG.elapsed * 360;
					if (gfxBig.angle <= -360) {
						gfxBig.angle += 360;
					}
				}
				gfxBig.x = x;
				gfxBig.y = y;
				gfxBig.postUpdate(); // set frame according to angle
				width = gfxBig.width;
				height = gfxBig.height;
			} else {
				gfxDefault.angle = Math.atan2(velocity.y, velocity.x) * 180 / Math.PI;
				gfxDefault.x = x;
				gfxDefault.y = y;
				gfxDefault.postUpdate();
				width = gfxDefault.width;
				height = gfxDefault.height;
			}
			
			
			if (_canHit && y + height >= Globals.GROUND_LEVEL) {
				hitGround();
			}
			
			gfxFloor.update();
			
			gfxFloor.x = x;
			gfxFloor.y = Globals.GROUND_LEVEL - gfxFloor.height;


			if (floorTimer > 0)
			{	
				floorTimer -= FlxG.elapsed;
				if ((floorTimer <= 0) && !floorDead) {
					gfxFloor.flicker(0.5);
					floorDead = true;
				}
			}
			
			if (floorDead && !gfxFloor.flickering && !isType(TYPE_BIGSPIT))
			{
				kill();
			}
			
			if (x > FlxG.width || x < -width) {
				kill();
			}
			
			/*if (y > FlxG.height) {
				kill();
			}*/
		}
		
		override public function draw():void
		{
			if (_canHit) {
				if (isType(TYPE_BIGSPIT)) {
					gfxBig.draw();
				} else {
					gfxDefault.draw();
				}
			}
			particles.draw();
			if (gfxFloor.visible) {
				gfxFloor.draw();
			}
		}
		
		public override function revive():void
		{
			_canHit = true;
			onGround = false;
			super.revive();
		}
		
		public function canHit ():Boolean
		{
			return _canHit;
		}
		
		/**
		 * Called when the spit hits something that
		 * is a target and NOT the ground. i.e. it counts
		 * as a hit in statistics.
		 */
		public function hitSomething ():void
		{
			if(!isType(TYPE_BIGSPIT))
			{
				velocity.y = 0;
				acceleration.y = 0;
				
				velocity.x /= 1.5;
				_canHit = false;
				particles.on = false;
				
				if (isType(TYPE_MULTI_SPAWN))
				{
					var currentState:IngameState = FlxG.state as IngameState;
					currentState.spawnMultipleNewSpitsAtSpitPosition(this, true);
				}
			}
			else 
			{ // BIGSPIT
				bigsize -= 0.15;
				gfxBig.scale = new FlxPoint(bigsize, bigsize);
				if (bigsize < 0.2) {
					_canHit = false;
					particles.on = false;
				}
			}
			
			hitTrigger.trigger();
		}
		
		public function hitGround ():void
		{
			velocity.y = 0;
			acceleration.y = 0;
			onGround = true;
			
			if(!isType(TYPE_BIGSPIT)) {
				_canHit = false;
				particles.on = false;
				gfxFloor.x = x;
				gfxFloor.y = Globals.GROUND_LEVEL - gfxFloor.height;
				gfxFloor.visible = true;
				drag.x = Math.abs(velocity.x) * 10;
				floorTimer = 0.5;
				floorDead = false;
				
				Globals.sfxPlayer.Splotsh();
				
				if (isType(TYPE_MULTI_SPAWN)) {
					var currentState:IngameState = FlxG.state as IngameState;
					currentState.spawnMultipleNewSpitsAtSpitPosition(this, false);
				}
			} else { // BIGSPIT
				// 3 px, because 3px are transparent border
				y = Globals.GROUND_LEVEL - (gfxBig.height + gfxBig.height*bigsize - 3 - 3*bigsize)/2;
			}
		}
		
		public function setType(SpitType:uint):void {
			spitType = SpitType;
		}
		
		public function isType(SpitType:uint):Boolean
		{
			return spitType == SpitType;
		}
		
		public function getCombo():int
		{
			return combo;
		}
		
		public function setCombo(combo:int):void
		{
			this.combo = combo;
		}
	}

}
