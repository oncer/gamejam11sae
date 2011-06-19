package  
{
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
		
		public function Spit(center:FlxPoint) 
		{			
			// the spit is 16x16
			super();			
			//loadGraphic(SpitClass);
			loadRotatedGraphic(SpitClass, 16, -1, true, true);
			setCenterPosition(center.x, center.y);
			
			exists = false;
			_canHit = true;
			
			gfxFloor = new FlxSprite(0,0);
			gfxFloor.loadGraphic(SpitFloorClass);
			
			spitType = TYPE_DEFAULT;
		}
		
		private function initParticles():void
		{
			particles = new FlxEmitter();
			particles.makeParticles (SpitParticleClass, 50, 0, true, 0);
			particles.setRotation(0, 0);
			particles.setYSpeed(-50, 100);
			particles.setXSpeed(-20, 20);
			particles.gravity = 100;
			particles.start (false,0.3,0.05,0);
		}
		
		override public function reset(X:Number, Y:Number):void
		{
			super.reset(X,Y);
			initParticles();
			gfxFloor.visible = false;
			floorTimer = 0;
			floorDead = false;
			velocity.x = 0;
			velocity.y = 0;
			acceleration.x = 0;
			acceleration.y = 200;
			drag.x = drag.y = 0;
			
			setCenterPosition(X, Y);
			
			setType(TYPE_DEFAULT);
		}
		
		override public function preUpdate():void
		{
			super.preUpdate();
			gfxFloor.preUpdate();
		}
		
		public function setCenterPosition(X:Number, Y:Number):void {
			x = X - width / 2;
			y = Y - height / 2;
		}
		
		override public function update():void
		{		
			super.update();
			particles.at(this);
			particles.update();
			
			angle = Math.atan2(velocity.y, velocity.x) * 180 / Math.PI;
			
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
				trace("[spit] kill");
				kill();
			}
			
			if (x > FlxG.width || x < -width) {
				trace("[spit] kill after getting out of screen");
				kill();
			}
			
			/*if (y > FlxG.height) {
				kill();
			}*/
		}
		
		override public function draw():void
		{
			if (_canHit) {
				super.draw();
			}
			particles.draw();
			if (gfxFloor.visible) {
				gfxFloor.draw();
			}
		}
		
		public override function revive():void
		{
			_canHit = true;
			super.revive();
		}
		
		public function canHit ():Boolean
		{
			return _canHit;
		}
		
		public function hitSomething ():void
		{			
			velocity.y = 0;
			if(!isType(TYPE_BIGSPIT)) {			
				velocity.x /= 1.5;
				_canHit = false;
				particles.on = false;
			} else {				
			}
		}
		
		public function hitGround ():void
		{
			
			if(!isType(TYPE_BIGSPIT)) {			
				_canHit = false;
				particles.on = false;
				gfxFloor.x = x;
				gfxFloor.y = Globals.GROUND_LEVEL - gfxFloor.height;
				gfxFloor.visible = true;
				drag.x = Math.abs(velocity.x) * 10;
				velocity.y = 0;
				acceleration.y = 0;
				floorTimer = 0.5;
				floorDead = false;
				
				Globals.sfxPlayer.Splotsh();
				
				if (isType(TYPE_MULTI_SPAWN)) {
					var currentState:IngameState = FlxG.state as IngameState;
					currentState.spawnMultipleNewSpitsAtSpitPosition(this);
				}
			} else {
				velocity.y = 0;
				acceleration.y = 0;
				// 3 px, because 3px are transparent border
				y = Globals.GROUND_LEVEL - height +3 ;
			}
		}
		
		public function setType(SpitType:uint):void {
			spitType = SpitType;
			
			// this gets only called at reset, for the default type, or if type is bigspit or MULTI_SPAWN - because these spit types are not generated that often, performance drain is still ok
			trace("[Spit] setSpitType: " + SpitType);
			if (isType(TYPE_BIGSPIT)) {
				loadRotatedGraphic(SpitBigClass, 16, -1, true, true);
			} else {
				loadRotatedGraphic(SpitClass, 16, -1, true, true);
			}
		}
		
		public function isType(SpitType:uint):Boolean {
			return spitType == SpitType;
		}
	}

}
