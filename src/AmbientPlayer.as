package
{
	import org.flixel.*;
	public class AmbientPlayer extends FlxGroup
	{
		[Embed(source="../audio/main_theme.mp3")] private static var SndMusic:Class;
		
		private var city:FlxSound;
		private var music:FlxSound;
										   
		private var targetTime:Number;
		private var elapsedTime:Number;
		private var started:Boolean;
		
		private static const AMBIENT_VOLUME:Number = 0.33;
		private static const MUSIC_VOLUME:Number = 1.0;
		
		public function AmbientPlayer():void
		{
			music = new FlxSound();
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
		
		override public function update():void
		{
			if (!started) return;
			if (music.volume < MUSIC_VOLUME) {
				music.volume += (FlxG.elapsed / 2) * MUSIC_VOLUME;
				if (music.volume > MUSIC_VOLUME) {
					music.volume = MUSIC_VOLUME;
				}
			}
		}
	}
}
