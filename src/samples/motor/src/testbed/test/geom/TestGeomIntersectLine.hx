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
import de.polygonal.motor.geom.intersect.IntersectLine;
import de.polygonal.motor.geom.primitive.Plane2;
import de.polygonal.ui.trigger.behavior.MutableSegment;

class TestGeomIntersectLine extends TestGeom
{
	var _viewSegment1:MutableSegment;
	var _viewSegment2:MutableSegment;
	
	var _plane:Plane2;
	
	override public function getName():String 
	{
		return "intersect line against line";
	}
	
	override function _init():Void
	{
		super._init();
		
		_viewSegment1 = _createInteractiveSegment(250, 250, 350, 350, 20, 200);
		_viewSegment2 = _createInteractiveSegment(400, 300, 200, 330, 20, 200);
		
		_viewSegment1.trigger.appendChild(_viewSegment2.trigger);
		
		_plane = new Plane2();
	}
	
	override function _free():Void
	{
		_viewSegment1.free();
		_viewSegment2.free();
		super._free();
	}
	
	override function _tick(tick:Int):Void
	{
		var segment1 = _viewSegment1.segment;
		var segment2 = _viewSegment2.segment;
		
		_fIntersect = IntersectLine.find2(segment1, segment2, _tmpVec);
		_bIntersect = _fIntersect != -1;
		
		#if debug
		de.polygonal.core.macro.Assert.assert(_bIntersect == IntersectLine.test2(segment1, segment2), "_bIntersect == IntersectLine.test2(segment1, segment2)");
		#end
	}
	
	override function _draw(alpha:Float):Void
	{
		var segment1 = _viewSegment1.segment;
		var segment2 = _viewSegment2.segment;
		
		_vr.line2(segment1.a, segment1.b);
		_vr.line2(segment2.a, segment2.b);
		
		_vr.style.lineAlpha = .25;
		_vr.applyLineStyle();
		
		_plane.setFromPoints2(segment1.a, segment1.b);
		_vr.plane4(_plane, bound, 0, 4);
		_plane.setFromPoints2(segment2.a, segment2.b);
		_vr.plane4(_plane, bound, 0, 4);
		
		if (_bIntersect)
		{
			_drawMarker(_tmpVec);
			_annotate(_tmpVec, Sprintf.format("%.2f", [_fIntersect]));
		}
	}
}