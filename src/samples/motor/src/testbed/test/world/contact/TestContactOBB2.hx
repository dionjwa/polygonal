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

import de.polygonal.motor.World;
import testbed.test.world.TestWorld;

class TestContactOBB2 extends TestWorld
{
	override public function getName():String 
	{
		return "OBB pyramid";
	}
	
	override function _initWorld():Void
	{
		World.settings.doWarmStart = true;
		World.settings.velocityIterations = 15;
		World.settings.positionIterations = 10;
		
		var boxDensity   = .1;
		var boxBaseCount = 10;
		var boxSize      = .4;
		var boxSpacing   = boxSize / 100;
		var floorLevel   = 5.;
		var floorExtent  = boxBaseCount * (boxSize + boxSpacing) + boxSize * 2;
		var floorHeight  = .4;
		
		var xOffset = -(boxBaseCount / 2) * (boxSize + boxSpacing) + (boxSize / 2) + boxSpacing / 2;
		var yOffset = floorLevel - floorHeight;
		var k = 0;
		var y = 0;
		
		_createFloor(floorLevel, floorExtent, floorHeight);
		
		while (boxBaseCount > 0)
		{
			for (x in 0...boxBaseCount)
			{
				var xpos = xOffset + (boxSize + boxSpacing) * x;
				var ypos = yOffset - y * (boxSize + boxSpacing);
				_createBox(boxDensity, xpos, ypos, boxSize, boxSize);
				k++;
			}
			
			boxBaseCount--;
			y++;
			xOffset += (boxSize / 2) + boxSpacing / 2;
		}
	}
}