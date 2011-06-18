/**
 * ToggleEvent.as
 * Damian Connolly
 * version 1.3
 * 
 * Copyright (c) 2011 Damian Connolly
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package com.divillysausages.gameobjeditor.event 
{
	import flash.events.Event;
	
	/**
	 * The event that we fire when we need to toggle a value
	 * @author Damian
	 */
	public class ToggleEvent extends Event 
	{
		
		/*********************************************************************************/
		
		/**
		 * The value to toggle to
		 */
		public var value:Boolean = false;
		
		/*********************************************************************************/
		
		/**
		 * Creates a new ToggleEvent
		 * @param type The type of the event
		 * @param value The value to toggle to
		 * @param bubbles Whether the event bubbles or not
		 * @param cancelable Whether the event is cancelable or not
		 */
		public function ToggleEvent( type:String, value:Boolean, bubbles:Boolean=false, cancelable:Boolean = false ) 
		{ 
			super( type, bubbles, cancelable );
			this.value = value;
		} 
		
		/**
		 * Clones the event and returns a new copy
		 * @return A new ToggleEvent object that's a clone of this one
		 */
		public override function clone():Event 
		{ 
			return new ToggleEvent( type, this.value, bubbles, cancelable );
		} 
		
		/**
		 * Returns the String version of the event
		 */
		public override function toString():String 
		{ 
			return formatToString("ToggleEvent", "type", "value", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}