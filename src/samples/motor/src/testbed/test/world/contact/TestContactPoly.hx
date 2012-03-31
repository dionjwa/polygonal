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
import de.polygonal.core.math.random.Random;
import de.polygonal.motor.data.PolyData;
import testbed.test.world.TestWorld;

class TestContactPoly extends TestWorld
{
	override public function getName():String 
	{
		return "poly soup";
	}
	
	override function _initWorld()
	{
		var containerSize      = 10;
		var containerThickness = .5;
		
		_createContainer(containerThickness, 0, 0, containerSize, containerSize);
		
		//create some static shapes
		var scope = this;
		_gridLayout(.5, 0, 3, containerSize, containerSize / 4, 5, 2,
		function(x:Float, y:Float):Void
		{
			var r = Random.frandRange(0, Mathematics.PI);
			var data = new PolyData(0);
			data.setCircle(5, .5);
			scope._createPoly(x, y, r, data);
		});
		
		//create some dynamic shapes
		var polyDensity    = .1;
		var polyRadiusMin  = .3;
		var polyRadiusMax  = .6;
		var polyCount      = 30;
		var randomPolyData = _getRandomPolyCollection();
		
		for (i in 0...polyCount)
		{
			var x = Random.frandSym(containerSize / 3);
			var y = Random.frandSym(2) - 2;
			var r = Random.frandRange(0, Mathematics.PI);
			var s = Random.frandRange(polyRadiusMin, polyRadiusMax);
			
			var data = new PolyData(polyDensity);
			
			switch (Random.randRange(0, 2))
			{
				case 0:
					data.setCircle(6, s);
				
				case 1:
					var len = Random.frandRange(.5, 1);
					data.setCapsule(len, len/3, len/3, Random.randRange(2, 6), Random.randRange(2, 6));
				
				case 2:
					data.setCustom(randomPolyData[Random.randRange(0, randomPolyData.length - 1)], true);
			}
			
			_createPoly(x, y, r, data);
		}
		
		_dataToBody(_getCompoundPoly(.1, 0, -5, .5, .25));
	}
}