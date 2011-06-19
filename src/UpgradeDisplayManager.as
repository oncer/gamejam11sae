package  
{
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.*;
	
	/**
	 * ...
	 * @author Chris
	 */
	public class UpgradeDisplayManager extends FlxGroup
	{
				
		[Embed(source = "../gfx/upgrade0.png")] private var Upgrade0Class:Class;
		[Embed(source = "../gfx/upgrade1.png")] private var Upgrade1Class:Class;
		[Embed(source = "../gfx/upgrade2.png")] private var Upgrade2Class:Class;
		[Embed(source = "../gfx/upgrade3.png")] private var Upgrade3Class:Class;
		
		private var upgradeClasses:Array = new Array(Upgrade0Class, Upgrade1Class, Upgrade2Class, Upgrade3Class);
		
		private var upgradeBars:Array = new Array();
		/*private var upgradeBar0:FlxBar;
		private var upgradeBar1:FlxBar;
		private var upgradeBar2:FlxBar;
		private var upgradeBar3:FlxBar;*/
		
		private var WIDTH:int = 32;
		private var HEIGHT:int = 32;
		
		private var currentActiveIndex:uint;
		
		public function UpgradeDisplayManager(X:int, Y:int) 
		{			
			// the empty border should always be displayed
			var upgradeBackgroundBorder:FlxSprite = new FlxSprite(X, Y);
			upgradeBackgroundBorder.loadGraphic(Upgrade0Class);
			add(upgradeBackgroundBorder);
			
			for (var i:int = 0; i < 4; i++) {
				var upgradeBar:FlxBar = new FlxBar(X, Y, FlxBar.FILL_BOTTOM_TO_TOP, WIDTH, HEIGHT);
				upgradeBar.createImageBar(null, upgradeClasses[i], 0x00000000);
				add(upgradeBar);				
				upgradeBar.visible = false;
				upgradeBars.push(upgradeBar);
			}
			upgradeBars[0].visible = true;
			currentActiveIndex = 0;
		}
		
		public function updateUpgradeDisplay(activeUpgradeindex:uint, percent:Number):void {
			
			
			// change of upgrade
			if (activeUpgradeindex != currentActiveIndex) {
				trace("active upgrade index changed in UpgradeDisplayManager from " + currentActiveIndex + " to " + activeUpgradeindex);
				upgradeBars[currentActiveIndex].visible = false;
				
				currentActiveIndex = activeUpgradeindex;
				upgradeBars[currentActiveIndex].visible = true;
			}
			//trace("percent: " + percent);
			if (percent > 100)
				percent = 100;
				
			upgradeBars[currentActiveIndex].percent = 100-percent;
		}
		
	}

}