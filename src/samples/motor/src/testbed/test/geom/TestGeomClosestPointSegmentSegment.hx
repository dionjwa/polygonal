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
import de.polygonal.motor.geom.closest.ClosestPointSegmentSegment;
import de.polygonal.core.math.Vec2;
import de.polygonal.ui.trigger.behavior.MutableSegment;

class TestGeomClosestPointSegmentSegment extends TestGeom
{
	var _viewSegmentA:MutableSegment;
	var _viewSegmentB:MutableSegment;
	
	var _closestPointA:Vec2;
	var _closestPointB:Vec2;
	
	var _distance:Float;
	
	override public function getName():String 
	{
		return "closest points between two segments";
	}
	
	override function _init():Void
	{
		super._init();
		
		_closestPointA = new Vec2();
		_closestPointB = new Vec2();
		
		_viewSegmentA = _createInteractiveSegment(300, 200, 400, 400);
		_viewSegmentB = _createInteractiveSegment(250, 250, 200, 300);
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
		
		_distance = ClosestPointSegmentSegment.find2(segmentA, segmentB, _closestPointA, _closestPointB);
	}
	
	override function _draw(alpha:Float):Void
	{
		var segmentA = _viewSegmentA.getSegment();
		var segmentB = _viewSegmentB.getSegment();
		
		_vr.setLineStyle(0xFFFFFF, 1, 0);
		_drawSegment(segmentA.a, segmentA.b);
		_drawSegment(segmentB.a, segmentB.b);
		
		_vr.clearStroke();
		_vr.setFillColor(0xFFFF00, 1);
		_vr.fillStart();
		
		_vr.box2(_closestPointA, 4);
		_vr.box2(_closestPointB, 4);
		_vr.fillEnd();
		
		_vr.setLineStyle(0x00FF00, 1, 0);
		_vr.line2(_closestPointA, _closestPointB);
	}
}