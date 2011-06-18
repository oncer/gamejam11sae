/**
 * WatchComponent.as
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
package com.divillysausages.gameobjeditor.component 
{
	import com.bit101.components.Label;
	import com.divillysausages.gameobjeditor.EditableVar;
	import flash.display.DisplayObjectContainer;
	
	/**
	 * The component we use when we want to just watch a variable, or when we try to
	 * edit a variable that's just read-only
	 * @author Damian
	 */
	public class WatchComponent extends GOEComponent
	{
		
		/*********************************************************************************/
		
		/**
		 * Creates a new WatchComponent
		 * @param obj The object that we're dealing with
		 * @param variable The <code>EditableVar</code> object that holds our variable info
		 * @param parent The <code>DisplayObjectContainer</code> to add this component to
		 * @param x The component x position
		 * @param y The component y position
		 */	
		public function WatchComponent( obj:*, variable:EditableVar, parent:DisplayObjectContainer = null, x:Number = 0.0, y:Number = 0.0 ) 
		{
			super( obj, variable );
			
			// just show a label to track it
			var label:Label 	= new Label( parent, x, y, "" );
			this.m_component	= label;
			label.autoSize		= true;
			if ( this.m_editVar.hasReadAccess )
				label.text = this.m_editVar.variable + ": " + this.m_obj[this.m_editVar.variable];
			else
				label.text = this.m_editVar.variable + ": NO READ ACCESS";
		}
		
		/**
		 * Updates the WatchComponent to always match our object's variable
		 */
		override public function update():void 
		{
			// get the component as a label
			var label:Label = this.m_component as Label;
			if ( label == null )
				return;
				
			// set the text on the label
			label.text 	= this.m_editVar.variable + ": " + this.m_obj[this.m_editVar.variable];
		}
		
	}

}