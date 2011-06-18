/**
 * ComboBoxComponent.as
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
	import com.bit101.components.ComboBox;
	import com.bit101.components.Label;
	import com.divillysausages.gameobjeditor.EditableVar;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	
	/**
	 * The component we use when we're using static consts to edit our variable
	 * @author Damian
	 */
	public class ComboBoxComponent extends GOEComponent
	{
		
		/*********************************************************************************/
		
		private var m_label:Label = null; // the label for this component
		
		/*********************************************************************************/
		
		/**
		 * @inheritDoc
		 */
		override public function get width():Number { return this.m_label.width + this.m_spacing + this.m_component.width; }
		
		/*********************************************************************************/
		
		/**
		 * Creates a new ComboBoxComponent
		 * @param obj The object that we're dealing with
		 * @param variable The <code>EditableVar</code> object that holds our variable info
		 * @param parent The <code>DisplayObjectContainer</code> to add this component to
		 * @param x The component x position
		 * @param y The component y position
		 */	
		public function ComboBoxComponent( obj:*, variable:EditableVar, parent:DisplayObjectContainer = null, x:Number = 0.0, y:Number = 0.0 ) 
		{
			super( obj, variable );
			
			// create the label for the component
			this.m_label = new Label( parent, x, y, this.m_editVar.variable + ":" );
			x 			+= this.m_label.width + this.m_spacing; // move the x position along
			
			// add the combobox and fill it
			var combo:ComboBox 	= new ComboBox( parent, x, y, ( this.m_editVar.hasReadAccess ? this.m_obj[this.m_editVar.variable] : "" ), this.m_editVar.params.clazz );
			this.m_component	= combo;
			
			// add the event listener for it
			combo.addEventListener( Event.SELECT, this._onComboSelect );
		}
		
		/**
		 * Destroys the ComboBoxComponent and clears it for garbage collection
		 */
		override public function destroy():void 
		{
			// remove our label
			if( this.m_label.parent != null )
				this.m_label.parent.removeChild( this.m_label );
			this.m_label = null;
			
			// remove our event listener, then super it
			this.m_component.removeEventListener( Event.SELECT, this._onComboSelect );
			super.destroy();
		}
		
		/*********************************************************************************/
		
		// Called when we select a value from the combox box. We set the contant on the
		// object that we're currently editing
		private function _onComboSelect( e:Event ):void
		{
			var c:ComboBox 	= this.m_component as ComboBox;
			if ( c == null )
				return;
			var obj:Object	= c.selectedItem; // what was selected
		
			// set the prop
			this.m_obj[this.m_editVar.variable] = obj.data;
		}
		
	}

}