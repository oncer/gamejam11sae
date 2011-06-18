/**
 * Editor.as
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
	import com.divillysausages.gameobjeditor.event.GameObjEvent;
	import com.divillysausages.gameobjeditor.event.SelectObjEvent;
	import com.divillysausages.gameobjeditor.event.ToggleEvent;
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.FileReference;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	/**
	 * The main class that we use to parse a class and take out all the editable
	 * variables. When we select an object that we have info for, we generate the
	 * components needed to edit our variables.
	 * 
	 * @author Damian Connolly
	 */
	public class Editor
	{
		
		/*********************************************************************************/
		
		private var m_stage:Stage 				= null;	// a reference to the stage
		private var m_parser:Parser				= null; // the parser that we use to parse our classes
		private var m_classDB:Dictionary		= null;	// the class db that holds the edit info for our different classes
		private var m_editObjs:Array			= null;	// the list of objects that we're currently editing
		private var m_currObj:Object			= null;	// the current object that we're editing
		private var m_updateOnlyWatch:Boolean	= true; // when updating every frame, should we update everything?
		private var m_clickToSelect:Boolean		= true;	// can we click to select objects?
		private var m_matchParent:Boolean		= true;	// match against the parent when selecting objects?
		private var m_removeObj:Object			= null; // when removing an object, this is set if it's the current editing object
		
		private var m_gui:GUI						 	= null;	// the gui for the editor
		private var m_currObjHighlight:ObjHighlighter 	= null;	// the shape to draw our tracking into
		
		/*********************************************************************************/
		
		/**
		 * A reference to the main Stage
		 */
		public function get stage():Stage { return this.m_stage; }
		
		/**
		 * The gui for the <code>Editor</code>, if you want to make changes to it
		 */
		public function get gui():GUI { return this.m_gui; }
		
		/**
		 * Makes the <code>Editor</code> visible and adds it to the stage
		 */
		public function get visible():Boolean { return this.m_gui.visible; }
		public function set visible( b:Boolean ):void 
		{
			this.m_gui.visible = b;
		}
		
		/**
		 * @private
		 * Sets the <code>x</code> position of the <code>Editor</code> and snaps
		 * to the edge if we go outside it
		 */
		public function get x():Number { return this.m_gui.x; }
		public function set x( n:Number ):void
		{
			this.m_gui.x = n;
		}
		
		/**
		 * @private
		 * Sets the <code>y</code> position of the <code>Editor</code> and snaps
		 * to the edge if we go outside it
		 */
		public function get y():Number { return this.m_gui.y; }
		public function set y( n:Number ):void
		{
			this.m_gui.y = n;
		}
		
		/**
		 * When updating every frame, should we update everything or only the
		 * "watch" variable types?
		 * 
		 * @default true
		 */
		public function set updateOnlyWatchVars( b:Boolean ):void
		{
			this.m_updateOnlyWatch = b;
		}
		
		/**
		 * Get the current object that we're editing
		 * 
		 * @default null
		 */
		public function get currentObject():*
		{
			var obj:Object = this.m_gui.currSelectedItem;
			if ( obj == null || obj.data == undefined )
				return null;
			return obj.data;
		}
		
		/**
		 * Should we highlight the current object when it's selected?
		 * 
		 * @default false
		 */
		public function set highlightCurrentObject( b:Boolean ):void
		{
			// update the gui as well
			this.m_currObjHighlight.highlight 	= b;			
			this.m_gui.highlightCurrObject 		= b;
		}
		
		/**
		 * The size of the line when we're highlighting the current object
		 * 
		 * @default 1.0
		 */
		public function set highlightCurrentLineSize( n:Number ):void
		{
			this.m_currObjHighlight.lineSize = n;
		}
		
		/**
		 * The colour of the line when we're highlighting the current object
		 * 
		 * @default 0xff0000
		 */
		public function set highlightCurrentLineColour( u:uint ):void
		{
			this.m_currObjHighlight.lineColour = u;
		}
		
		/**
		 * Can we click to select our object (DisplayObjects only)
		 * 
		 * @default true
		 */
		public function set clickToSelect( b:Boolean ):void
		{
			// update the gui as well
			this.m_clickToSelect 		= b;			
			this.m_gui.clickToSelect 	= b;
		}
		
		/**
		 * When clickToSelect is enabled, should we match against the parent of the clicked
		 * object (from the MouseEvent). Helps deal with clicking on children when their
		 * parents are the ones being edited
		 * 
		 * @default true
		 */
		public function set clickToSelectMatchParent( b:Boolean ):void
		{
			this.m_matchParent = b;
		}
		
		/*********************************************************************************/
		
		/**
		 * Creates the <code>Editor</code>
		 * 
		 * @param stage A reference to the <code>Stage</code>
		 */
		public function Editor( stage:Stage ) 
		{			
			// set the stage and the event listener for new objects
			this.m_stage = stage;
			this.m_stage.addEventListener( Event.ADDED, this._onAdded, false, 0, true );
			this.m_stage.addEventListener( Event.REMOVED, this._onRemoved, false, 0, true );
			this.m_stage.addEventListener( Event.ENTER_FRAME, this._onEnterFrame, false, 0, true );
			this.m_stage.addEventListener( MouseEvent.CLICK, this._onClick, false, 0, true );
			
			// create the gui and add the event listeners
			this.m_gui = new GUI( this );
			this.m_gui.addEventListener( GameObjEvent.SELECT_OBJECT, this._onSelectObject );
			this.m_gui.addEventListener( GameObjEvent.HIGHLIGHT_CURR_OBJECT, this._onHighlightCurr );
			this.m_gui.addEventListener( GameObjEvent.CLICK_TO_SELECT, this._onClickToSelect );
			this.m_gui.addEventListener( GameObjEvent.SAVE_CURR_OBJECT, this._onSaveObj );
			this.m_gui.addEventListener( GameObjEvent.SAVE_ALL_OBJECTS, this._onSaveAll );
			
			// create our class parser
			this.m_parser = new Parser( this );
			
			// create our edit db
			this.m_classDB = new Dictionary( true );
			
			// create our editing array
			this.m_editObjs = new Array;
			
			// create our current object highlighter
			this.m_currObjHighlight = new ObjHighlighter( this.m_stage );
			
			// set some of our props
			this.clickToSelect 			= true;
			this.highlightCurrentObject = false;
			
			// we're invisible at the start
			this.visible = false;
		}
		
		/**
		 * Registers a class to be parsed for editable variables
		 * 
		 * @param clazz The <code>Class</code> that we want to parse
		 */
		public function registerClass( clazz:Class ):void
		{			
			// get our parser to parse the class
			var v:Vector.<EditableVar> = this.m_parser.parse( clazz );
			
			// add it to the edit db
			this.m_classDB[clazz] = v;
		}
		
		/**
		 * Registers an object so it can be edited. If the object is already in our edit
		 * list, it's ignored. If it's class hasn't been previously registered, it's ignored.
		 * 
		 * @param obj The object that we want to register so we can edit it
		 */
		public function registerObject( obj:* ):void
		{
			// get the class and see if the class registered
			var name:String	= getQualifiedClassName( obj );
			var c:Class 	= getDefinitionByName( name ) as Class;
			if ( this.m_classDB[c] == undefined )
				return;
			
			// check to see if we already have it
			var len:int = this.m_editObjs.length;
			for ( var i:int = 0; i < len; i++ )
			{
				if ( this.m_editObjs[i].data == obj )
					return; // we already have this object in our edit array - ignore
			}
			
			// we don't have it, so add it (get the name or create one)
			var displayName:String 	= ( "name" in obj ) ? obj.name : int( Math.random() * 10000.0 ) + ""; // a random name for the obj
			
			// set up the class name
			var className:String	= name;
			var colon:int 			= name.indexOf( "::" );
			if ( colon != -1 )
				className = name.substring( colon + 2 );
				
			// add it to our edit objects array	
			var obj:Object = { label:"[" + className + "]: " + displayName, data:obj };
			this.m_editObjs.push( obj ); // an object that we have edit info for
			
			// add it to the available array on the gui
			this.m_gui.addObjectToAvailable( obj );
		}
		
		/**
		 * Unregisters an object from the editable array.
		 * 
		 * @param obj The object that we want to unregister
		 */
		public function unregisterObject( obj:* ):void
		{
			// check to see if we have it
			var len:int 		= this.m_editObjs.length;
			var editObj:Object	= null;
			for ( var i:int = 0; i < len; i++ )
			{
				if ( this.m_editObjs[i].data == obj )
				{
					editObj = this.m_editObjs[i];
					break;
				}
			}
			
			// we don't have it
			if ( editObj == null )
				return;
				
			// if it's the current object, set the remove and return as
			// this could be called in the middle of an update, which would
			// throw an error
			if ( editObj.data == this.m_currObj )
				this.m_removeObj = editObj;
			else
				this._removeEditObject( editObj );
		}
		
		/**
		 * Traces out a message to the console and the log panel
		 * 
		 * @param msg The message we're tracing
		 * @param level The level of the message; this is used to colour code trace outputs if your IDE supports it
		 */
		public function log( msg:String, level:int = 1 ):void
		{
			this.m_gui.log( msg, level );
		}
		
		/*********************************************************************************/
		
		// removes an object from our edit queue. this is either called immediately
		// if the object we're removing is not the current object, or at the end of
		// the frame if it is
		private function _removeEditObject( editObj:* ):void
		{
			// if it's our current object, remove the edit
			if ( this.m_currObj == editObj.data )
			{
				this.m_gui.currSelectedItem = null; // clear the selected item on the combobox
				this._clearPrevious();
			}
			
			// get the index
			var index:int = this.m_editObjs.indexOf( editObj );
			if ( index == -1 )
				return;
				
			// remove it from our array and available gui array
			var obj:* = this.m_editObjs.splice( index, 1 )[0]; // splice returns an array
			this.m_gui.removeObjectFromAvailable( obj );
			
			// clear the remove object variable
			this.m_removeObj = null;
		}
		
		// clears all the previous components for an object
		private function _clearPrevious():void
		{			
			// clear the gui
			this.m_gui.clearPreviousEditComponents();
			
			// clear the current obj
			this.m_currObj = null;
		}
		
		// adds the edit component for a variable based on the params in it's EditableVar class
		private function _addDebug( obj:Object ):void
		{
			// get the class for the object
			var name:String	= getQualifiedClassName( obj );
			var c:Class 	= getDefinitionByName( name ) as Class;
			
			// get the vector of editable vars
			var v:Vector.<EditableVar> 	= this.m_classDB[c];
			
			// update the gui
			this.m_gui.addEditComponentsForObject( obj, v );
			
			// hold the current
			this.m_currObj = obj;
		}
		
		/*********************************************************************************/
		
		// Event listener functions
		
		// Called when something gets added in the game. We look to see if we have it's class
		// in the Editor. If so, then we add it to the list of objects that we can edit
		private function _onAdded( e:Event ):void
		{
			this.registerObject( e.target );
		}
		
		// Called when something gets removed in the game. We look to see if we have the object
		// in our list of editable objects, and if so, remove it
		private function _onRemoved( e:Event ):void
		{
			this.unregisterObject( e.target );
		}
		
		// called every frame - update the variables that we have on the current object
		private function _onEnterFrame( e:Event ):void
		{
			// if we've no current object, do nothing
			if ( this.m_currObj == null )
				return;
				
			// tell the object highlighter to update
			this.m_currObjHighlight.update( this.m_currObj );
			
			// update the gui
			this.m_gui.updateComponentValues( this.m_currObj, this.m_updateOnlyWatch );
			
			// if our remove object was set, then we're trying to remove the
			// current object, so do so now
			if ( this.m_removeObj != null )
				this._removeEditObject( this.m_removeObj );
		}
		
		// Called when we select an object from the dropdown menu of available objects. We remove
		// any previous components, and add the components for the new one (or just quit if none
		// was selected)
		private function _onSelectObject( e:SelectObjEvent ):void
		{
			this._showEditForObject( e.object );
		}
		
		// shows the edit data for the an object
		private function _showEditForObject( obj:* ):void
		{
			// clear the previous
			this._clearPrevious();
			
			// if our object is null, revert to the base state and return
			if ( obj == null )
			{
				this.m_currObjHighlight.clear(); // clear the current object highlighter
				return;
			}
				
			// get the object
			this._addDebug( obj.data );
			
			// set the position (so it snaps)
			this.x = this.x;
			this.y = this.y;
		}
		
		// called when we click on the "highlight current object" checkbox - turn on/off the highlighting
		private function _onHighlightCurr( e:ToggleEvent ):void
		{
			this.m_currObjHighlight.highlight = e.value;
		}
		
		// called when we click on the "click to select" checkbox - toggle the functionality
		private function _onClickToSelect( e:ToggleEvent ):void
		{
			this.m_clickToSelect = e.value;
		}
		
		// called when the user clicks somewhere on the stage
		private function _onClick( e:MouseEvent ):void
		{
			if ( !this.m_clickToSelect )
				return;
				
			// go through the objects we have for editing and see did we click on one of them
			var len:int = this.m_editObjs.length;
			for ( var i:int = 0; i < len; i++ )
			{
				// if the data is our target, then show the edit info for it
				if ( this.m_editObjs[i].data == e.target ||
					( this.m_matchParent && this.m_editObjs[i].data == e.target.parent ) )
				{
					this._showEditForObject( this.m_editObjs[i] );
					
					// set the current object on the available list
					this.m_gui.currSelectedItem = this.m_editObjs[i];
					return;
				}
			}
		}
		
		// called when we click on the "save obj" button - save the current objects changed variables
		private function _onSaveObj( e:Event ):void
		{
			// if we don't have a current object, do nothing
			if ( this.m_currObj == null )
			{
				this.log( "There's no current object, can't save it", 3 );
				return;
			}
				
			// create the XML for the current object
			var x:XML = this._createParamsXML( this.m_currObj );
			if ( x == null )
				return;
				
			// copy it to the clipboard
			Clipboard.generalClipboard.setData( ClipboardFormats.TEXT_FORMAT, x );
			
			// create a file object and save it
			var file:FileReference = new FileReference;
			file.save( x, "params.xml" );
			
			// log it
			this.log( "The XML for the current object was copied to the clipboard and saved to XML" );
		}
		
		// called when we click on the "save all" button - save all the object's changed variables
		private function _onSaveAll( e:Event ):void
		{
			// if we've nothing to edit, we can't save
			if ( this.m_editObjs.length == 0 )
			{
				this.log( "We've no editable objects, can't save", 3 );
				return;
			}
				
			// create the XML for the current everything
			var game:XML = new XML( <game /> );
			
			// get all the xml for each obj
			var len:int = this.m_editObjs.length;
			for ( var i:int = 0; i < len; i++ )
			{
				var x:XML = this._createParamsXML( this.m_editObjs[i].data );
				if ( x == null )
					continue;
					
				// add it to the game
				game.appendChild( x );
			}
				
			// copy it to the clipboard
			Clipboard.generalClipboard.setData( ClipboardFormats.TEXT_FORMAT, game );
			
			// create a file object and save it
			var file:FileReference = new FileReference;
			file.save( game, "params.xml" );
			
			// log it
			this.log( "The XML for all the objects was copied to the clipboard and saved to XML" );
		}
		
		// creates an XML object that defines the editable params for an object
		private function _createParamsXML( obj:Object ):XML
		{	
			if ( obj == null )
				return null;
				
			// get the list of editable vars in this class
			var name:String				= getQualifiedClassName( obj );
			var c:Class 				= getDefinitionByName( name ) as Class;
			var v:Vector.<EditableVar> 	= this.m_classDB[c];
			if ( v == null )
				return null;
				
			// create the XML object for the obj
			var nodeName:String = ( "name" in obj ) ? obj.name : int( Math.random() * 10000 ) + "";
			var x:XML 			= new XML( <{nodeName} /> );
			for each( var ev:EditableVar in v )
			{
				// create the XML for the param
				var param:XML = new XML( <{ev.variable} /> );
				param.appendChild( obj[ev.variable] );
				
				// add it to the object XML
				x.appendChild( param );
			}
			return x;
		}
		
	}

}