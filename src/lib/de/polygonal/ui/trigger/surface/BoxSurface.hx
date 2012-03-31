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
package de.polygonal.ui.trigger.surface;

import de.polygonal.core.math.Vec2;
import de.polygonal.motor.geom.inside.PointInsideAABB;
import de.polygonal.motor.geom.primitive.AABB2;
import de.polygonal.ui.trigger.pointer.Pointer;

using de.polygonal.ds.BitFlags;

class BoxSurface extends AbstractSurface
{
	public static function ofAABB(x:AABB2):BoxSurface
	{
		return new BoxSurface(x.minX, x.minY, x.intervalX, x.intervalY);
	}
	
	var _tmp:Vec2;
	
	public function new(x:Float, y:Float, width:Float, height:Float)
	{
		super();
		_bound.minX = x;
		_bound.minY = y;
		_bound.maxX = x + width;
		_bound.maxY = y + height;
		_tmp = new Vec2();
	}
	
	override public function free():Void 
	{
		_tmp = null;
		super.free();
	}
	
	override public function isTouching(pointer:Pointer):Bool
	{
		return PointInsideAABB.test2(pointer.position(), _bound);
	}
	
	override public function getCenter():Vec2
	{
		_tmp.x = _bound.centerX;
		_tmp.y = _bound.centerY;
		return _tmp;
	}
	
	override public function setCenter(x:Float, y:Float):Void
	{
		_bound.centerX = x;
		_bound.centerY = y;
	}
	
	inline public function shape():AABB2
	{
		return _bound;
	}
	
	override function _updateProxy():Void 
	{
	}
}