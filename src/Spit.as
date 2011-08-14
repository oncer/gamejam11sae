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
		
		private var floorTimer:Number;
		private var floorDead:Boolean;
		
		private var hitTrigger:OnceTrigger;
		
		private var bigsize:Number;
		private var onGround:Boolean;
		private var combo:int;
		
		public function Spit(center:FlxPoint) 
		{
var __start__:int = flash.utils.getTimer();
			// the spit is 16x16
			super();			
			//loadGraphic(SpitClass);
			loadRotatedGraphic(SpitClass, 16, -1, true, true);
			setCenterPosition(center.x, center.y);
			
			exists = false;
			_canHit = true;
			onGround = false;
			
			gfxFloor = new FlxSprite(0,0);
			gfxFloor.loadGraphic(SpitFloorClass);
			
			spitType = TYPE_DEFAULT;
			combo = 1;
		Profiler.profiler.profile('Spit.Spit', flash.utils.getTimer() - __start__);
}
		
		private function initParticles():void
		{
var __start__:int = flash.utils.getTimer();
			particles = new FlxEmitter();
			particles.makeParticles (SpitParticleClass, 16, 0, true, 0);
			particles.setRotation(0, 0);
			particles.setYSpeed(-50, 100);
			particles.setXSpeed(-20, 20);
			particles.gravity = 100;
			particles.start (false,0.3,0.05,0);
		Profiler.profiler.profile('Spit.initParticles', flash.utils.getTimer() - __start__);
}
		
		private function commonReset(X:Number, Y:Number):void
		{
var __start__:int = flash.utils.getTimer();
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
		Profiler.profiler.profile('Spit.commonReset', flash.utils.getTimer() - __start__);
}
		
		public function resetAsChild(X:Number, Y:Number, parent:Spit):void
		{
var __start__:int = flash.utils.getTimer();
			commonReset(X, Y);
			hitTrigger = parent.hitTrigger;
		Profiler.profiler.profile('Spit.resetAsChild', flash.utils.getTimer() - __start__);
}
		
		public function resetCreate(X:Number, Y:Number, onHitSomething:Function):void
		{
var __start__:int = flash.utils.getTimer();
			commonReset (X, Y);
			hitTrigger = new OnceTrigger(onHitSomething);
		Profiler.profiler.profile('Spit.resetCreate', flash.utils.getTimer() - __start__);
}
		
		override public function preUpdate():void
		{
var __start__:int = flash.utils.getTimer();
			super.preUpdate();
			gfxFloor.preUpdate();
		Profiler.profiler.profile('Spit.preUpdate', flash.utils.getTimer() - __start__);
}
		
		public function setCenterPosition(X:Number, Y:Number):void {
var __start__:int = flash.utils.getTimer();
			x = X - width / 2;
			y = Y - height / 2;
		Profiler.profiler.profile('Spit.setCenterPosition', flash.utils.getTimer() - __start__);
}
		
		override public function update():void
		{
var __start__:int = flash.utils.getTimer();		
			super.update();
			particles.at(this);
			particles.update();
			
			if (spitType == TYPE_BIGSPIT) {
				if (velocity.x > 0) {
					angle += FlxG.elapsed * 360;
					if (angle >= 360) {
						angle -= 360;
					}
				} else {
					angle -= FlxG.elapsed * 360;
					if (angle <= -360) {
						angle += 360;
					}
				}
			} else {
				angle = Math.atan2(velocity.y, velocity.x) * 180 / Math.PI;
			}
			
			
			//trace("spit vel x: " + velocity.x + ", y:" + velocity.y);
			//trace("spit acc x: " + acceleration.x + ", y:" + acceleration.y);
			
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
				//trace("[spit] kill");
				kill();
			}
			
			if (x > FlxG.width || x < -width) {
				//trace("[spit] kill after getting out of screen");
				kill();
			}
			
			/*if (y > FlxG.height) {
				kill();
			}*/
		Profiler.profiler.profile('Spit.update', flash.utils.getTimer() - __start__);
}
		
		override public function draw():void
		{
var __start__:int = flash.utils.getTimer();
			if (_canHit) {
				super.draw();
			}
			particles.draw();
			if (gfxFloor.visible) {
				gfxFloor.draw();
			}
		Profiler.profiler.profile('Spit.draw', flash.utils.getTimer() - __start__);
}
		
		public override function revive():void
		{
var __start__:int = flash.utils.getTimer();
			_canHit = true;
			onGround = false;
			super.revive();
		Profiler.profiler.profile('Spit.revive', flash.utils.getTimer() - __start__);
}
		
		public function canHit ():Boolean
		{
var __start__:int = flash.utils.getTimer();
			{ var __ret1__:* = _canHit;
Profiler.profiler.profile('Spit.canHit', flash.utils.getTimer() - __start__); return __ret1__; }
		Profiler.profiler.profile('Spit.canHit', flash.utils.getTimer() - __start__);
}
		
		/**
		 * Called when the spit hits something that
		 * is a target and NOT the ground. i.e. it counts
		 * as a hit in statistics.
		 */
		public function hitSomething ():void
		{
var __start__:int = flash.utils.getTimer();	
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
				scale = new FlxPoint(bigsize, bigsize);
				if (bigsize < 0.2) {
					_canHit = false;
					particles.on = false;
				}
			}
			
			hitTrigger.trigger();
		Profiler.profiler.profile('Spit.hitSomething', flash.utils.getTimer() - __start__);
}
		
		public function hitGround ():void
		{
var __start__:int = flash.utils.getTimer();
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
				y = Globals.GROUND_LEVEL - (height + height*bigsize - 3 - 3*bigsize)/2;
			}
		Profiler.profiler.profile('Spit.hitGround', flash.utils.getTimer() - __start__);
}
		
		public function setType(SpitType:uint):void {
var __start__:int = flash.utils.getTimer();
			spitType = SpitType;
			
			// this gets only called at reset, for the default type, or if type is bigspit or MULTI_SPAWN - because these spit types are not generated that often, performance drain is still ok
			//trace("[Spit] setSpitType: " + SpitType);
			if (isType(TYPE_BIGSPIT)) {
				loadRotatedGraphic(SpitBigClass, 32, -1, true, true);
			} else {
				loadRotatedGraphic(SpitClass, 16, -1, true, true);
			}
		Profiler.profiler.profile('Spit.setType', flash.utils.getTimer() - __start__);
}
		
		public function isType(SpitType:uint):Boolean
		{
var __start__:int = flash.utils.getTimer();
			{ var __ret2__:* = spitType == SpitType;
Profiler.profiler.profile('Spit.isType', flash.utils.getTimer() - __start__); return __ret2__; }
		Profiler.profiler.profile('Spit.isType', flash.utils.getTimer() - __start__);
}
		
		public function getCombo():int
		{
var __start__:int = flash.utils.getTimer();
			{ var __ret3__:* = combo;
Profiler.profiler.profile('Spit.getCombo', flash.utils.getTimer() - __start__); return __ret3__; }
		Profiler.profiler.profile('Spit.getCombo', flash.utils.getTimer() - __start__);
}
		
		public function setCombo(combo:int):void
		{
var __start__:int = flash.utils.getTimer();
			this.combo = combo;
		Profiler.profiler.profile('Spit.setCombo', flash.utils.getTimer() - __start__);
}
	}

}
