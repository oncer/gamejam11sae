/**
 * GameObjEvent.as
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
	 * The events that get fired by the Game Object Editor
	 * @author Damian
	 */
	public class GameObjEvent
	{		
		/**
		 * The event that gets fired when we select an object from
		 * the dropdown of available objects
		 */
		public static const SELECT_OBJECT:String = "select_object";
		
		/**
		 * The event that gets fired when we change the "highlight
		 * current object" behaviour
		 */
		public static const HIGHLIGHT_CURR_OBJECT:String = "show_current_object";
		
		/**
		 * The event that gets fired when we change the "click to
		 * select" behaviour
		 */
		public static const CLICK_TO_SELECT:String = "click_to_select";
		
		/**
		 * The event that gets fired when we want to save the current object
		 * edits
		 */
		public static const SAVE_CURR_OBJECT:String = "save_curr_object";
		
		/**
		 * The event that gets fired when we want to save the edits that
		 * we've done for all objects
		 */
		public static const SAVE_ALL_OBJECTS:String = "save_all_objects";
		
	}
	
}