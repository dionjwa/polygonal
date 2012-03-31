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
import de.polygonal.motor.collision.shape.feature.Vertex;
import de.polygonal.motor.geom.intersect.IntersectMovingSpherePoly;
import de.polygonal.core.math.Vec2;
import de.polygonal.motor.geom.primitive.Poly2;
import de.polygonal.motor.geom.primitive.Sphere2;
import de.polygonal.ui.Key;
import de.polygonal.ui.trigger.behavior.MutableSegment;
import de.polygonal.ui.trigger.surface.PolySurface;

using de.polygonal.ds.BitFlags;

class TestGeomIntersectMovingSpherePoly extends TestGeom
{
	inline static var DRAW_SWEPT_SHAPE = Bits.BIT_15;
	
	var _sphere:Sphere2;
	var _sphereSwept:MutableSegment;
	
	var _poly:Poly2;
	var _vertexList:Array<Vec2>;
	
	override public function getName():String 
	{
		return "swept sphere against poly";
	}
	
	override function _init():Void
	{
		super._init();

		_sphere = new Sphere2(0, 0, 30);
		_sphereSwept = _createInteractiveSegment(100, centerY + 40, 300, centerY - 40, 20, 400);
		
		var polyView = _createInteractivePoly(centerX, centerY, 6, 100);
		_poly = cast (polyView.surface, PolySurface).getShape();
		_vertexList = cast Vertex.toArray(_poly.worldVertexChain);
		
		polyView.appendChild(_sphereSwept.getTrigger());
	}
	
	override function _free():Void 
	{
		_sphereSwept.free();
		super._free();
	}
	
	override function _tick(tick:Int):Void
	{
		//synchronize model with view
		var s = _sphereSwept.getSegment();
		_movement.x = s.b.x - s.a.x;
		_movement.y = s.b.y - s.a.y;
		var i = 0;
		for (v in _poly.worldVertexChain)
		{
			_vertexList[i].x = v.x;
			_vertexList[i].y = v.y;
			i++;
		}
		
		_sphere.c.x = s.a.x;
		_sphere.c.y = s.a.y;
		
		_fIntersect = IntersectMovingSpherePoly.find3(_sphere, _movement, _poly, _tmpVec);
		_bIntersect = _fIntersect != -1 && _fIntersect <= 1;
	}
	
	override function _draw(alpha:Float):Void
	{
		_vr.arrowLine3(_sphereSwept.getSegment().a, _sphereSwept.getSegment().b, 4);
		_vr.circle2(_sphereSwept.getSegment().a, _sphere.r);
		_vr.circle2(_sphereSwept.getSegment().b, _sphere.r);
		
		_vr.polyLineVector(cast _vertexList, true);
		
		if (_bIntersect)
		{
			_vr.setLineStyle(0xff0000, 1, 0);
			_vr.circle2(_tmpVec, _sphere.r);
			_annotate(_tmpVec, Sprintf.format("%.2f", [_fIntersect]));
		}
		
		if (hasf(DRAW_SWEPT_SHAPE))
		{
			_vr.setLineStyle(0x00FFFF, 1, 0);
			_vr.ssp(_vertexList, _sphere.r);
				
			if (_bIntersect)
			{
				_vr.clearStroke();
				_vr.setFillColor(0xFFFF00, 1);
				_vr.fillStart();
				_vr.box3(_tmpVec.x, _tmpVec.y, 4);
				_vr.fillEnd();
			}
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
