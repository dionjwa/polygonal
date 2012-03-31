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

class TestContactTriangle extends TestWorld
{
	override public function getName():String 
	{
		return "triangle soup";
	}
	override function _initWorld():Void
	{
		var triangleDensity     = .1;
		var triangleRadiusMin   = .3;
		var triangleRadiusMax   = .5;
		var triangleCount       = 50;
		var containerSize       = 10;
		var containerThickness  = .5;
		
		_createContainer(containerThickness, 0, 0, containerSize, containerSize);
		
		var scope = this;
		_listLayout(.3, 0, 4, containerSize, 20,
			function(x:Float, y:Float):Void
			{
				var data = new PolyData(0);
				data.setCircle(3, .25);
				scope._createPoly(x, y - Random.frandRange(0, 2), Mathematics.PI / 6, data);
			});
		
		for (i in 0...triangleCount)
		{
			var x = Random.frandSym(containerSize / 2 - triangleRadiusMin);
			var y = Random.frandSym(2) - 2;
			var s = Random.frandRange(triangleRadiusMin, triangleRadiusMax);
			
			var data = new PolyData(triangleDensity);
			data.setCircle(3, Random.frandRange(triangleRadiusMin, triangleRadiusMax));
			_createPoly(x, y, 0, data);
		}
	}
}