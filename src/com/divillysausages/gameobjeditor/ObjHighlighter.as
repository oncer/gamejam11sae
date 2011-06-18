/**
 * EditableVar.as
 * Damian Connolly
 * version 1.2
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
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Stage;
	import flash.geom.Rectangle;
	
	/**
	 * If an object is a DisplayObject and we want to highlight it's position, then
	 * this will draw a rectangle around it so it can found easier
	 * 
	 * @author Damian Connolly
	 */
	public class ObjHighlighter extends Shape
	{
		
		/*********************************************************************************/
		
		private var m_stage:Stage		= null;		// a reference to the stage so we can add/remove ourselves
		private var m_highlight:Boolean = false;	// are we currently highlighting an object?
		private var m_lineSize:Number	= 1.0;		// the size of the line to draw
		private var m_lineColour:uint	= 0xff0000;	// the colour of the line to draw
		private var m_lineAlpha:Number	= 0.5;		// the alpha of the line to draw
		private var m_padding:Number	= 5.0;		// how much padding to add to the box
		
		/*********************************************************************************/
		
		/**
		 * Should we highlight the current object?
		 * @default false
		 */
		public function get highlight():Boolean { return this.m_highlight; }
		public function set highlight( b:Boolean ):void
		{
			this.m_highlight = b;
			if ( !this.m_highlight )
				this.clear();
		}
		
		/**
		 * The size of the line to draw when we're highlighting the current object
		 * @default 1.0
		 */
		public function set lineSize( n:Number ):void
		{
			this.m_lineSize = n;
		}
		
		/**
		 * The colour of the line to draw when we're highlighting the current object
		 * @default 0xff0000
		 */
		public function set lineColour( u:uint ):void
		{
			this.m_lineColour = u;
		}
		
		/**
		 * The alpha of the line to draw when we're highlighting the current object
		 * @default 0.5
		 */
		public function set lineAlpha( n:Number ):void
		{
			// clamp it
			n = ( n < 0.0 ) ? 0.0 : ( n > 1.0 ) ? 1.0 : n;
			this.m_lineAlpha = n;
		}
		
		/*********************************************************************************/
		
		/**
		 * Creates the ObjHighlighter object
		 * @param s A reference to the Stage so we can add/remove ourselves
		 */
		public function ObjHighlighter( s:Stage ) 
		{
			this.m_stage = s;
		}
		
		/**
		 * Updates the ObjHighlighter. If we're meant to highlight the current object, then
		 * we draw a rectangle around it so we can see where it is
		 * @param obj The object we want to draw around
		 */
		public function update( obj:* ):void
		{
			// if we're not highlight, return
			if ( !this.m_highlight )
				return;
				
			// see is our object a DisplayObject
			var dObj:DisplayObject = obj as DisplayObject;
			if ( dObj == null )
			{
				// remove any graphics and return
				this.clear();
				return;
			}
			
			// get it's bounds
			var rect:Rectangle = dObj.transform.pixelBounds;
			
			// expand the rect a bit
			rect.x 		-= this.m_padding;
			rect.y 		-= this.m_padding;
			rect.width 	+= this.m_padding * 2.0;
			rect.height += this.m_padding * 2.0
			
			// draw our box
			this.graphics.clear();
			this.graphics.lineStyle( this.m_lineSize, this.m_lineColour, this.m_lineAlpha );
			this.graphics.drawRect( rect.x, rect.y, rect.width, rect.height );
			
			// draw lines to the 4 corners
			if ( this.m_stage != null )
			{
				// tl to tl
				this.graphics.moveTo( 0.0, 0.0 );
				this.graphics.lineTo( rect.x, rect.y );
				
				// tr to tr
				this.graphics.moveTo( this.m_stage.stageWidth, 0.0 );
				this.graphics.lineTo( rect.x + rect.width, rect.y );
				
				// bl to bl
				this.graphics.moveTo( 0.0, this.m_stage.stageHeight );
				this.graphics.lineTo( rect.x, rect.y + rect.height );
				
				// br to br
				this.graphics.moveTo( this.m_stage.stageWidth, this.m_stage.stageHeight );
				this.graphics.lineTo( rect.x + rect.width, rect.y + rect.height );
			}
			
			// if we're not on the stage, add us
			if ( this.parent == null && this.m_stage != null )
				this.m_stage.addChild( this );
		}
		
		/**
		 * Clears the highlight graphics
		 */
		public function clear():void
		{
			// if we don't have a parent, we're already off
			if ( this.parent == null )
				return;
				
			// clear our graphics
			this.graphics.clear();
			
			// remove us from the stage
			this.parent.removeChild( this );
		}
		
	}

}