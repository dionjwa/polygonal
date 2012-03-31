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
package testbed.display;

import de.polygonal.core.math.Vec2;

/**
 * A simple viewport for transforming world coordinates to screen coordinates and vice versa.
 */
class Camera
{
	public var x:Float;
	public var y:Float;
	public var zoom:Float;
	
	public function new(x:Float, y:Float, zoom:Float)
	{
		this.x = x;
		this.y = y;
		this.zoom = zoom;
	}
	
	inline public function scale(x:Float):Float
	{
		return x * zoom;
	}
	
	inline public function scaleInverse(x:Float):Float
	{
		return x * 1 / zoom;
	}
	
	inline public function toScreen(worldPoint:Vec2, screenPoint:Vec2):Vec2
	{
		screenPoint.x = toScreenX(worldPoint.x);
		screenPoint.y = toScreenY(worldPoint.y);
		return screenPoint;
	}
	
	inline public function toScreenX(x:Float):Float { return x * zoom + this.x; }
	inline public function toScreenY(y:Float):Float { return y * zoom + this.y; }
	
	inline public function toWorld(screenPoint:Vec2, worldPoint:Vec2):Vec2
	{
		worldPoint.x = toWorldX(screenPoint.x);
		worldPoint.y = toWorldY(screenPoint.y);
		return worldPoint;
	}
	
	inline public function toWorldX(x:Float):Float { return (x - this.x) / zoom; }
	inline public function toWorldY(y:Float):Float { return (y - this.y) / zoom; }
}