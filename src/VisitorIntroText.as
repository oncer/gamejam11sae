package
{
	import org.flixel.FlxSprite;
	import org.flixel.*;
	
	public class VisitorIntroText extends FlxGroup
	{
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
			"Zombies are coming. They want your brains!" // zombie
		]);
		private const DISPLAY_SECONDS:Number = 7;
		private const LEFT_X:Number = 150;
		private const TOP_Y:Number = 60;
		private const X_SPACING:Number = 5; // space between text and img
		private const Y_SPACING:Number = 80; // y-dist between top borders of two V.I.Texts
		
		private const FONT_SIZE:Number = 14;
		private const COLOR:uint = 0xeeee9f;
		private const SHADOW:uint = 0x333333;
		
		public function VisitorIntroText(visitorNr:int, y_index:int)
		{
			timeToLive = DISPLAY_SECONDS;
			this.visitorNr = visitorNr;
			
			var top_y:int = TOP_Y + Y_SPACING * y_index;
			var text:FlxText = new FlxText(LEFT_X, top_y, FlxG.width - LEFT_X*2);
			text.alignment = "left";
			text.color = COLOR;
			text.shadow = SHADOW;
			text.size = FONT_SIZE;
			text.text = INTRO_TEXT[visitorNr];
			
			var imageClass:Class = Visitor.getTypeImage(visitorNr);
			var imgLeft:int = LEFT_X - Globals.VISITOR_SPRITE_WIDTH - X_SPACING;
			var image:FlxSprite = new FlxSprite(imgLeft, top_y);
			image.loadGraphic(imageClass, true, true,
				Globals.VISITOR_SPRITE_WIDTH, Globals.VISITOR_SPRITE_HEIGHT);
			image.addAnimation("walk", [0,1,2,3], Globals.ANIM_SPEED);
			image.play("walk");
			
			add(text);
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
	}
}
