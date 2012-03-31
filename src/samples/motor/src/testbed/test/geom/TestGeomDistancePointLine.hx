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
import de.polygonal.core.math.random.Random;
import de.polygonal.motor.geom.distance.DistancePointLine;
import de.polygonal.core.math.Vec2;

class TestGeomDistancePointLine extends TestGeom
{
	var _a:Vec2;
	var _b:Vec2;
	var _distance:Float;
	
	override public function getName():String 
	{
		return "minimum distance point to line";
	}
	
	override function _init():Void
	{
		super._init();
		
		var angle = Random.frandSym(Math.PI);
		var c = Math.cos(angle);
		var s = Math.sin(angle);
		_a = new Vec2(centerX - c, centerY - s);
		_b = new Vec2(centerX + c, centerY + s);_tmpVec.x = 0;
		_tmpVec.x = 0;
		_tmpVec.y =-20;
	}
	
	override function _tick(tick:Int):Void
	{
		_distance = DistancePointLine.find3(mouse, _a, _b);
	}
	
	override function _draw(alpha:Float):Void
	{
		var dx = _b.x - _a.x;
		var dy = _b.y - _a.y;
		_vr.setLineStyle(0xffffff, 1, 0);
		_vr.planeThroughPoint10(_a.x, _a.y, dy, -dx, bound.minX, bound.minY, bound.maxX, bound.maxY, 0, 0);
		_drawMarker(mouse, Sprintf.format("%.2f", [Math.sqrt(_distance)]), 0xFFFF00, _tmpVec);
	}
}