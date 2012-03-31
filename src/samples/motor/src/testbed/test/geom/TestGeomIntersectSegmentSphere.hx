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
import de.polygonal.motor.geom.intersect.IntersectSegmentSphere;
import de.polygonal.ui.trigger.behavior.MutableSegment;
import de.polygonal.ui.trigger.surface.CircleSurface;
import de.polygonal.ui.trigger.Trigger;

class TestGeomIntersectSegmentSphere extends TestGeom
{
	var _viewSegment:MutableSegment;
	var _viewCircle:Trigger;
	
	override public function getName():String 
	{
		return "intersect segment against sphere";
	}
	
	override function _init():Void
	{
		super._init();
		
		_viewSegment = _createInteractiveSegment(220, centerY, 400, centerY - 20, 20, 200);
		_viewCircle = _createInteractiveCircle(centerX, centerY, 50);
		_viewCircle.appendChild(_viewSegment.getTrigger());
	}
	
	override function _free():Void 
	{
		_viewSegment.free();
		_viewCircle.free();
		super._free();
	}
	
	override function _tick(tick:Int):Void
	{
		var circle = cast(_viewCircle.surface, CircleSurface).getShape();
		var segment = _viewSegment.getSegment();
		
		_fIntersect = IntersectSegmentSphere.find2(segment, circle, _tmpVec);
		_bIntersect = _fIntersect != -1;
		
		#if debug
		de.polygonal.core.macro.Assert.assert(IntersectSegmentSphere.test2(segment, circle) == _bIntersect, "IntersectSegmentSphere.test2(segment, circle) == _bIntersect");
		#end
	}
	
	override function _draw(alpha:Float):Void
	{
		var circle = cast(_viewCircle.surface, CircleSurface).getShape();
		var segment = _viewSegment.getSegment();
		
		_vr.circle(circle);
		_drawSegment(segment.a, segment.b);
		
		if (_bIntersect) _drawMarker(_tmpVec, Sprintf.format("%.2f", [_fIntersect]));
	}
}