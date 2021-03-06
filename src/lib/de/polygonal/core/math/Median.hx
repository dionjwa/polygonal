﻿/*
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
package de.polygonal.core.math;

import de.polygonal.ds.mem.DoubleMemory;

/**
 * <p>The median of a set of numbers.</p>
 */
class Median
{
	var _i:Int;
	var _s:Int;
	var _k:Int;
	
	var _val:Float;
	var _set:DoubleMemory;
	var _invalidate:Bool;
	
	/**
	 * @param size the size of the number set.
	 */
	public function new(size:Int)
	{
		_set = new DoubleMemory(_s = size, "Median._set");
		_set.fill(0);
		_val = 0;
	}
	
	/**
	 * Destroys this object by explicitly nullifying all references for GC'ing used resources.<br/>
	 * <warn>Always call this method to prevent a memory leak.</warn>
	 */
	public function free():Void
	{
		_set.free();
		_set = null;
	}
	
	/**
	 * Inserts <code>x</code> into the number set.
	 */
	inline public function add(x:Float):Void
	{
		_set.set(_i, x);
		_i = (_i + 1) % _s;
		_k = _k < _s ? _k + 1: _k;
		_invalidate = true;
	}
	
	/**
	 * Computes the median value.
	 */
	inline public function val():Float
	{
		if (_invalidate)
		{
			var k = _k;
			
			//insertion sort
			for (i in 1...k)
			{
				var x = _set.get(i);
				var j = i;
				while ((j > 0) && (_set.get(j - 1) > x))
				{
					_set.set(j, _set.get(j - 1));
					j--;
				}
				_set.set(j, x);
			}
			
			if (k == 0)
				_val = 0;
			else
			{
				if (Mathematics.isEven(k))
				{
					if (k == 2)
						_val = (_set.get(0) + _set.get(1)) * .5;
					else
						_val = (_set.get((k >> 1)) + _set.get(((k >> 1)) - 1)) * .5;
				}
				else
					_val =  _set.get(k >> 1);
			}
		}
		
		return _val;
	}
	
	/**
	 * Clears all values.
	 */
	inline public function clear():Void
	{
		_i = 0;
		_k = 0;
		_val = 0;
		_invalidate = true;
	}
}