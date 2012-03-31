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
import de.polygonal.motor.geom.inside.PointInsidePoly;
import de.polygonal.core.math.Vec2;
import de.polygonal.motor.geom.primitive.Poly2;

class TestGeomPointInsidePoly extends TestGeom
{
	var _vertexList:Array<Vec2>;
	
	override public function getName():String 
	{
		return "point inside poly";
	}
	
	override function _init():Void
	{
		super._init();
		
		var tmp = Poly2.createBlob(7, 100);
		tmp.transform(centerX, centerY, Math.PI / 4);
		_vertexList = cast Vertex.toArray(tmp.worldVertexChain);
	}
	
	override function _tick(tick:Int):Void
	{
		_bIntersect = PointInsidePoly.testArray2(mouse, cast _vertexList);
	}
	
	override function _draw(alpha:Float):Void
	{
		_vr.polyLineVector(_vertexList, true);
		_drawMarker(mouse, "", _bIntersect ? 0xFF0000 : 0x00FF00);
	}
}