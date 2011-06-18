/**
 * Parser.as
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
package com.divillysausages.gameobjeditor 
{
	
	/**
	 * Parses a class <code>XML</code> file and takes out all the editable meta-tagged vars
	 * 
	 * @author Damian Connolly
	 */
	public class Parser
	{
		
		/*********************************************************************************/
		
		private var m_editor:Editor		= null;	// a reference to the Editor that created us
		private var m_db:DescribeTypeDB	= null;	// our describeType() db, that will cache our calls for us
		
		/*********************************************************************************/
		
		/**
		 * Creates our <code>Parser</code>
		 * 
		 * @param editor A reference to the <code>Editor</code> class that created us
		 */
		public function Parser( editor:Editor )
		{
			// hold our editor
			this.m_editor = editor;
			
			// create our describe type db
			this.m_db = new DescribeTypeDB;
		}
		
		/**
		 * Parses a classes description and extracts all the variables that have
		 * been tagged with the <code>[Editable]</code> meta data
		 * 
		 * @param clazz	The class that we're parsing
		 * 
		 * @return	A Vector list of EditableVar objects for the class
		 */
		public function parse( clazz:Class ):Vector.<EditableVar>
		{
			// describeType() the class
			var xml:XML = this.m_db.describeType( clazz );
			
			// create our vector to hold the things we can change
			var v:Vector.<EditableVar> = new Vector.<EditableVar>;
			
			// look for public variables, then accessors
			this._explore( xml, v, "variable" );
			this._explore( xml, v, "accessor" );
			
			// sort the vector by alphabetical order
			v.sort( this._sort );
			
			// return the vector
			return v;
		}
		
		/*********************************************************************************/
		
		// Explores an XML object to pull out all the editable vars. The node parameter
		// determines what we're looking at; variables or accessors
		private function _explore( xml:XML, vector:Vector.<EditableVar>, node:String ):void
		{
			for each( var varXML:XML in xml.factory[node] )
				this._exploreNode( xml, varXML, vector );
		}
		
		// Explores a particular node in an XML for editable vars
		private function _exploreNode( xml:XML, varXML:XML, vector:Vector.<EditableVar> ):void
		{	
			// if we already have this variable in the vector, ignore it. this can happen
			// if we add [Editable] metadata for parameters that we don't have in the class,
			// (e.g. if we extend Sprite and we can to edit the x, or y), as to do this, I
			// edit the XML but I can't guarantee if we've already treated the node or not
			for each( var ev:EditableVar in vector )
				if ( ev.variable == varXML.@name )
					return;
					
			// loop through the meta data
			for each ( var meta:XML in varXML.metadata )
			{
				// if the meta data isn't [Editable], do nothing
				if ( meta.@name != "Editable" )
					continue;
					
				// if the metadata has a "field" parameter, then it's a tag that's
				// been added for a variable that we don't have in this class (e.g.
				// if you extend Sprite, and you want to add the x, or y variables)
				// so we look for it in the variables and accessors of the class, and
				// modify it's XML node to include the meta data (minus the "field"
				// declaration)
				if ( meta.arg.(@key == "field") != undefined )
				{
					// hold the node name
					var nodeName:String = meta.arg.(@key == "field").@value;
					var i:int			= 0;
					var metaArg:XML		= null;
					
					// look for it in the variables
					if ( xml.factory.variable.(@name == nodeName) != undefined )
					{
						// remove the "field" meta argument, otherwise we'll go into
						// an infinite loop
						i = 0;
						for each( metaArg in meta.arg )
						{
							if ( metaArg.@key == "field" )
								break;
							i++;
						}
						delete meta.children()[i]; // remove the arg node
						
						// append the meta data to the node, then explore it
						xml.factory.variable.(@name == nodeName).appendChild( meta );
						this._exploreNode( xml, XML( xml.factory.variable.(@name == nodeName) ), vector );
					}
					// look for it in the accessors
					else if ( xml.factory.accessor.(@name == nodeName) != undefined )
					{
						// remove the "field" meeta argument, otherwise we'll go into
						// an infinite loop
						i = 0;
						for each( metaArg in meta.arg )
						{
							if ( metaArg.@key == "field" )
								break;
							i++;
						}
						delete meta.children()[i]; // remove the arg node
						
						// append the meta data to the node, then explore it
						xml.factory.accessor.(@name == nodeName).appendChild( meta );
						this._exploreNode( xml, XML( xml.factory.accessor.(@name == nodeName) ), vector );
					}
					else
						this.m_editor.log( "Couldn't add field '" + nodeName + "' as Editable as we couldn't find it", 3 );
						
					// the added variable will be explored at this point, so just continue
					continue;
				}
					
				// create our editable var obj
				var editVar:EditableVar = new EditableVar;
				
				// if this is an accessor and it's readonly, then change the type to "watch"
				// as we can only get the data, not set it
				if ( varXML.@access != undefined && varXML.@access == "readonly" )
				{
					// if it has an arg type in it's meta data, then change it,
					// otherwise add a new arg node
					if ( meta.arg.(@key == "type") != undefined )
						meta.arg.(@key == "type").@value = EditableTypes.TYPE_WATCH;
					else
						meta.appendChild( new XML( <arg key="type" value={EditableTypes.TYPE_WATCH} /> ) );
				}
				// if this is an accessor and it's writeonly, then set the bool on our EditableVar obj
				else if ( varXML.@access != undefined && varXML.@access != "readwrite" )
					editVar.hasReadAccess = false; // we don't have read access to this var
				
				// set the name of the variable
				editVar.variable = varXML.@name;
				
				// if it has a "type", use it
				if ( meta.arg.(@key == "type") != undefined )
				{
					// set the type
					editVar.type = ( meta.arg.(@key == "type").@value );
					
					// make sure it's good
					if ( !EditableTypes.isGoodType( editVar.type ) )
					{
						editVar.type = this._getDefaultType( varXML.@type );
						this.m_editor.log( "The type set for '" + varXML.@name + "' was wrong, changing it to " + editVar.type, 2 );
					}
				}
				else
					// there was no "type" set, just take the default
					editVar.type = this._getDefaultType( varXML.@type );
					
				// set the default arguments for the type
				editVar.params = this._getDefaultParams( editVar.type );
					
				// get the other arguments (component configuration)
				for each( var argsXML:XML in meta.arg )
				{
					// ignore the "type" arg
					if ( argsXML.@key == "type" )
						continue;
						
					// see if the arg set is acceptable for the type of component that we're going to use
					if ( !this._isGoodArg( argsXML.@key, editVar.type ) )
					{
						this.m_editor.log( "Ignoring argument '" + argsXML.@key + "' on '" + varXML.@name + "' as it's not used for this type: " + editVar.type, 2 );
						continue;
					}
					
					// get our sanitised value (i.e. convert from a String)
					var val:* = this._convertArgValue( argsXML.@key, argsXML.@value );
					if ( val == null )
					{
						this.m_editor.log( "Couldn't convert the value '" + argsXML.@value + "' for argument '" + argsXML.@key + "' on '" + varXML.@name + "'", 3 );
						continue;
					}
					
					// if we don't have an obj, create one, then store our val
					if ( editVar.params == null )
						editVar.params = new Object;
						
					// if it's a static const type, get the constants
					if ( editVar.type == EditableTypes.TYPE_STATIC_CONSTS )
						editVar.params[argsXML.@key] = this._getConstants( val, varXML.@type );
					else
						// otherwise, just set the value
						editVar.params[argsXML.@key] = val;
				}
				
				// add our edit var to the vector
				vector.push( editVar );
			}
		}
		
		// Returns the default EditableType component that we're going to use depending
		// on what type the variable is
		private function _getDefaultType( varType:String ):String
		{
			// Strings use the input component
			if ( varType == "String" )
				return EditableTypes.TYPE_INPUT;
				
			// Booleans use a checkbox
			if ( varType == "Boolean" )
				return EditableTypes.TYPE_CHECKBOX;
				
			// int, uint and number all revert to TYPE_STEPPER
			if( varType == "int" || varType == "uint" || varType == "Number" )
				return EditableTypes.TYPE_STEPPER;
				
			// just a non-editable watch type
			return EditableTypes.TYPE_WATCH;
		}
		
		// Returns the default params for the edit component depending on what
		// type component we're using
		private function _getDefaultParams( type:String ):Object
		{
			// if it's an input type, then the default max number of chars allowed is infinite
			if ( type == EditableTypes.TYPE_INPUT )
				return { maxChars:0 }
			// else if it's a slider or a stepper, we set a min and max between 0-100, with a step of 1
			else if ( type == EditableTypes.TYPE_SLIDER || type == EditableTypes.TYPE_STEPPER )
				return { min:0, max:100, step:1 }
			// none of the other component have default params
			else
				return null;
		}
		
		// makes sure that any arguments coming from the user code are valid
		private function _isGoodArg( arg:String, type:String ):Boolean
		{
			// for input types, the only thing we accept is the "maxChars" arg
			if ( type == EditableTypes.TYPE_INPUT )
				return ( arg == "maxChars" );
				
			// if it's a static const type, the only thing we accept is the "clazz" arg
			if ( type == EditableTypes.TYPE_STATIC_CONSTS )
				return ( arg == "clazz" );
				
			// if it's a slider, or a stepper, we only accept "min", "max", and "step"
			if ( type == EditableTypes.TYPE_SLIDER || type == EditableTypes.TYPE_STEPPER )
				return ( arg == "min" || arg == "max" || arg == "step" ); // 'min', 'max' and 'step' are the only ones we accept
				
			return false; // the rest don't take any args
		}
		
		// this takes the value passed with an arg and converts it to the right type from a String
		private function _convertArgValue( key:String, value:String ):*
		{
			// "maxChars" only accepts int type
			if ( key == "maxChars" )
				return int( value );
			// if it's a "clazz", then look in the application domain to see if the class exists
			else if ( key == "clazz" )
			{
				var c:Class = null;
				try
				{
					c = this.m_editor.stage.loaderInfo.applicationDomain.getDefinition( value ) as Class;
				}
				catch ( e:Error ) { /* couldn't find the class */ }
				return c; // will be null if we can't find the class
			}
			// the "min", "max", and "step" all convert to Number
			else if ( key == "min" || key == "max" || key == "step" )
				return Number( value );
				
			return null;
		}
		
		// looks at a class and strips out all the static consts in the class that match our
		// type (e.g. "String" or "Number")
		private function _getConstants( clazz:Class, type:String ):Array
		{
			// describeType() the class
			var xml:XML = this.m_db.describeType( clazz );
			
			// the array that we're going to return (array as that's what the
			// combobox component takes as a display list)
			var a:Array = new Array;
			
			// go through all the statics and take out the statics that match our type
			for each( var cXML:XML in xml.constant )
			{
				// if the type is the same, the add a new object with the "label" set to
				// the constant variable name + it's value, and the "data" set to the value
				if ( cXML.@type == type )
					a.push( { label:cXML.@name.toString() + " - (" + clazz[cXML.@name] + ")", data:clazz[cXML.@name] } );
			}
				
			// sort the array
			a.sortOn( "label" );
			
			// return the array
			return a;
		}
		
		// sorts the vector of EditableVars based on the variable alphabetical order
		private function _sort( a:EditableVar, b:EditableVar ):int
		{
			if ( a.variable < b.variable )
				return -1;
			return 1;
		}
		
	}

}