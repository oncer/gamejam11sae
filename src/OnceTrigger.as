package
{
	/**
	 * Proxy which passes a call through to a function only once.
	 * Subsequent calls to the trigger are suppressed.
	 */
	public class OnceTrigger
	{
		private var hasFired:Boolean;
		private var triggeredFunction:Function;
		
		public function OnceTrigger(triggerFunc:Function)
		{
			hasFired = false;
			triggeredFunction = triggerFunc;
		}
		
		public function trigger():void
		{
			if (!hasFired)
			{
				triggeredFunction();
				hasFired = true;
			}
		}
	}
}
