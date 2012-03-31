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
import de.polygonal.motor.geom.intersect.IntersectMovingSphereSphere;
import de.polygonal.core.math.Vec2;
import de.polygonal.ui.trigger.behavior.MutableSegment;

class TestGeomIntersectMovingSphereSphere extends TestGeom
{
	var _sphereSwept1:MutableSegment;
	var _sphereSwept2:MutableSegment;
	
	var _radius1:Float;
	var _radius2:Float;
	
	var _v0:Vec2;
	var _v1:Vec2;
	
	override public function getName():String 
	{
		return "swept sphere against sphere";
	}
	
	override function _init():Void
	{
		super._init();
		
		_sphereSwept1 = _createInteractiveSegment(100, centerY + 30, centerX, centerY, 20, 400);
		_sphereSwept2 = _createInteractiveSegment(centerX + 200, centerY + 100, centerX, centerY + 50, 20, 400);
		
		_sphereSwept1.getTrigger().appendChild(_sphereSwept2.getTrigger());
		
		_radius1 = 40;
		_radius2 = 30;
		
		_v0 = new Vec2();
		_v1 = new Vec2();
	}
	
	override private function _free():Void 
	{
		_sphereSwept1.free();
		_sphereSwept2.free();
		super._free();
	}
	
	override function _tick(tick:Int):Void
	{
		var s1 = _sphereSwept1.getSegment();
		var s2 = _sphereSwept2.getSegment();
		
		_v0.x = s1.b.x - s1.a.x;
		_v0.y = s1.b.y - s1.a.y;
		
		_v1.x = s2.b.x - s2.a.x;
		_v1.y = s2.b.y - s2.a.y;
		
		_fIntersect = IntersectMovingSphereSphere.find10
			(
				s1.a.x, s1.a.y, _radius1,
				s2.a.x, s2.a.y, _radius2,
				_v0.x, _v0.y, _v1.x, _v1.y
			);
		
		_bIntersect = _fIntersect != -1 && _fIntersect <= 1.;
	}
	
	override function _draw(alpha:Float):Void
	{
		var s1 = _sphereSwept1.getSegment();
		var s2 = _sphereSwept2.getSegment();
		
		_vr.circle2(s1.a, _radius1);
		_vr.circle2(s1.b, _radius1);
		
		_vr.circle2(s2.a, _radius2);
		_vr.circle2(s2.b, _radius2);
		
		_vr.arrowLine3(s1.a, s1.b, 4);
		_vr.arrowLine3(s2.a, s2.b, 4);
		
		if (_bIntersect)
		{
			_vr.setLineStyle(0xff0000, 1, 0);
			
			var x1 = s1.a.x + _v0.x * _fIntersect;
			var y1 = s1.a.y + _v0.y * _fIntersect;
			
			var x2 = s2.a.x + _v1.x * _fIntersect;
			var y2 = s2.a.y + _v1.y * _fIntersect;
			
			_vr.circle3(x1, y1, _radius1);
			_vr.circle3(x2, y2, _radius2);
			
			_tmpVec.x = x1 + (x2 - x1) / 2;
			_tmpVec.y = y1 + (y2 - y1) / 2;
			
			_drawMarker(_tmpVec);
			_annotate(_tmpVec, Sprintf.format("%.2f", [_fIntersect]));
		}
	}
}