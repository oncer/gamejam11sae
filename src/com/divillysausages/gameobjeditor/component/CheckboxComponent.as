/**
 * CheckboxComponent.as
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
	import com.bit101.components.CheckBox;
	import com.divillysausages.gameobjeditor.EditableVar;
	import flash.display.DisplayObjectContainer;
	import flash.events.MouseEvent;
	
	/**
	 * The component we use by default when we're dealing with booleans
	 * @author Damian
	 */
	public class CheckboxComponent extends GOEComponent
	{
		
		/*********************************************************************************/
		
		/**
		 * Creates a new CheckboxComponent
		 * @param obj The object that we're dealing with
		 * @param variable The <code>EditableVar</code> object that holds our variable info
		 * @param parent The <code>DisplayObjectContainer</code> to add this component to
		 * @param x The component x position
		 * @param y The component y position
		 */
		public function CheckboxComponent( obj:*, variable:EditableVar, parent:DisplayObjectContainer = null, x:Number = 0.0, y:Number = 0.0 ) 
		{
			super( obj, variable );
			
			// create our component and set it's initial state
			var check:CheckBox	= new CheckBox( parent, x, y, this.m_editVar.variable, this._onCheck );
			this.m_component 	= check; 
			if ( this.m_editVar.hasReadAccess )
				check.selected = this.m_obj[this.m_editVar.variable];
		}
		
		/**
		 * Destroys the CheckboxComponent and clears it for garbage collection
		 */
		override public function destroy():void 
		{
			// remove our event listener, then super it
			this.m_component.removeEventListener( MouseEvent.CLICK, this._onCheck );
			super.destroy();
		}
		
		/**
		 * Updates the CheckboxComponent to always match our object's variable
		 */
		override public function update():void 
		{
			// get the checkbox component
			var check:CheckBox = this.m_component as CheckBox;
			if ( check == null )
				return;
				
			// set the selected property based on our object
			check.selected = this.m_obj[this.m_editVar.variable];
		}
		
		/*********************************************************************************/
		
		// Called when we click on a check box. We set the boolean variable on the object
		// that we're currently editing
		private function _onCheck( e:MouseEvent ):void
		{
			// get the checkbox
			var c:CheckBox = this.m_component as CheckBox;
			if ( c == null )	
				return;
			
			// set the prop
			this.m_obj[this.m_editVar.variable] = c.selected;
		}
		
	}

}