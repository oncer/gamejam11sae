package
{
	import org.flixel.*;
	public class AmbientPlayer extends FlxGroup
	{
		[Embed(source="../audio/ambient.mp3")] private static var SndCity:Class;
		[Embed(source="../audio/main_theme.mp3")] private static var SndMusic:Class;
		/*[Embed(source="../audio/kinder1_low.mp3")] private static var SndKids1:Class;
		[Embed(source="../audio/kinder2_low.mp3")] private static var SndKids2:Class;
		[Embed(source="../audio/kinder3_low.mp3")] private static var SndKids3:Class;
		[Embed(source="../audio/kinder4_low.mp3")] private static var SndKids4:Class;
		[Embed(source="../audio/kinder5_low.mp3")] private static var SndKids5:Class;
		[Embed(source="../audio/kinder6_low.mp3")] private static var SndKids6:Class;*/
		
		private var city:FlxSound;
		private var music:FlxSound;
		//private var kids:FlxSound;
		/*private var kidsClasses:Array = new Array(SndKids1, SndKids2, SndKids3,
												  SndKids4, SndKids5, SndKids6);*/
										   
		private var targetTime:Number;
		private var elapsedTime:Number;
		private var started:Boolean;
		
		private static const AMBIENT_VOLUME:Number = 0.33;
		private static const MUSIC_VOLUME:Number = 1.0;
		
		public function AmbientPlayer():void
		{
			city = new FlxSound();
			music = new FlxSound();
			//kids = new FlxSound();
			started = false;
		}
		
		public function start():void
		{
			city.loadEmbedded(SndCity, true);
			city.volume = 0;
			city.play();
			music.loadEmbedded(SndMusic, true);
			music.volume = 0;
			music.play();
			started = true;
			targetTime = Math.random() * 5 + 10;
			elapsedTime = 0;
		}
		
		public function stop():void
		{
			city.stop();
			music.stop();
		}
		
		override public function update():void
		{
			if (!started) return;
			if (city.volume < AMBIENT_VOLUME) {
				city.volume += (FlxG.elapsed / 2) * AMBIENT_VOLUME;
				music.volume += (FlxG.elapsed / 2) * MUSIC_VOLUME;
				if (city.volume > AMBIENT_VOLUME) {
					city.volume = AMBIENT_VOLUME;
				}
				if (music.volume > MUSIC_VOLUME) {
					music.volume = MUSIC_VOLUME;
				}
			}
			/*elapsedTime += FlxG.elapsed;
			if (elapsedTime > targetTime)
			{
				var i:int = Math.random() * kidsClasses.length;
				kids.loadEmbedded(kidsClasses[i], false);
				kids.play();
				targetTime = Math.random() * 10 + 20;
				elapsedTime = 0;
			}*/
		}
	}
}
