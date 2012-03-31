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
import de.polygonal.motor.data.PolyData;
import testbed.test.world.TestWorld;

class TestContactCompound extends TestWorld
{
	override public function getName():String 
	{
		return "compound shape soup";
	}
	
	override function _initWorld()
	{
		var containerSize      = 10;
		var containerThickness = .5;
		
		_createContainer(containerThickness, 0, 0, containerSize, containerSize);
		
		_dataToBody(_getCompoundPoly(.1, 0, 0, .5, .25));
		
		//create some dynamic shapes
		/*var polyDensity    = .1;
		var polyRadiusMin  = .3;
		var polyRadiusMax  = .6;
		var polyCount      = 30;
		var randomPolyData = getRandomPolyCollection();
		
		for (i in 0...polyCount)
		{
			var x = Random.frandSym(containerSize / 3);
			var y = Random.frandSym(2) - 2;
			var r = Random.frandRange(0, Mathematics.PI);
			var s = Random.frandRange(polyRadiusMin, polyRadiusMax);
			
			var data = new PolyData(polyDensity);
			
			switch (Mathematics.randomRange(0, 2))
			{
				case 0:
					data.setCircle(6, s);
				
				case 1:
					var len = Random.frandRange(.5, 1);
					data.setCapsule(len, len/3, len/3, Mathematics.randomRange(2, 6), Mathematics.randomRange(2, 6));
				
				case 2:
					data.setCustom(randomPolyData[Mathematics.randomRange(0, randomPolyData.length - 1)]);
			}
			
			_createPoly(x, y, r, data);
		}
		
		_dataToBody(getCompoundPoly(.1, 0, -5, .5, .25));*/
	}
}