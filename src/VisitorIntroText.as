package
{
	import org.flixel.FlxSprite;
	import org.flixel.*;
	
	public class VisitorIntroText extends FlxGroup
	{
		[Embed(source = "../gfx/visitor_intro.png")] private static var PresentFrame:Class;
		private static const PRESENT_FRAME_WIDTH:int = 64;
		private static const PRESENT_FRAME_HEIGHT:int = 96;
		
		private var textId:int;
		private var visitorNr:int;
		private var timeToLive:Number;
		
		private const INTRO_TEXT:Vector.<String> = Vector.<String> ([
			"Beware of unsupervised children trying to " +
			"climb the cage. They're fast too!", // child
			"Humans are coming to visit you at the zoo. Your " +
			"cage walls can not protect you anymore! Use your " +
			"natural defenses to repel them.", // man
			"Women climb faster. Be on your guard!", // woman
			"Tourists with cameras want a close-up shot.", // tourist
			"Seniors get a discount on their tickets. " +
			"Give them their money's worth!", // granny
			"Zombies are coming. They want your brains!", // zombie
			"Circus directors", // circus director
			"Tiger men" // tiger man
		]);
		private const DISPLAY_SECONDS:Number = 7;
		private const LEFT_X:Number = 150;
		private const TOP_Y:Number = 60;
		private const X_SPACING:Number = 5; // space between text and img
		private const Y_SPACING:Number = 80; // y-dist between top borders of two V.I.Texts
		
		private const FONT_SIZE:Number = 16;
		private const COLOR:uint = 0xeeee9f;
		private const SHADOW:uint = 0x999999;
		
		public function VisitorIntroText(textId:int, y_index:int)
		{
			timeToLive = DISPLAY_SECONDS;
			this.textId = textId;
			this.visitorNr = visitorFromTextId(textId);
			
			var top_y:int = TOP_Y + Y_SPACING * y_index;
			var text:FlxText = new FlxText(LEFT_X, top_y, FlxG.width - LEFT_X*2);
			text.font = "verab";
			text.alignment = "left";
			text.color = COLOR;
			text.shadow = SHADOW;
			text.size = FONT_SIZE;
			text.text = INTRO_TEXT[textId];
			
			var bgLeft:int = LEFT_X - X_SPACING - PRESENT_FRAME_WIDTH;
			var bgTop:int = top_y + (text.height - PRESENT_FRAME_HEIGHT) / 2;
			var imageBackground:FlxSprite = new FlxSprite(bgLeft, bgTop);
			imageBackground.loadGraphic(PresentFrame, false, false,
				PRESENT_FRAME_WIDTH, PRESENT_FRAME_HEIGHT);
			
			var imageClass:Class = Visitor.getTypeImage(visitorNr);
			var imgLeft:int = bgLeft + 16;
			var imgTop:int = bgTop + 16;
			var image:FlxSprite = new FlxSprite(imgLeft, imgTop);
			image.loadGraphic(imageClass, true, true,
				Globals.VISITOR_SPRITE_WIDTH, Globals.VISITOR_SPRITE_HEIGHT);
			image.addAnimation("walk", [0,1,2,3], Globals.ANIM_SPEED);
			image.play("walk");
			
			add(text);
			add(imageBackground);
			add(image);
		}
		
		override public function update():void
		{
			super.update();
			
			timeToLive -= FlxG.elapsed;
			
			if (timeToLive <= 0)
			{
				kill();
			}
		}
		
		private function visitorFromTextId(textId:int):int
		{
			const VISITOR_TYPES:Vector.<int> = Vector.<int> (
				[0, 1, 2, 3, 4, 9, 11, 10]);
			
			assert((textId >= 0) && (textId < INTRO_TEXT.length));
			assert(VISITOR_TYPES.length == INTRO_TEXT.length);
			
			return VISITOR_TYPES[textId];
		}
	}
}
