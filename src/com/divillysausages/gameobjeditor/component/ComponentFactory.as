/**
 * ComponentFactory.as
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
	import com.divillysausages.gameobjeditor.EditableTypes;
	import com.divillysausages.gameobjeditor.EditableVar;
	import flash.display.DisplayObjectContainer;
	
	/**
	 * The ComponentFactory will give us a component based on the type of variable we're looking at
	 * @author Damian
	 */
	public class ComponentFactory
	{
		
		/**
		 * Creates a new <code>GOEComponent</code> based on the type of variable that's passed in
		 * @param obj The object that we're dealing with
		 * @param variable The <code>EditableVar</code> object that holds our variable info
		 * @param parent The <code>DisplayObjectContainer</code> to add this component to
		 * @param x The component x position
		 * @param y The component y position
		 * @return The <code>GOEComponent</code> that was created for this variable, or null if 
		 * 			we couldn't find a component for the type
		 */	
		public static function getComponent( obj:*, variable:EditableVar, parent:DisplayObjectContainer = null, x:Number = 0.0, y:Number = 0.0 ):GOEComponent 
		{
			// return a different component based on the type
			if ( variable.type == EditableTypes.TYPE_CHECKBOX )
				return new CheckboxComponent( obj, variable, parent, x, y );
			else if ( variable.type == EditableTypes.TYPE_COLOUR )
				return new ColourComponent( obj, variable, parent, x, y );
			else if ( variable.type == EditableTypes.TYPE_INPUT )
				return new InputComponent( obj, variable, parent, x, y );
			else if ( variable.type == EditableTypes.TYPE_STATIC_CONSTS )
				return new ComboBoxComponent( obj, variable, parent, x, y );
			else if ( variable.type == EditableTypes.TYPE_SLIDER )
				return new SliderComponent( obj, variable, parent, x, y );
			else if ( variable.type == EditableTypes.TYPE_STEPPER )
				return new StepperComponent( obj, variable, parent, x, y );
			else if ( variable.type == EditableTypes.TYPE_WATCH )
				return new WatchComponent( obj, variable, parent, x, y );
				
			// couldn't find it
			return null;
		}
		
	}

}