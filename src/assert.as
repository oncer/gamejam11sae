package
{

public function assert(expression:Boolean):void
{
	Globals.ASSERT_ENABLED {
		if (!expression)
			throw new Error("Assertion failed!");
	}
}

}
