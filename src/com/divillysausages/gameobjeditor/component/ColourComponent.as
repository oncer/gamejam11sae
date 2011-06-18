/**
 * ColourComponent.as
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
	import com.bit101.components.ColorChooser;
	import com.bit101.components.Label;
	import com.divillysausages.gameobjeditor.EditableVar;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	
	/**
	 * The component we use when we're looking to select colours (uints)
	 * @author Damian
	 */
	public class ColourComponent extends GOEComponent
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
		 * Creates a new ColourComponent
		 * @param obj The object that we're dealing with
		 * @param variable The <code>EditableVar</code> object that holds our variable info
		 * @param parent The <code>DisplayObjectContainer</code> to add this component to
		 * @param x The component x position
		 * @param y The component y position
		 */
		public function ColourComponent( obj:*, variable:EditableVar, parent:DisplayObjectContainer = null, x:Number = 0.0, y:Number = 0.0 ) 
		{
			super( obj, variable );
			
			// create the label for the component
			this.m_label = new Label( parent, x, y, this.m_editVar.variable + ":" );
			x 			+= this.m_label.width + this.m_spacing; // move the x position along
			
			// add the colour picker
			var colour:ColorChooser = new ColorChooser( parent, x, y, 0, this._onChooseColour );
			colour.usePopup 		= true; // use a popup to make it easier to choose the colour
			this.m_component		= colour;
			if ( this.m_editVar.hasReadAccess )
				colour.value = this.m_obj[this.m_editVar.variable];
		}
		
		/**
		 * Destroys the ColourComponent and clears it for garbage collection
		 */
		override public function destroy():void 
		{
			// remove our label
			if( this.m_label.parent != null )
				this.m_label.parent.removeChild( this.m_label );
			this.m_label = null;
			
			// remove our event listener, then super it
			this.m_component.removeEventListener( Event.CHANGE, this._onChooseColour );
			super.destroy();
		}
		
		/**
		 * Updates the ColourComponent to always match our object's variable
		 */
		override public function update():void 
		{
			// get the component as a colour chooser
			var c:ColorChooser = this.m_component as ColorChooser;
			if ( c == null )
				return;
				
			// set the colour
			c.value = this.m_obj[this.m_editVar.variable];
		}
		
		/*********************************************************************************/
		
		// Called when we click on a colour box. We set the colour variable on the object
		// that we're currently editing
		private function _onChooseColour( e:Event ):void
		{
			// get the colour chooser
			var c:ColorChooser = this.m_component as ColorChooser;
			if ( c == null )
				return;
			
			// set the prop
			this.m_obj[this.m_editVar.variable] = c.value;
		}
		
	}

}