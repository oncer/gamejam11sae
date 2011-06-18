/**
 * GOEComponent.as
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
	import com.bit101.components.Component;
	import com.divillysausages.gameobjeditor.EditableVar;
	
	/**
	 * The base class for a Game Object Editor component
	 * @author Damian
	 */
	public class GOEComponent 
	{	
		
		/*********************************************************************************/
		
		protected var m_component:Component	= null;	// the minimalcomps component we have
		protected var m_editVar:EditableVar	= null;	// the editable var that we use for our info
		protected var m_obj:*				= null;	// the object that we're editing
		protected var m_spacing:Number		= 5.0;	// if we have a label, this is how much space to put between it
		
		/*********************************************************************************/
		
		/**
		 * The width of the component
		 */
		public function get width():Number { return ( this.m_component != null ) ? this.m_component.width : 0.0; }
		
		/**
		 * The height of the component
		 */
		public function get height():Number { return ( this.m_component != null ) ? this.m_component.height : 0.0; }
		
		/**
		 * The type of the component. Use the statics from the EditableTypes class
		 */
		public function get type():String { return this.m_editVar.type; }
		
		/**
		 * Does this component edit a variable that has read access?
		 */
		public function get hasReadAccess():Boolean { return this.m_editVar.hasReadAccess; }
		
		/*********************************************************************************/
		
		/**
		 * Creates the new component
		 * @param obj The object that we're editing
		 * @param variable All the info about the variable that we're editing
		 */
		public function GOEComponent( obj:*, variable:EditableVar )
		{
			// hold our object
			this.m_obj = obj;
			
			// hold our variable and get our type from it
			this.m_editVar = variable;
		}
		
		/**
		 * Destroys the component and clears it for garbage collection
		 */
		public function destroy():void
		{
			// remove the component
			if ( this.m_component != null && this.m_component.parent != null )
				this.m_component.parent.removeChild( this.m_component );
			
			// null our objects
			this.m_component 	= null;
			this.m_editVar		= null;
			this.m_obj			= null;
		}
		
		/**
		 * Updates the info on the component
		 */
		public function update():void
		{
		}
	}
	
}