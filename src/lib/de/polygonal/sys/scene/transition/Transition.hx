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
package de.polygonal.sys.scene.transition;

import de.polygonal.core.math.Mathematics;
import de.polygonal.sys.Entity;
import de.polygonal.sys.scene.Scene;

class Transition extends Entity
{
	public var a:Scene;
	public var b:Scene;
	
	var _interval:Interval;
	var _duration:Float;
	var _mode:TransitionMode;
	var _phase:Int;
	
	function new(mode:TransitionMode, duration:Float)
	{
		super();
		
		_mode = mode;
		_duration = duration;
		_interval = new Interval(_duration);
		a = null;
		b = null;
		
		if (mode == TransitionMode.Sequential) _duration /= 2;
	}
	
	override function onFree():Void 
	{
		_interval = null;
		_mode = null;
		
		a = null;
		b = null;
	}
	
	override function onAdd(parent:Entity):Void
	{
		if (_mode == TransitionMode.Sequential)
		{
			if (a == null)
			{
				b.onShow0(null);
				onInit(b);
				return;
			}
			
			a.onHide0(b);
			onInit(a);
		}
		else
		if (_mode == TransitionMode.Simultaneous)
		{
			if (a != null)
			{
				a.onHide0(b);
				onInit(a);
			}
			
			b.onShow0(a);
			onInit(b);
		}
	}
	
	override function onAdvance(dt:Float, parent:Entity):Void
	{
		if (_mode == TransitionMode.Sequential)
		{
			var alpha = _interval.alpha;
			_interval.advance(dt);
			if (_phase == 0)
			{
				if (alpha >= 1)
				{
					if (a == null)
					{
						remove();
						onProgress(b, 1, 1);
						onDone(b);
						b.onShow1(null);
						return;
					}
					
					onProgress(a, 1, -1);
					onDone(a);
					
					_phase = 1;
					_interval.reset();
					
					a.onHide1(b);
					b.onShow0(a);
				}
				else
				{
					if (a != null)
						onProgress(a, alpha, -1);
					else
						onProgress(b, alpha, 1);
				}
			}
			else
			if (_phase == 1)
			{
				if (alpha >= 1)
				{
					remove();
					onProgress(b, 1, 1);
					onDone(b);
					b.onShow1(a);
				}
				else
					onProgress(b, alpha, 1);
			}
		}
		else
		if (_mode == TransitionMode.Simultaneous)
		{
			var alpha = _interval.alpha;
			_interval.advance(dt);
			if (alpha >= 1)
			{
				remove();
				if (a != null)
				{
					onProgress(a, 1, -1);
					onDone(a);
					a.onHide1(b);
				}
				onProgress(b, 1, 1);
				onDone(b);
				b.onShow1(a);
				return;
			}
			
			if (a != null) onProgress(a, alpha, -1);
			onProgress(b, alpha, 1);
		}
	}
	
	override function onRender(alpha:Float, parent:Entity):Void
	{
		
	}
	
	function onInit(scene:Scene):Void
	{
	}
	
	function onDone(scene:Scene):Void
	{
		
	}
	
	function onProgress(scene:Scene, x:Float, dir:Int):Void
	{
		throw 'override for implementation';
	}
}

private class Interval
{
	public var length:Float;
	
	var _t0:Float;
	var _t1:Float;
	var _length:Float;
	
	public var alpha(_alphaGetter, never):Float;
	function _alphaGetter():Float
	{
		return Mathematics.fmin(_t0 / _t1, 1);
	}
	
	public var hold:Bool;
	
	public function new(length:Float)
	{
		_t0 = 0;
		_t1 = length;
		_length = length;
	}
	
	inline public function reset():Void
	{
		_t0 = 0;
		_t1 = _length;
	}
	
	inline public function advance(dt:Float):Float
	{
		if (!hold) _t0 += dt;
		return alpha;
	}
}