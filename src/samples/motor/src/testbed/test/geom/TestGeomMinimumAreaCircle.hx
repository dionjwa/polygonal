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
package testbed.test.geom;

import de.polygonal.core.math.random.Random;
import de.polygonal.motor.geom.bv.MinimumAreaCircle;
import de.polygonal.core.math.Vec2;
import de.polygonal.core.math.Vec2;
import de.polygonal.motor.geom.primitive.Sphere2;

class TestGeomMinimumAreaCircle extends TestGeom
{
	var _circle1:Sphere2;
	var _circle2:Sphere2;
	var _circle3:Sphere2;
	
	var _points:Array<Vec2>;
	
	override public function getName():String 
	{
		return "minimum area circle from point cloud";
	}
	
	override function _init():Void
	{
		super._init();
		
		_points = new Array<Vec2>();
		_circle1 = new Sphere2();
		_circle2 = new Sphere2();
		_circle3 = new Sphere2();
		
		for (i in 0...10)
			_points.push(new Vec2(centerX + Random.frandSym(100), centerY + Random.frandSym(100)));
		
		MinimumAreaCircle.findApproxA(_points, _circle1);
		MinimumAreaCircle.findApproxB(_points, _circle2);
		MinimumAreaCircle.findExact(_points, _circle3);
	}
	
	override function _onMouseDown(mouse:Vec2):Void 
	{
		super._onMouseDown(mouse);
		
		_points.push(new Vec2(mouse.x, mouse.y));
		if (_points.length >= 3)
		{
			MinimumAreaCircle.findApproxA(_points, _circle1);
			MinimumAreaCircle.findApproxB(_points, _circle2);
			MinimumAreaCircle.findExact(_points, _circle3);
		}
	}
	
	override function _draw(alpha:Float):Void
	{
		_vr.setLineStyle(0x00ff00, 1, 0);
		for (p in _points) _vr.crossSkewed2(p, 3);
		
		_vr.setLineStyle(0xff0000, 1, 0);
		if (_points.length >= 3)
		{
			_vr.setLineStyle(0xFFFF00, .9, 0);
			_vr.circle(_circle1);
			_vr.setLineStyle(0xFF8000, .9, 0);
			_vr.circle(_circle2);
			_vr.setLineStyle(0xFF0000, .9, 0);
			_vr.circle(_circle3);
		}
	}
}