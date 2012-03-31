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
import de.polygonal.motor.geom.intersect.IntersectRaySphere;
import de.polygonal.motor.geom.primitive.Ray2;
import de.polygonal.ui.trigger.behavior.MutableSegment;
import de.polygonal.ui.trigger.surface.CircleSurface;
import de.polygonal.ui.trigger.Trigger;

class TestGeomIntersectRaySphere extends TestGeom
{
	var _viewSegment:MutableSegment;
	var _viewCircle:Trigger;

	var _ray:Ray2;
	
	override public function getName():String 
	{
		return "intersect ray against sphere";
	}
	
	override function _init():Void
	{
		super._init();
		
		_viewSegment = _createInteractiveSegment(100, centerY + 60, 200, centerY + 40, 20, 200);
		_viewCircle = _createInteractiveCircle(centerX, centerY, 50);
		_viewCircle.appendChild(_viewSegment.getTrigger());
		
		_ray = new Ray2();
	}
	
	override function _free():Void 
	{
		_viewSegment.free();
		super._free();
	}
	
	override function _tick(tick:Int):Void
	{
		var circle = cast(_viewCircle.surface, CircleSurface).getShape();
		_ray.setFromPoints2(_viewSegment.getSegment().a, _viewSegment.getSegment().b);
		
		_fIntersect = IntersectRaySphere.find2(_ray, circle, _tmpVec);
		_bIntersect = _fIntersect != -1;
		
		#if debug
		de.polygonal.core.macro.Assert.assert(IntersectRaySphere.test2(_ray, circle) == _bIntersect, "IntersectRaySphere.test2(_ray, circle) == _bIntersect");
		#end
	}
	
	override function _draw(alpha:Float):Void
	{
		var circle = cast(_viewCircle.surface, CircleSurface).getShape();
		
		_vr.circle(circle);
		_vr.arrowLine3(_viewSegment.getSegment().a, _viewSegment.getSegment().b, 8);
		
		if (_bIntersect)
		{
			_drawMarker(_tmpVec, Sprintf.format("%.2f", [_fIntersect]));
			
			if (_fIntersect * _fIntersect > _viewSegment.getSegment().lengthSq)
			 {
				_vr.setLineStyle(0xFF0000, 1, 0);
				_vr.dashedLine2(_viewSegment.getSegment().b, _tmpVec, 4, 4);
			 }
			
		}
	}
}