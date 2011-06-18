/**
 * EditableTypes.as
 * Damian Connolly
 * version 1.0
 * 
 * The different types of editable components that we provide
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
package com.divillysausages.gameobjeditor 
{
	
	/**
	 * The different types of editable components that we provide
	 * 
	 * @author Damian Connolly
	 */
	public class EditableTypes
	{
		
		/**
		 * We want to edit this variable as a input <code>TextField</code>
		 */
		public static const TYPE_INPUT:String = "input";
		
		/**
		 * We want to edit this variable as a numerical slider
		 */
		public static const TYPE_SLIDER:String = "slider";
		
		/**
		 * We want to edit this variable by taking static consts from
		 * another class
		 */
		public static const TYPE_STATIC_CONSTS:String = "static_consts";
		
		/**
		 * We want to edit this variable by choosing a colour
		 */
		public static const TYPE_COLOUR:String = "colour";
		
		/**
		 * We want to edit this variable by using a numerical stepper
		 */
		public static const TYPE_STEPPER:String = "stepper";
		
		/**
		 * We want to edit this variable by using a checkbox
		 */
		public static const TYPE_CHECKBOX:String = "checkbox";
		
		/**
		 * We want to just watch this variable
		 */
		public static const TYPE_WATCH:String = "watch";
		
		/*********************************************************************************/
		
		/**
		 * Checks if a <code>String</code> is one of the editable types that we support
		 * 
		 * @param type The <code>String</code> that we're checking
		 * 
		 * @return Returns <code>true</code> if we support this type, <code>false</code> otherwise
		 */
		public static function isGoodType( type:String ):Boolean
		{
			if ( type == EditableTypes.TYPE_INPUT )
				return true;
			if ( type == EditableTypes.TYPE_SLIDER )
				return true;
			if ( type == EditableTypes.TYPE_STATIC_CONSTS )
				return true;
			if ( type == EditableTypes.TYPE_COLOUR )
				return true;
			if ( type == EditableTypes.TYPE_STEPPER )
				return true;
			if ( type == EditableTypes.TYPE_CHECKBOX )
				return true;
			if ( type == EditableTypes.TYPE_WATCH )
				return true;
			return false;
		}
		
	}

}