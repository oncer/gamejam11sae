package
{
    import org.flixel.*;

    [SWF(width="800", height="500", backgroundColor="#000000")]

    public class main extends FlxGame
    {
        public function main():void
        {
            super(800,500,MenuState,1); // super(800,500,StartState,1);
            Globals.sfxPlayer = new SfxPlayer();
            forceDebugger = true;
        }
    }
}

