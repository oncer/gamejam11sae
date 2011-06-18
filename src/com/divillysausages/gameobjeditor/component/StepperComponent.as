/**
 * StepperComponent.as
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
	import com.bit101.components.NumericStepper;
	import com.divillysausages.gameobjeditor.EditableVar;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	
	/**
	 * The default component we use to edit Numbers, ints and uints
	 * @author Damian
	 */
	public class StepperComponent extends GOEComponent
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
		 * Creates a new StepperComponent
		 * @param obj The object that we're dealing with
		 * @param variable The <code>EditableVar</code> object that holds our variable info
		 * @param parent The <code>DisplayObjectContainer</code> to add this component to
		 * @param x The component x position
		 * @param y The component y position
		 */		
		public function StepperComponent( obj:*, variable:EditableVar, parent:DisplayObjectContainer = null, x:Number = 0.0, y:Number = 0.0 ) 
		{
			super( obj, variable );
			
			// create the label for the component
			this.m_label = new Label( parent, x, y, this.m_editVar.variable + ":" );
			x 			+= this.m_label.width + this.m_spacing; // move the x position along
			
			// add the numerical stepper
			var stepper:NumericStepper 	= new NumericStepper( parent, x, y, this._onStepChange );
			this.m_component			= stepper;
			stepper.minimum				= this.m_editVar.params.min;
			stepper.maximum				= this.m_editVar.params.max;
			stepper.step				= this.m_editVar.params.step;
			if ( this.m_editVar.hasReadAccess )
				stepper.value = this.m_obj[this.m_editVar.variable];
		}
		
		/**
		 * Destroys the StepperComponent and clears it for garbage collection
		 */
		override public function destroy():void 
		{
			// remove our label
			if( this.m_label.parent != null )
				this.m_label.parent.removeChild( this.m_label );
			this.m_label = null;
			
			// remove our event listener, then super it
			this.m_component.removeEventListener( Event.CHANGE, this._onStepChange );
			super.destroy();
		}
		
		/**
		 * Updates the StepperComponent to always match our object's variable
		 */
		override public function update():void 
		{
			// get the component as a stepper
			var s:NumericStepper = this.m_component as NumericStepper;
			if ( s == null )
				return;
				
			// set the value
			s.value = this.m_obj[this.m_editVar.variable];
		}
		
		/*********************************************************************************/
		
		// Called when our stepper changes. We set the number variable on the
		// object that we're currently editing
		private function _onStepChange( e:Event ):void
		{
			// get the stepper
			var s:NumericStepper = this.m_component as NumericStepper;
			if ( s == null )
				return;
			
			// set the prop
			this.m_obj[this.m_editVar.variable] = s.value;
		}
		
	}

}