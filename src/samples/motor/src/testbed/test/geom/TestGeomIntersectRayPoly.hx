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
import de.polygonal.motor.collision.shape.feature.Vertex;
import de.polygonal.motor.geom.intersect.ClipInfo;
import de.polygonal.motor.geom.intersect.IntersectRayPoly;
import de.polygonal.motor.geom.primitive.Ray2;
import de.polygonal.ui.trigger.behavior.MutableSegment;
import de.polygonal.ui.trigger.surface.PolySurface;
import de.polygonal.ui.trigger.Trigger;

class TestGeomIntersectRayPoly extends TestGeom
{
	var _viewSegment:MutableSegment;
	var _viewPoly:Trigger;
	
	var _vertexList:Array<Vertex>;
	var _ray:Ray2;
	var _clipResult:ClipInfo;
	
	override public function getName():String 
	{
		return "intersect ray against poly";
	}
	
	override function _init():Void
	{
		super._init();
		
		_viewSegment = _createInteractiveSegment(100, centerY, 200, centerY - 20, 20, 200);
		_viewPoly = _createInteractivePoly(centerX, centerY, 6, 100);
		_viewPoly.appendChild(_viewSegment.getTrigger());
		
		_vertexList = Vertex.toArray(cast(_viewPoly.surface, PolySurface).getShape().worldVertexChain);
		_ray = new Ray2();
		_clipResult = new ClipInfo();
	}
	
	override function _free():Void 
	{
		_viewSegment.free();
		super._free();
	}
	
	override function _tick(tick:Int):Void
	{
		_ray.setFromPoints2(_viewSegment.getSegment().a, _viewSegment.getSegment().b);
		
		var poly = cast(_viewPoly.surface, PolySurface).getShape();
		_bIntersect = IntersectRayPoly.find2(_ray, poly, _clipResult);
	}
	
	override function _draw(alpha:Float):Void
	{
		_vr.arrowLine3(_viewSegment.getSegment().a, _viewSegment.getSegment().b, 8);
		
		var poly = cast(_viewPoly.surface, PolySurface).getShape();
		var i = 0;
		for (v in poly.worldVertexChain)
		{
			_vertexList[i].x = v.x;
			_vertexList[i].y = v.y;
			i++;
		}
		_vr.polyLineVector(cast _vertexList, true);
		
		if (_bIntersect)
		{
			_vr.clearStroke();
			_vr.setFillColor(0xFFFF00, 1);
			
			_tmpVec.x = _ray.p.x + _ray.d.x * _clipResult.t0;
			_tmpVec.y = _ray.p.y + _ray.d.y * _clipResult.t0;
			_drawMarker(_tmpVec, Sprintf.format("%.2f %d", [_clipResult.t0, _clipResult.e0]));
			
			_tmpVec.x = _ray.p.x + _ray.d.x * _clipResult.t1;
			_tmpVec.y = _ray.p.y + _ray.d.y * _clipResult.t1;
			_drawMarker(_tmpVec, Sprintf.format("%.2f %d", [_clipResult.t1, _clipResult.e1]));
			
			if (_clipResult.t1 * _clipResult.t1 > _viewSegment.getSegment().lengthSq)
			 {
				_vr.setLineStyle(0xFF0000, 1, 0);
				_vr.dashedLine2(_viewSegment.getSegment().b, _tmpVec, 4, 4);
			 }
		}
	}
}