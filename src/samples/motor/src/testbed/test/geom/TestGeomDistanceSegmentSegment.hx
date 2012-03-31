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
import de.polygonal.core.math.Vec2Util;
import de.polygonal.motor.geom.distance.DistanceSegmentSegment;
import de.polygonal.ui.trigger.behavior.MutableSegment;

class TestGeomDistanceSegmentSegment extends TestGeom
{
	var _viewSegmentA:MutableSegment;
	var _viewSegmentB:MutableSegment;
	
	var _distance:Float;
	
	override public function getName():String 
	{
		return "minimum distance between two segments";
	}
	
	override function _init():Void
	{
		super._init();
		
		_viewSegmentA = _createInteractiveSegment(300, 200, 400, 400);
		_viewSegmentB = _createInteractiveSegment(250, 250, 200, 300);
		
		_viewSegmentA.getTrigger().appendChild(_viewSegmentB.getTrigger());
	}
	
	override function _free():Void 
	{
		_viewSegmentA.free();
		_viewSegmentB.free();
		super._free();
	}
	
	override function _tick(tick:Int):Void
	{
		var segmentA = _viewSegmentA.getSegment();
		var segmentB = _viewSegmentB.getSegment();
		
		_distance = DistanceSegmentSegment.find2(segmentA, segmentB);
	}
	
	override function _draw(alpha:Float):Void
	{
		_vr.setLineStyle(0xffffff, 1, 0);
		
		var segmentA = _viewSegmentA.getSegment();
		var segmentB = _viewSegmentB.getSegment();
		
		_drawSegment(segmentA.a, segmentA.b);
		_drawSegment(segmentB.a, segmentB.b);
		
		Vec2Util.mid2(segmentA.a, segmentA.b, _tmpVec);
		var cx1 = _tmpVec.x;
		var cy1 = _tmpVec.y;
		
		Vec2Util.mid2(segmentB.a, segmentB.b, _tmpVec);
		var cx2 = _tmpVec.x;
		var cy2 = _tmpVec.y;
		
		Vec2Util.mid4(cx1, cy1, cx2, cy2, _tmpVec);
		
		_annotate(_tmpVec, Sprintf.format("%.2f", [Math.sqrt(_distance)])); 
	}
}