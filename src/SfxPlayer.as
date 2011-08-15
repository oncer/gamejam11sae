package
{
	import org.flixel.*;
	
	public class SfxPlayer extends FlxGroup
	{
		[Embed(source="../audio/splotsh/splotsh1.mp3")] private static var SndSplotsh1:Class;
		[Embed(source="../audio/splotsh/splotsh2.mp3")] private static var SndSplotsh2:Class;
		[Embed(source="../audio/splotsh/splotsh3.mp3")] private static var SndSplotsh3:Class;
		[Embed(source="../audio/splotsh/splotsh4.mp3")] private static var SndSplotsh4:Class;
		[Embed(source="../audio/splotsh/splotsh5.mp3")] private static var SndSplotsh5:Class;
		[Embed(source="../audio/splotsh/splotsh6.mp3")] private static var SndSplotsh6:Class;
		[Embed(source="../audio/splotsh/splotsh7.mp3")] private static var SndSplotsh7:Class;
		[Embed(source="../audio/splotsh/splotsh8.mp3")] private static var SndSplotsh8:Class;
		[Embed(source="../audio/splotsh/splotsh9.mp3")] private static var SndSplotsh9:Class;
		[Embed(source="../audio/splotsh/splotsh10.mp3")] private static var SndSplotsh10:Class;
		[Embed(source="../audio/splotsh/splotsh11.mp3")] private static var SndSplotsh11:Class;
		[Embed(source="../audio/splotsh/splotsh12.mp3")] private static var SndSplotsh12:Class;
		[Embed(source="../audio/splotsh/splotsh13.mp3")] private static var SndSplotsh13:Class;
		[Embed(source="../audio/splotsh/splotsh14.mp3")] private static var SndSplotsh14:Class;
		[Embed(source="../audio/splotsh/splotsh15.mp3")] private static var SndSplotsh15:Class;
		[Embed(source="../audio/splotsh/splotsh16.mp3")] private static var SndSplotsh16:Class;
		[Embed(source="../audio/splotsh/splotsh17.mp3")] private static var SndSplotsh17:Class;
		
		[Embed(source="../audio/spit/spit1.mp3")] private static var SndSpit1:Class;
		[Embed(source="../audio/spit/spit2.mp3")] private static var SndSpit2:Class;
		[Embed(source="../audio/spit/spit3.mp3")] private static var SndSpit3:Class;
		[Embed(source="../audio/spit/spit4.mp3")] private static var SndSpit4:Class;
		[Embed(source="../audio/spit/spit5.mp3")] private static var SndSpit5:Class;
		[Embed(source="../audio/spit/spit6.mp3")] private static var SndSpit6:Class;
		[Embed(source="../audio/spit/spit7.mp3")] private static var SndSpit7:Class;
		[Embed(source="../audio/spit/spit8.mp3")] private static var SndSpit8:Class;
		[Embed(source="../audio/spit/spit9.mp3")] private static var SndSpit9:Class;
		[Embed(source="../audio/spit/spit10.mp3")] private static var SndSpit10:Class;
		[Embed(source="../audio/spit/spit11.mp3")] private static var SndSpit11:Class;
		[Embed(source="../audio/spit/spit12.mp3")] private static var SndSpit12:Class;
		
		[Embed(source="../audio/trampolin/trampolin1.mp3")] private static var SndTrampolin1:Class;
		[Embed(source="../audio/trampolin/trampolin2.mp3")] private static var SndTrampolin2:Class;
		[Embed(source="../audio/trampolin/trampolin3.mp3")] private static var SndTrampolin3:Class;
		
		[Embed(source="../audio/scream/kid1.mp3")] private static var SndKid1:Class;
		[Embed(source="../audio/scream/kid2.mp3")] private static var SndKid2:Class;
		[Embed(source="../audio/scream/man1.mp3")] private static var SndMan1:Class;
		[Embed(source="../audio/scream/man2.mp3")] private static var SndMan2:Class;
		[Embed(source="../audio/scream/man3.mp3")] private static var SndMan3:Class;
		[Embed(source="../audio/scream/man4.mp3")] private static var SndMan4:Class;
		[Embed(source="../audio/scream/oldwoman1.mp3")] private static var SndOldWoman1:Class;
		[Embed(source="../audio/scream/woman1.mp3")] private static var SndWoman1:Class;
		[Embed(source="../audio/scream/woman2.mp3")] private static var SndWoman2:Class;
		
		[Embed(source="../audio/upgrade.mp3")] private static var SndUpgrade:Class;
		
		[Embed(source="../audio/chopper.mp3")] private static var SndChopper:Class;
		
		[Embed(source="../audio/game_over.mp3")] private static var SndGameover:Class;
		
		private var SndSplotshPool:Array = new Array(
			SndSplotsh1, SndSplotsh2, SndSplotsh3, SndSplotsh4, SndSplotsh5,
			SndSplotsh6, SndSplotsh7, SndSplotsh8, SndSplotsh9, SndSplotsh10,
			SndSplotsh11, SndSplotsh12, SndSplotsh13, SndSplotsh14, SndSplotsh15,
			SndSplotsh16, SndSplotsh17
		);
		
		private var SndSpitPool:Array = new Array(
			SndSpit1, SndSpit2, SndSpit3, SndSpit4, SndSpit5, SndSpit6,
			SndSpit7, SndSpit8, SndSpit9, SndSpit10, SndSpit11, SndSpit12
		);
		
		private var SndTrampolinPool:Array = new Array(
			SndTrampolin1, SndTrampolin2, SndTrampolin3
		);
		
		private var SndScreamKidPool:Array = new Array(
			SndKid1, SndKid2
		);
		
		private var SndScreamManPool:Array = new Array(
			SndMan1, SndMan2, SndMan3, SndMan4
		);
		
		private var SndScreamOldWomanPool:Array = new Array(
			SndOldWoman1
		);
		
		private var SndScreamWomanPool:Array = new Array(
			SndWoman1, SndWoman2
		);
		
		private var SndUpgradePool:Array = new Array(
			SndUpgrade
		);
		
		public function Splotsh():void {  playSfxRandomPool(SndSplotshPool); }
		public function Spit():void { playSfxRandomPool(SndSpitPool); }
		public function Trampolin():void { playSfxRandomPool(SndTrampolinPool); }
		public function ScreamKid():void { playSfxRandomPool(SndScreamKidPool); }
		public function ScreamMan():void { playSfxRandomPool(SndScreamManPool); }
		public function ScreamOldWoman():void { playSfxRandomPool(SndScreamOldWomanPool); }
		public function ScreamWoman():void { playSfxRandomPool(SndScreamWomanPool); }
		public function Upgrade():void { playSfxRandomPool(SndUpgradePool); }
		public function Gameover():void { FlxG.play(SndGameover, volume); }
		
		private var sfxChopper:FlxSound;

		public var volume:Number = 1.0;
		
		public function ChopperIn():void
		{
			sfxChopper.volume = volume;
			sfxChopper.fadeIn(2);
			sfxChopper.update();
		}
		
		public function ChopperOut():void
		{
			sfxChopper.fadeOut(1);
		}
		
		public function SfxPlayer():void
		{
			sfxChopper = new FlxSound();
			sfxChopper.loadEmbedded(SndChopper);
			sfxChopper.volume = 0.5;
			add(sfxChopper);
		}
		
		// Pool is an array of sound classes
		private function playSfxRandomPool(POOL:Array):void
		{
			if (POOL == null || POOL.length <= 0) return;
			var i:uint = Math.random() * POOL.length;
			FlxG.play(POOL[i], volume);
		}
	}
}
