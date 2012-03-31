/*
 *                            _/                                                    _/   
 *       _/_/_/      _/_/    _/  _/    _/    _/_/_/    _/_/    _/_/_/      _/_/_/  _/    
 *      _/    _/  _/    _/  _/  _/    _/  _/    _/  _/    _/  _/    _/  _/    _/  _/     
 *     _/    _/  _/    _/  _/  _/    _/  _/    _/  _/    _/  _/    _/  _/    _/  _/      
 *    _/_/_/      _/_/    _/    _/_/_/    _/_/_/    _/_/    _/    _/    _/_/_/  _/       
 *   _/                            _/        _/                                          
 *  _/                        _/_/      _/_/                                             
 *                                                                                       
 * POLYGONAL - A HAXE LIBRARY FOR GAME DEVELOPERS
 * Copyright (c) 2009-2010 Michael Baczynski, http://www.polygonal.de
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
package testbed.test.world.contact;

import de.polygonal.core.math.Mathematics;
import de.polygonal.core.math.Vec2;
import testbed.test.world.TestWorld;

class TestContactAABB3 extends TestWorld
{
	override public function getName():String 
	{
		return "AABB wall";
	}
	
	override function _initWorld():Void
	{
		var boxDensity   = .1;
		var boxRows      = 10;
		var boxCols      = 10;
		var boxSize      = new Vec2(.4, .2);
		var boxSpacing   = .01;
		var floorLevel   = 5.;
		var floorExtent  = 10.;
		var floorHeight  = .4;
		
		_createFloor(floorLevel, floorExtent, floorHeight);
		
		var xOffset = -((boxCols - 1) * (boxSize.x + boxSpacing) / 2);
		var yOffset = floorLevel - floorHeight / 2 - boxSize.y / 2 - boxSpacing;
		
		var axisAligned = true;
		
		for (y in 0...boxRows)
		{
			for (x in 0...boxCols)
			{
				var xpos = xOffset + x * (boxSize.x + boxSpacing);
				var ypos = yOffset;
				
				if (!Mathematics.isEven(y)) xpos += boxSize.x / 2;
				
				var body = _createBox(boxDensity, xpos, ypos, boxSize.x, boxSize.y, 0, axisAligned);
			}
			
			yOffset += -(boxSize.y + boxSpacing);
		}
	}
}