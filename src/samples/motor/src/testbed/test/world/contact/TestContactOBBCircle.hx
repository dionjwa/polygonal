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
import testbed.test.world.TestWorld;

using de.polygonal.core.math.Mathematics;

class TestContactOBBCircle extends TestWorld
{
	override public function getName():String 
	{
		return "OBB + circle soup";
	}
	
	override function _initWorld():Void
	{
		var circleDensity   = .1;
		var circleCount     = 15;
		var circleRadiusMin = .15;
		var circleRadiusMax = .35;
		var boxDensity      = .1;
		var boxCount        = 5;
		var boxSizeMin      = .25;
		var boxSizeMax      = .5;
		var rampCount       = 6;
		var rampSpacingX    = 2.2;
		var rampSpacingY    = 1.5;
		var rampWidth       = 5;
		var rampHeight      = .25;
		
		var x = 0, y = -4;
		
		for (i in 0...rampCount)
		{
			if (Mathematics.isEven(i))
				_createBox(0, x - rampSpacingX, y + i * rampSpacingY, rampWidth, rampHeight, 20.toRad());
			else
				_createBox(0, x + rampSpacingX, y + i * rampSpacingY, rampWidth, rampHeight,-20.toRad());
		}
		
		for (i in 0...circleCount)
		{
			var t = rampWidth - circleRadiusMax - .5;
			var x = _getRandomFloat(-t, t);
			
			var y = -5.5 + _getRandomFloat(circleRadiusMin, circleRadiusMax);
			var radius = _getRandomFloat(circleRadiusMin, circleRadiusMax);
			_createCircle(circleDensity, x, y, radius);
		}
		
		for (i in 0...boxCount)
		{
			var t = rampWidth - boxSizeMax - .5;
			var x = _getRandomFloat(-t, t);
			var y = -5.5 + _getRandomFloat(boxSizeMin, boxSizeMax);
			var s = _getRandomFloat(boxSizeMin, boxSizeMax);
			_createBox(boxDensity, x, y, s, s, 0);
		}
		
		//_createContainer(0.25, 0, 0, rampWidth * 2, rampWidth * 2);
	}
}