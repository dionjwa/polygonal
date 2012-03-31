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
import de.polygonal.motor.geom.intersect.IntersectSegmentAABB;
import de.polygonal.motor.geom.intersect.ClipInfo;
import de.polygonal.ui.trigger.behavior.MutableSegment;
import de.polygonal.ui.trigger.surface.BoxSurface;
import de.polygonal.ui.trigger.Trigger;

class TestGeomIntersectSegmentAABB extends TestGeom
{
	var _viewSegment:MutableSegment;
	var _viewBox:Trigger;
	
	var _clipResult:ClipInfo;
	
	override public function getName():String 
	{
		return "intersect segment against AABB";
	}
	
	override function _init():Void
	{
		super._init();
		
		_viewSegment = _createInteractiveSegment(centerX - 100, centerY - 100, 500, 200, 20, 200);
		_viewBox = _createInteractiveBox(centerX - 100, centerY - 100, 200, 200);
		_viewBox.appendChild(_viewSegment.getTrigger());
		
		_clipResult = new ClipInfo();
	}
	
	override function _free():Void
	{
		_viewSegment.free();
		super._free();
	}
	
	override function _tick(tick:Int):Void
	{
		var segment = _viewSegment.getSegment();
		var aabb = cast(_viewBox.surface, BoxSurface).getBound();
		
		_bIntersect = IntersectSegmentAABB.find5(segment.a.x, segment.a.y, segment.b.x, segment.b.y, aabb, _clipResult);
		trace( "_bIntersect : " + _bIntersect );
		
		#if debug
		de.polygonal.core.macro.Assert.assert(_bIntersect == IntersectSegmentAABB.test5(segment.a.x, segment.a.y, segment.b.x, segment.b.y, aabb), "_bIntersect == IntersectSegmentAABB.test5(segment.a.x, segment.a.y, segment.b.x, segment.b.y, aabb)");
		#end
	}
	
	override function _draw(alpha:Float):Void
	{
		var segment = _viewSegment.getSegment();
		_drawSegment(segment.a, segment.b);
		var aabb = cast(_viewBox.surface, BoxSurface).getBound();
		_vr.aabb(aabb);
		
		if (_bIntersect)
		{
			_vr.clearStroke();
			_vr.setFillColor(0xFFFF00, 1);
			
			var dx = segment.b.x - segment.a.x;
			var dy = segment.b.y - segment.a.y;
			
			_tmpVec.x = segment.a.x + dx * _clipResult.t0;
			_tmpVec.y = segment.a.y + dy * _clipResult.t0;
			_drawMarker(_tmpVec, Sprintf.format("%.2f %d", [_clipResult.t0, _clipResult.e0]));
			
			_tmpVec.x = segment.a.x + dx * _clipResult.t1;
			_tmpVec.y = segment.a.y + dy * _clipResult.t1;
			_drawMarker(_tmpVec, Sprintf.format("%.2f %d", [_clipResult.t1, _clipResult.e1]));
		}
	}
}