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

using de.polygonal.core.math.Mathematics;

class TestContactPolyCircle extends TestWorld
{
	override public function getName():String 
	{
		return "poly + circle soup";
	}
	
	override function _initWorld()
	{
		var containerSize      = 10;
		var containerThickness = .5;
		
		_createContainer(containerThickness, 0, 0, containerSize, containerSize);
		
		var radius = .5;
		var minRadius = .2;
		var maxRadius = .4;
		
		var gridX  = 0;
		var gridY  = 2;
		var gridW  = containerSize - radius * 2;
		var gridH  = 5;
		var countX = 5;
		var countY = 5;
		var spaceX =(gridW - radius * 2) / (countX - 1);
		var spaceY = gridH / 5;
		
		var startX = -gridW / 2 + radius;
		var startY = -gridH / 2 + radius;
		
		for (y in 0...countY)
		{
			for (x in 0...countX)
			{
				var shapeX = gridX + startX + x * spaceX + Random.frandSym(.1);
				var shapeY = gridY + startY + y * spaceY + Random.frandSym(.1);
				
				if (y.isEven())
					shapeX += radius;
				else
					shapeX -= radius;
				
				var s = Random.frandRange(minRadius, maxRadius);
				
				if (Math.random() < .5)
					_createCircle(0, shapeX, shapeY, s);
				else
				{
					var data = new PolyData(0);
					data.setCircle(Random.randRange(5, 8), s);
					var r = Random.frandRange(0, Mathematics.PI);
					_createPoly(shapeX, shapeY, r, data);
				}
			}
		}
		
		var dynamicCount = 40;
		var dynamicDensity = .1;
		
		for (i in 0...dynamicCount)
		{
			var x = Random.frandSym(containerSize / 2 - minRadius);
			var y = - 2 + Random.frandSym(2);
			var r = Random.frandRange(0, Mathematics.PI);
			var s = Random.frandRange(minRadius, maxRadius);
			
			if (Math.random() < .5)
				_createCircle(dynamicDensity, x, y, s);
			else
			{
				var data = new PolyData(dynamicDensity);
				data.setCircle(Random.randRange(5, 8), s);
				var r = Random.frandRange(0, Mathematics.PI);
				_createPoly(x, y, r, data);
			}
		}
		
		_dataToBody(_getCompoundPoly(.1, -2, -5, .5, .25));
		_dataToBody(_getCompoundCircle(.1, 2, -5, .5, .25));
	}
}