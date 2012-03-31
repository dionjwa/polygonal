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

import de.polygonal.core.fmt.Sprintf;
import de.polygonal.core.Root;
import de.polygonal.gl.Window;
import de.polygonal.motor.geom.intersect.IntersectMovingSpherePlane;
import de.polygonal.motor.geom.primitive.Plane2;
import de.polygonal.motor.geom.primitive.Sphere2;
import de.polygonal.ui.trigger.behavior.MutableSegment;

class TestGeomIntersectMovingSpherePlane extends TestGeom
{
	var _sphere:Sphere2;
	var _sphereSwept:MutableSegment;
	
	var _plane:Plane2;
	
	override public function getName():String 
	{
		return "swept sphere against plane";
	}
	
	override function _init():Void
	{
		super._init();
		
		_sphere = new Sphere2(0, 0, 30);
		
		_sphereSwept = _createInteractiveSegment(centerX + 200, centerY, centerX - 100, centerY - 100, 20, 400);
		
		_plane = new Plane2();
		var r = Math.PI / 4;
		_plane.setFromNormal4(Math.cos(r), Math.sin(r), Window.bound().centerX, Window.bound().centerY);
	}
	
	override function _free():Void
	{
		_sphereSwept.free();
		super._free();
	}
	
	override function _tick(tick:Int):Void
	{
		var s = _sphereSwept.getSegment();
		_movement.x = s.b.x - s.a.x;
		_movement.y = s.b.y - s.a.y;
		_sphere.c.x = s.a.x;
		_sphere.c.y = s.a.y;
		
		_fIntersect = IntersectMovingSpherePlane.find3(_sphere, _plane, _movement, _tmpVec);
		_bIntersect = _fIntersect != -1 && _fIntersect <= 1;
	}
	
	override function _draw(alpha:Float):Void
	{
		//draw circle movement
		_vr.arrowLine3(_sphereSwept.getSegment().a, _sphereSwept.getSegment().b, 4);
		_vr.circle2(_sphereSwept.getSegment().a, _sphere.r);
		_vr.circle2(_sphereSwept.getSegment().b, _sphere.r);
		
		_vr.plane4(_plane, Window.bound(), 20, 4);
		
		if (_bIntersect)
		{
			_vr.setLineStyle(0xff0000, 1, 0);
			_vr.circle3
			(
				_sphere.c.x + _movement.x * _fIntersect,
				_sphere.c.y + _movement.y * _fIntersect,
				_sphere.r
			);
			
			_drawMarker(_tmpVec);
			_annotate(_tmpVec, Sprintf.format("%.3f", [_fIntersect]));
		}
	}
}