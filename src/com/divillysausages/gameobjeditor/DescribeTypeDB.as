/**
 * DescribeTypeDB.as
 * Damian Connolly
 * version 1.0
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
	import flash.utils.Dictionary;
	
	/**
	 * Provides a cache for using <code>describeType()</code>, making subsequent calls quicker
	 * 
	 * @author Damian Connolly
	 */
	public class DescribeTypeDB extends Dictionary
	{
		
		/**
		 * Creates our <code>DescribeTypeDB</code>, using weak keys
		 */
		public function DescribeTypeDB()
		{
			super( true );
		}
		
		/**
		 * Gets the <code>XML</code> representation of an <code>Object</code> or a 
		 * <code>Class</code>. If the object already exists in our DB, then the 
		 * cached representation is returned, otherwise a new one is created
		 * 
		 * @param obj The <code>Object</code> that we're describing
		 * @return The <code>XML</code> representation of the object
		 */
		public function describeType( obj:* ):XML 
		{
			// if it's already there, just return it
			if ( this[obj] != null )
				return this[obj];
				
			// describe and add it
			var x:XML = flash.utils.describeType( obj );
			this[obj] = x;
			return x;
		}
		
	}

}