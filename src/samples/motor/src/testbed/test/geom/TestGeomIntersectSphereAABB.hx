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

import de.polygonal.motor.geom.intersect.IntersectSphereAABB;
import de.polygonal.core.math.Vec2;
import de.polygonal.ui.trigger.surface.BoxSurface;
import de.polygonal.ui.trigger.surface.CircleSurface;
import de.polygonal.ui.trigger.Trigger;

class TestGeomIntersectSphereAABB extends TestGeom
{
	var _viewBox:Trigger;
	var _viewCircle:Trigger;
	
	var _normal:Vec2;
	
	override public function getName():String 
	{
		return "intersect sphere against AABB";
	}
	
	override function _init():Void
	{
		super._init();
		
		_viewBox = _createInteractiveBox(centerX - 100, centerY - 100, 200, 200);
		_viewCircle = cast _createInteractiveCircle(280, 220, 50);
		_viewBox.appendChild(_viewCircle);
		
		_normal = new Vec2();
	}
	
	override function _free():Void 
	{
		_viewBox.free();
		_viewCircle.free();
		super._free();
	}
	
	override function _tick(tick:Int):Void
	{
		var circle = cast(_viewCircle.surface, CircleSurface).getShape();
		var aabb = cast(_viewBox.surface, BoxSurface).getBound();
		
		_fIntersect = IntersectSphereAABB.find2(circle, aabb, _tmpVec, _normal);
		_bIntersect = _fIntersect < 0;
	}
	
	override function _draw(alpha:Float):Void
	{
		var circle = cast(_viewCircle.surface, CircleSurface).getShape();
		var aabb = cast(_viewBox.surface, BoxSurface).getBound();
		
		_vr.aabb(aabb);
		_vr.circle(circle);
		
		if (_bIntersect)
		{
			_drawMarker(_tmpVec);
			_vr.setLineStyle(0xFFFF00, 1, 0);
			_vr.arrowRay4(_tmpVec, _normal, _fIntersect, 6);
		}
	}
}
