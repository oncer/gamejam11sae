package
{
	import org.flixel.*;
	
	public class AmbientPlayer extends FlxGroup
	{
		[Embed(source="../audio/main_theme.mp3")] private static var SndMusic:Class;
		
		private var music:FlxSound;
		
		private var targetTime:Number;
		private var elapsedTime:Number;
		private var started:Boolean;
		
		public var _volume:Number = 1.0;
		
		public function AmbientPlayer():void
		{
			music = new FlxSound();
			add(music);
			started = false;
		}
		
		public function start():void
		{
			music.loadEmbedded(SndMusic, true);
			music.volume = 0;
			music.play();
			started = true;
			targetTime = Math.random() * 5 + 10;
			elapsedTime = 0;
		}
		
		public function stop():void
		{
			music.stop();
		}
		
		public function set volume(v:Number):void
		{
			_volume = v;
		}
		
		public function get volume():Number
		{
			return _volume;
		}
		
		override public function update():void
		{
			if (!started) return;
			if (music.volume < _volume) {
				music.volume += (FlxG.elapsed / 2);
				if (music.volume > _volume) {
					music.volume = _volume;
				}
			}
			if (music.volume > _volume) {
				music.volume -= (FlxG.elapsed * 2);
				if (music.volume < _volume) {
					music.volume = _volume;
				}
			}
		}
	}
}
