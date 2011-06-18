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
		[Embed(source="../gfx/spitparticle.png")] private var SpitParticleClass:Class;
		
		private var _canHit:Boolean;
		
		private var particles:FlxEmitter;
		private var explosion:FlxEmitter;
		
		public function Spit(center:FlxPoint) 
		{
			// the spit is 16x16
			super(center.x-8, center.y-8);
			loadGraphic(SpitClass);
			acceleration.y = 200;
			exists = false;
			_canHit = true;
			
			particles = new FlxEmitter();
			particles.makeParticles (SpitParticleClass, 50, 0, true, 0);
			particles.setRotation(0, 0);
			particles.setYSpeed(-50, 100);
			particles.setXSpeed(-20, 20);
			particles.gravity = 500;
			particles.start (false,1,0.2,0);
			
			explosion = new FlxEmitter();
			explosion.makeParticles(SpitParticleClass, 50, 16, true, 0);
			explosion.setRotation(0, 360);
			explosion.setYSpeed(-100, 100);
			explosion.setXSpeed(-100, 100);
			explosion.gravity = 200;
		}
		
		override public function update():void
		{		
			super.update();
			particles.at(this);
			particles.update();
			explosion.at(this);
			explosion.update();
			
			//trace("spit vel x: " + velocity.x + ", y:" + velocity.y);
			//trace("spit acc x: " + acceleration.x + ", y:" + acceleration.y);
			if (y > FlxG.height)
				kill();
		}
		
		override public function draw():void
		{
			if (_canHit) {
				super.draw();
			}
			particles.draw();
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
			explosion.start(true, 0.5);
		}
	}

}
