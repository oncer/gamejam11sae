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
		
		[Embed(source="../gfx/spit.png")] private var SpitClass:Class;
		[Embed(source="../gfx/spitfloor.png")] private var SpitFloorClass:Class;
		[Embed(source="../gfx/spitparticle.png")] private var SpitParticleClass:Class;
		
		private var _canHit:Boolean;
		
		private var particles:FlxEmitter;
		private var explosion:FlxEmitter;
		private var gfxFloor:FlxSprite;
		
		private var floorTimer:Number;
		private var floorDead:Boolean;
		
		public function Spit(center:FlxPoint) 
		{
			// the spit is 16x16
			super(center.x-12, center.y-12);
			loadRotatedGraphic(SpitClass, 16, -1, true, true);
			acceleration.y = 200;
			exists = false;
			_canHit = true;
			
			gfxFloor = new FlxSprite(0,0);
			gfxFloor.loadGraphic(SpitFloorClass);
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
		}
		
		override public function preUpdate():void
		{
			super.preUpdate();
			gfxFloor.preUpdate();
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
			
			if (floorDead && !gfxFloor.flickering)
			{
				trace("[spit] kill");
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
		
		public function canHit (visitor:Visitor):Boolean
		{
			return _canHit;
		}
		
		public function hitSomething ():void
		{
			velocity.x /= 1.5;
			velocity.y = 0;
			_canHit = false;
			particles.on = false;
		}
		
		public function hitGround ():void
		{
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
		}
	}

}
