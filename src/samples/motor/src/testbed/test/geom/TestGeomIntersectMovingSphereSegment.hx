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
import de.polygonal.ds.Bits;
import de.polygonal.motor.geom.intersect.IntersectMovingSphereSegment;
import de.polygonal.core.math.Vec2;
import de.polygonal.motor.geom.primitive.Segment2;
import de.polygonal.motor.geom.primitive.Sphere2;
import de.polygonal.ui.Key;
import de.polygonal.ui.trigger.behavior.MutableSegment;

using de.polygonal.ds.BitFlags;

class TestGeomIntersectMovingSphereSegment extends TestGeom
{
	inline static var DRAW_SWEPT_SHAPE = Bits.BIT_15;
	
	var _sphere:Sphere2;
	var _sphereSwept:MutableSegment;
	var _viewSegment:MutableSegment;
	
	override public function getName():String 
	{
		return "swept sphere against segment";
	}
	
	override function _init():Void
	{
		super._init();
		
		_viewSegment = _createInteractiveSegment(511, 189, 325, 397);
		_sphereSwept = _createInteractiveSegment(202, 264, 539, 297, 20, 400);
		
		_viewSegment.getTrigger().appendChild(_sphereSwept.getTrigger());
		
		_sphere = new Sphere2(0, 0, 30);
	}
	
	override function _free():Void 
	{
		_sphereSwept.free();
		_viewSegment.free();
		super._free();
	}
	
	override function _tick(tick:Int):Void
	{
		//synchronize model with view
		var s = _sphereSwept.getSegment();
		_movement.x = s.b.x - s.a.x;
		_movement.y = s.b.y - s.a.y;
		_sphere.c.x = _sphereSwept.getSegment().a.x;
		_sphere.c.y = _sphereSwept.getSegment().a.y;
		
		var segment = _viewSegment.getSegment();
		
		_fIntersect = IntersectMovingSphereSegment.find3(_sphere, segment, _movement, _tmpVec);
		_bIntersect = _fIntersect != -1;
	}
	
	override function _draw(alpha:Float):Void
	{
		_drawSegment(_viewSegment.getSegment().a, _viewSegment.getSegment().b);
		_vr.arrowLine3(_sphereSwept.getSegment().a, _sphereSwept.getSegment().b, 4);
		
		_vr.circle2(_sphereSwept.getSegment().a, _sphere.r);
		_vr.circle2(_sphereSwept.getSegment().b, _sphere.r);
		
		if (_bIntersect)
		{
			_vr.setLineStyle(0xff0000, 1, 0);
			
			if (_fIntersect == .0)
			{
				//var x = _tmpVec.x - _test.MTD.x;
				//var y = _tmpVec.y - _test.MTD.y;
				//_vr.arrowRay6(x, y, _test.MTD.x, _test.MTD.y, Vec2.norm(_test.MTD), 4);
				//drawBox(_tmpVec.x, _tmpVec.y);
			}
			else
			{
				var x = _sphere.c.x + _fIntersect * _movement.x;
				var y = _sphere.c.y + _fIntersect * _movement.y;
				_vr.circle3(x, y, _sphere.r);
				
				_drawMarker(_tmpVec);
				
				_annotate(_tmpVec, Sprintf.format("%.2f", [_fIntersect]));
				
				var dx = x - _tmpVec.x;
				var dy = y - _tmpVec.y;
				var k = Math.sqrt(dx * dx + dy * dy);
				dx /= k;
				dy /= k;
				_drawNormal(_tmpVec.x, _tmpVec.y, dx, dy);
			}
		}
		
		if (hasf(DRAW_SWEPT_SHAPE))
		{
			_vr.setLineStyle(0x00FFFF, 1, 0);
			_vr.ssl3(_viewSegment.getSegment().a, _viewSegment.getSegment().b, _sphere.r);
		}
	}
	
	override function _onKeyDown(keyCode:Int):Void
	{
		switch (keyCode)
		{
			case Key.F3:
				_menu.toggleMenuEntry(2);
				invf(DRAW_SWEPT_SHAPE);
		}
		
		super._onKeyDown(keyCode);
	}
	
	override function _initMenu(menuEntries:Array<String>, ?activeEntries = 0):Void
	{
		menuEntries.push("F3\tdraw swept shape");
		super._initMenu(menuEntries, activeEntries);
	}
}