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
import de.polygonal.motor.geom.intersect.IntersectRayPlane;
import de.polygonal.core.math.Vec2;
import de.polygonal.motor.geom.primitive.Plane2;
import de.polygonal.motor.geom.primitive.Ray2;
import de.polygonal.ui.trigger.behavior.MutableSegment;

class TestGeomIntersectRayPlane extends TestGeom
{
	var _rayView:MutableSegment;
	var _planeView:MutableSegment;
	
	var _ray:Ray2;
	var _plane:Plane2;
	
	override public function getName():String 
	{
		return "intersect ray against plane";
	}
	
	override function _init():Void
	{
		super._init();
		
		_ray = new Ray2();
		_rayView = _createInteractiveSegment(100, 300, 300, 280, 20, 200);
		_planeView = _createInteractiveSegment(centerX - 100, centerY - 100, centerX + 100, centerY + 100, 0, 0, true);
		
		_plane = new Plane2();
		_plane.setFromPoints2(_planeView.getSegment().a, _planeView.getSegment().b);
	}
	
	override function _free():Void
	{
		_rayView.free();
		_planeView.free();
		super._free();
	}
	
	override function _tick(tick:Int):Void
	{
		//synchronize model with view
		_plane.setFromPoints2(_planeView.getSegment().a, _planeView.getSegment().b);
		_ray.setFromPoints2(_rayView.getSegment().a, _rayView.getSegment().b);
		
		//find intersection
		_fIntersect = IntersectRayPlane.find2(_ray, _plane, _tmpVec);
		_bIntersect = _fIntersect != -1;
		
		#if debug
		de.polygonal.core.macro.Assert.assert(_bIntersect == IntersectRayPlane.test2(_ray, _plane), "_bIntersect == IntersectRayPlane.test2(_ray, _plane)");
		#end
	}
	
	override function _draw(alpha:Float):Void
	{
		_vr.line2(_planeView.getSegment().a, _planeView.getSegment().b);
		
		var center = new Vec2();
		_planeView.getSegment().getCenter(center);
		
		_vr.arrowRay4(center, _plane.n, 30, 4);
		
		_vr.arrowLine3(_rayView.getSegment().a, _rayView.getSegment().b, 8);
		
		if (_bIntersect)
		{
			_tmpVec.x = _ray.p.x + _ray.d.x * _fIntersect;
			_tmpVec.y = _ray.p.y + _ray.d.y * _fIntersect;
			_drawMarker(_tmpVec, Sprintf.format("%.2f", [_fIntersect]));
			
			 if (_fIntersect * _fIntersect > _rayView.getSegment().lengthSq)
			 {
				_vr.setLineStyle(0xFF0000, 1, 0);
				_vr.dashedLine2(_rayView.getSegment().b, _tmpVec, 4, 4);
			 }
		}
	}
}