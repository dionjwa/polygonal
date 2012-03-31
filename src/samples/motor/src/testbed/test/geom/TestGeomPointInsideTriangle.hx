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

import de.polygonal.motor.collision.shape.feature.Vertex;
import de.polygonal.motor.geom.inside.PointInsideTriangle;
import de.polygonal.core.math.Vec2;
import de.polygonal.motor.geom.primitive.Poly2;

class TestGeomPointInsideTriangle extends TestGeom
{
	var _vTri1:Vec2;
	var _vTri2:Vec2;
	var _vTri3:Vec2;
	
	override public function getName():String 
	{
		return "point inside triangle";
	}
	
	override function _init():Void
	{
		super._init();
		
		var poly = Poly2.createBlob(3, 100);
		poly.transform(centerX, centerY, Math.PI / 4);
		
		var a = Vertex.toArray(poly.worldVertexChain);
		_vTri1 = a[0];
		_vTri2 = a[1];
		_vTri3 = a[2];
	}
	
	override function _tick(tick:Int):Void
	{
		_bIntersect = PointInsideTriangle.test4(mouse, _vTri1, _vTri2, _vTri3);
	}
	
	override function _draw(alpha:Float):Void
	{
		_vr.tri3(_vTri1, _vTri2, _vTri3);
		_drawMarker(mouse, "", _bIntersect ? 0xFF0000 : 0x00FF00);
	}
}