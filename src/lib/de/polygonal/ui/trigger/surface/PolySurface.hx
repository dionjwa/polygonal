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

import de.polygonal.core.math.Mathematics;
import de.polygonal.core.math.Vec2;
import de.polygonal.motor.geom.inside.PointInsidePoly;
import de.polygonal.motor.geom.primitive.Poly2;
import de.polygonal.ui.trigger.pointer.Pointer;

class PolySurface extends AbstractSurface
{
	var _shape:Poly2;
	var _pos:Vec2;
	
	public function new(x:Float, y:Float, poly:Poly2)
	{
		super();
		
		_shape = poly;
		_pos = new Vec2(x, y);
		setCenter(x, y);
	}
	
	override public function free():Void
	{
		_shape.free();
		_shape = null;
		_pos = null;
		super.free();
	}
	
	inline public function shape():Poly2
	{
		_syncProxy = true;
		return _shape;
	}
	
	inline public function getShape():Poly2
	{
		return _shape;
	}
	
	override public function isTouching(pointer:Pointer):Bool
	{
		return PointInsidePoly.test(pointer.position(), _shape);
	}
	
	override public function getCenter():Vec2
	{
		return _pos;
	}
	
	override public function setCenter(x:Float, y:Float):Void
	{
		_pos.x = x;
		_pos.y = y;
		_shape.transform(x, y, 0);
		_syncProxy = true;
	}
	
	override function _updateProxy():Void
	{
		_shape.getBound(getBound());
	}
}