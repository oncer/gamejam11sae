/**
 * GUI.as
 * Damian Connolly
 * version 1.3.1
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
	import com.bit101.components.CheckBox;
	import com.bit101.components.ComboBox;
	import com.bit101.components.PushButton;
	import com.bit101.components.TextArea;
	import com.bit101.components.Window;
	import com.divillysausages.gameobjeditor.component.ComponentFactory;
	import com.divillysausages.gameobjeditor.component.GOEComponent;
	import com.divillysausages.gameobjeditor.event.GameObjEvent;
	import com.divillysausages.gameobjeditor.event.SelectObjEvent;
	import com.divillysausages.gameobjeditor.event.ToggleEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * The GUI for the AS3 Game Object Editor
	 * @author Damian
	 */
	public class GUI extends Window
	{
		
		/*********************************************************************************/
		
		private var m_editor:Editor						= null;	// a reference to the Editor that created us
		private var m_currComps:Vector.<GOEComponent>	= null;	// the current list of component that we have
		private var m_compLog:TextArea					= null;	// the logging textarea, to show debug messages
		private var m_compAvailable:ComboBox			= null;	// the component that lets us select which component we're editing
		private var m_compShowCurr:CheckBox				= null; // the component that lets us set whether to highlight the current object
		private var m_compClickSelect:CheckBox			= null;	// the component that lets us set whether we can click to select the current object
		private var m_compSaveObj:PushButton			= null;	// the button to save the current object's changed params
		private var m_compSaveAll:PushButton			= null;	// the button to save all our objects changed params
		private var m_spacing:Number					= 5.0;	// the spacing between the different components
		private var m_posX:Number						= 0.0;	// the current x value for positioning components
		private var m_posY:Number						= 0.0;	// the current y value for positioning components
		
		/*********************************************************************************/
		
		/**
		 * Makes the <code>GUI</code> visible and adds it to the stage
		 */
		override public function get visible():Boolean { return super.visible; }
		override public function set visible( b:Boolean ):void 
		{
			super.visible = b;
			if( this.visible && this.m_editor != null && this.m_editor.stage != null )
				this.m_editor.stage.addChild( this );
			else if( !this.visible && this.parent != null )
				this.parent.removeChild( this );
		}
		
		/**
		 * @private
		 * Sets the <code>x</code> position of the <code>GUI</code> and snaps
		 * to the edge if we go outside it
		 */
		override public function set x( n:Number ):void
		{
			// snap to int value so the text remains sharp
			super.x = int( n );
			
			// no stage = no snapping
			if ( this.m_editor == null || this.m_editor.stage == null )
				return;
			
			// snap to the edge
			if ( this.x < 10.0 )
				super.x = 0.0;
			else if ( this.x + this.width > this.m_editor.stage.stageWidth - 10.0 )
				super.x = int( this.m_editor.stage.stageWidth - this.width );
		}
		
		/**
		 * @private
		 * Sets the <code>y</code> position of the <code>GUI</code> and snaps
		 * to the edge if we go outside it
		 */
		override public function set y( n:Number ):void
		{
			super.y = int( n );
			
			// no stage = no snapping
			if ( this.m_editor == null || this.m_editor.stage == null )
				return;
			
			// snap to the edge
			if ( this.y < 10.0 )
				super.y = 0.0;				
			else if ( this.y + this.height > this.m_editor.stage.stageHeight - 10.0 )
				super.y = int( this.m_editor.stage.stageHeight - this.height );
		}
		
		/**
		 * Returns the currently selected item, if we have one, in our editable dropdown
		 */
		public function get currSelectedItem():* { return this.m_compAvailable.selectedItem; }
		public function set currSelectedItem( obj:* ):void
		{
			this.m_compAvailable.selectedItem = obj;
		}
		
		/**
		 * Should we highlight the current object or not?
		 */
		public function set highlightCurrObject( b:Boolean ):void
		{
			this.m_compShowCurr.selected = b;
		}
		
		/**
		 * Can we click to select the current objects?
		 */
		public function set clickToSelect( b:Boolean ):void
		{
			this.m_compClickSelect.selected = b;
		}
		
		/*********************************************************************************/
		
		/**
		 * Creates the <code>GUI</code>
		 * 
		 * @param editor A reference to the <code>Editor</code> that created us
		 */
		public function GUI( editor:Editor ) 
		{
			// call our super and set some props
			super( null, 0.0, 0.0, "GameEditor" );
			this.draggable 			= true;
			this.hasMinimizeButton	= true;
			this.alpha				= 0.8;
			
			// hold our editor
			this.m_editor = editor;
			
			// our current comps dictionary
			this.m_currComps = new Vector.<GOEComponent>;
			
			// set the initial position vars
			this.m_posX	= this.m_spacing;
			this.m_posY	= this.m_spacing;
			
			// create our log
			this.m_compLog			= new TextArea( this, this.m_posX, this.m_posY, "Log\n" );
			this.m_compLog.editable	= false;
			this.m_posY				+= this.m_compLog.height + this.m_spacing;
			
			// create the combobox that lets us pick which object we're editing
			this.m_compAvailable 		= new ComboBox( this, this.m_posX, this.m_posY, "Available Objects:", null );
			this.m_compAvailable.width	= this.m_compLog.width;
			this.m_posY					+= this.m_compAvailable.height + this.m_spacing;
			this.m_compAvailable.addEventListener( Event.SELECT, this._onEditingSelect );
			
			// create the highlight checkbox that lets us set whether to highlight the current object or not
			this.m_compShowCurr	= new CheckBox( this, this.m_posX, this.m_posY, "Highlight curr", this._onShowCurr );
			this.m_posX			+= this.m_compShowCurr.width + this.m_spacing;
			
			// create the click to select checkbox that lets us set whether we can select objects by clicking on them
			this.m_compClickSelect	= new CheckBox( this, this.m_posX, this.m_posY, "Click to select", this._onClickSelect );
			this.m_posX				= this.m_spacing;
			this.m_posY				+= this.m_compClickSelect.height + this.m_spacing;
			
			// creates the save obj button
			this.m_compSaveObj 			= new PushButton( this, this.m_posX, this.m_posY, "Save obj", this._onSaveObj );
			this.m_compSaveObj.enabled	= false;
			this.m_posX					+= this.m_compSaveObj.width + this.m_spacing;
			
			// creates the save all button
			this.m_compSaveAll 	= new PushButton( this, this.m_posX, this.m_posY, "Save all objs", this._onSaveAll );
			this.m_posX			= this.m_spacing;
			this.m_posY			+= this.m_compSaveAll.height + this.m_spacing * 4.0;
			
			// update our size (and set our width, which doesn't seem to work automatically here)
			this._updateSize();
			this.width = this.m_compSaveObj.width * 2.0 + this.m_spacing * 3.0;
		}
		
		/**
		 * @private
		 * 
		 * Overriding the <code>stopDrag()</code> method to allow for edge
		 * snapping when we drag the <code>Editor</code>
		 */
		override public function stopDrag():void 
		{
			// to call the snapping position
			super.stopDrag();
			this.x = this.x;
			this.y = this.y;
		}
		
		/**
		 * Traces out a message to the console and the log panel
		 * 
		 * @param msg The message we're tracing
		 * @param level The level of the message; this is used to colour code trace outputs if your IDE supports it
		 */
		public function log( msg:String, level:int = 1 ):void
		{
			trace( level + ":" + msg );
			this.m_compLog.text += msg + "\n";
			
			// append text doesn't seem to want to work, which is why the text is set with +=
			//this.m_compLog.textField.appendText( msg + "\n" );
		}
		
		/**
		 * Adds an object to the available array
		 * @param obj The object to add
		 */
		public function addObjectToAvailable( obj:* ):void
		{
			this.m_compAvailable.addItem( obj );
		}
		
		/**
		 * Removes an object from the available array
		 * @param obj The object to remove
		 */
		public function removeObjectFromAvailable( obj:* ):void
		{
			this.m_compAvailable.removeItem( obj );
		}
		
		/**
		 * Clears all the previous components for an object
		 */ 
		public function clearPreviousEditComponents():void
		{
			// destroy our current components
			for each( var comp:GOEComponent in this.m_currComps )
				comp.destroy();
			this.m_currComps.length = 0;
			
			// set the posX and posY
			this.m_posX = this.m_spacing;
			this.m_posY = this.m_compSaveObj.y + this.m_compSaveObj.height + this.m_spacing * 4.0;
			
			// update our size
			this._updateSize();
		}
		
		/**
		 * Adds the edit components for an object based on the params in it's EditableVar class
		 * @param obj	The object that we're adding edit components for
		 * @param editableVars	The Vector list of EditableVar info for the object
		 */
		public function addEditComponentsForObject( obj:Object, editableVars:Vector.<EditableVar> ):void
		{
			// go through the list of vars we have for the object and add components for
			// each one
			for each( var editVar:EditableVar in editableVars )
			{
				// get the component
				var comp:GOEComponent = ComponentFactory.getComponent( obj, editVar, this, this.m_posX, this.m_posY );
				if ( comp == null )
				{
					this.log( "Couldn't a component for type " + editVar.type + " and variable " + editVar.variable, 3 );
					continue;
				}
				
				// update the current position and add it to the array
				this.m_posY += comp.height + this.m_spacing;
				this.m_currComps.push( comp );
			}
			
			// update the width and height
			this._updateSize();
		}
		
		/**
		 * Updates the values for the current object that we're displaying
		 * @param obj The object that we're updating the values for
		 * @param updateOnlyWatch Update only the watch variables, or update everything?
		 */
		public function updateComponentValues( obj:*, updateOnlyWatch:Boolean = true ):void
		{
			// if we've no current object, do nothing
			if ( obj == null )
				return;
				
			// go through our current components and update them
			for each( var comp:GOEComponent in this.m_currComps )
			{
				// if it's write-only, then ignore
				if ( !comp.hasReadAccess )
					continue;
					
				// if it's a watch type component, then update it, or
				// update them all if updateOnlyWatch is false
				if ( ( updateOnlyWatch && comp.type == EditableTypes.TYPE_WATCH ) || !updateOnlyWatch )
					comp.update();
			}
		}
		
		/*********************************************************************************/
		
		/**
		 * @private
		 * 
		 * Overriding the minimize event listener to allow for edge snapping when we
		 * minimize/maximize the <code>GUI</code> window
		 * 
		 * @param event The <code>MouseEvent</code> passed along from the button
		 */
		override protected function onMinimize( event:MouseEvent ):void 
		{
			super.onMinimize(event);
			this.x = this.x;
			this.y = this.y;
		}
		
		/*********************************************************************************/
		
		// updates the width and height of the GUI depending on what it contains
		private function _updateSize():void
		{
			this.height = this.m_posY + this.titleBar.height + this.m_spacing * 2.0;
			this.width 	= this.content.width + this.m_spacing * 2.0;
		}
		
		// Called when we select an object from the dropdown menu of available objects. We remove
		// any previous components, and add the components for the new one (or just quit if none
		// was selected)
		private function _onEditingSelect( e:Event ):void
		{
			// set the debug info for the selected item
			var c:ComboBox = e.target as ComboBox;
			if ( c == null )
				return;
			
			// enable/disable the save obj button if we have an obj
			this.m_compSaveObj.enabled 	= ( c.selectedItem != null );
				
			// dispatch our event with the selected object
			this.dispatchEvent( new SelectObjEvent( GameObjEvent.SELECT_OBJECT, c.selectedItem ) );
		}
		
		// called when we click on the "highlight current object" checkbox - turn on/off the highlighting
		private function _onShowCurr( e:MouseEvent ):void
		{
			// get the checkbox
			var c:CheckBox = e.target as CheckBox;
			if ( c == null )
				return;
				
			// dispatch our event with the new value
			this.dispatchEvent( new ToggleEvent( GameObjEvent.HIGHLIGHT_CURR_OBJECT, c.selected ) );
		}
		
		// called when we click on the "click to select" checkbox - turn on/off this functionality
		private function _onClickSelect( e:MouseEvent ):void
		{
			// get the checkbox
			var c:CheckBox = e.target as CheckBox;
			if ( c == null )
				return;
				
			// dispatch our event with the new value
			this.dispatchEvent( new ToggleEvent( GameObjEvent.CLICK_TO_SELECT, c.selected ) );
		}
		
		// called when we click on the "save obj" button - save the current objects changed variables
		private function _onSaveObj( e:MouseEvent ):void
		{
			this.dispatchEvent( new Event( GameObjEvent.SAVE_CURR_OBJECT ) );
		}
		
		// called when we click on the "save all" button - save all the object's changed variables
		private function _onSaveAll( e:MouseEvent ):void
		{
			this.dispatchEvent( new Event( GameObjEvent.SAVE_ALL_OBJECTS ) );
		}
		
	}

}