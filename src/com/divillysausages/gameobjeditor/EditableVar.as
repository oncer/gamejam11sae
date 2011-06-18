/**
 * EditableVar.as
 * Damian Connolly
 * version 1.0
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
	 * A helper class to hold the variable that we're affecting, the type of
	 * component we want to use to edit it, and the different parameters to
	 * fill for the type
	 * 
	 * @author Damian Connolly
	 */
	public class EditableVar
	{
		
		/**
		 * The name of the variable on the Object that we want to edit
		 */
		public var variable:String = null;
		
		/**
		 * The type of the component that we want to use for this variable.
		 * Use the static consts from the EditableVar class.
		 */
		public var type:String = null;
		
		/**
		 * Any params that we want to use to customise our edit component
		 */
		public var params:Object = null;
		
		/**
		 * Do we have read access to this variable? (so we can show the current value)
		 * 
		 * @default true 
		 */
		public var hasReadAccess:Boolean = true;
		
		/*********************************************************************************/
		
		/**
		 * A debug function that traces out the info for this Object
		 */
		public function debugTrace():void
		{
			trace( "[EditableVar]" );
			trace( "  Variable: '" + this.variable + "'" );
			trace( "  Type: '" + this.type + "'" );
			trace( "  Params: " + ( ( this.params == null ) ? "null" : "" ) );
			for ( var key:Object in this.params )
				trace( "    '" + key + "' = " + this.params[key] );
		}
		
	}

}