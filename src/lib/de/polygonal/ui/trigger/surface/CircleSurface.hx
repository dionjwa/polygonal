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
import de.polygonal.motor.geom.inside.PointInsideSphere;
import de.polygonal.motor.geom.primitive.Sphere2;
import de.polygonal.ui.trigger.pointer.Pointer;

class CircleSurface extends AbstractSurface
{
	var _shape:Sphere2;
	
	public function new(x:Float, y:Float, radius:Float)
	{
		super();
		_shape = new Sphere2(x, y, radius);
	}
	
	override public function free():Void
	{
		_shape = null;
		super.free();
	}
	
	override public function isTouching(pointer:Pointer):Bool 
	{
		return PointInsideSphere.test2(pointer.position(), _shape);
	}
	
	override public function getCenter():Vec2 
	{
		return _shape.c;
	}
	
	override public function setCenter(x:Float, y:Float):Void
	{
		_shape.c.x = x;
		_shape.c.y = y;
		_syncProxy = true;
	}
	
	inline public function shape():Sphere2
	{
		_syncProxy = true;
		return _shape;
	}
	
	inline public function getShape():Sphere2
	{
		return _shape;
	}
	
	override function _updateProxy():Void
	{
		var r = _shape.r;
		var c = _shape.c;
		var x = c.x;
		var y = c.y;
		_bound.set4(x - r, y - r, x + r, y + r);
	}
}