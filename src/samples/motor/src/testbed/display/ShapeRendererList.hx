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

import de.polygonal.ds.DA;
import de.polygonal.ds.HashTable;
import de.polygonal.ds.Itr;
import de.polygonal.ds.Map;
import de.polygonal.gl.VectorRenderer;
import de.polygonal.motor.collision.shape.AbstractShape;
import de.polygonal.motor.dynamics.RigidBody;

class ShapeRendererList<T>
{
	var _list:DA<T>;
	var _listItr:Itr<T>;
	var _lookup:Map<AbstractShape, T>;
	
	public function new()
	{
		_list = new DA<T>();
		_listItr = cast _list.iterator();
		_lookup = new HashTable<AbstractShape, T>(512, 512);
	}
	
	public function free()
	{
		_list.free();
		_lookup.free();
		
		_list   = null;
		_lookup = null;
	}
	
	inline public function iterator():Iterator<T>
	{
		_listItr.reset(); return _listItr;
	}
	
	inline public function getRenderer(s:AbstractShape):T
	{
		return _lookup.get(s);
	}
	
	public function addRenderer(shapeRenderer:Class<T>, body:RigidBody, camera:Camera, vr:VectorRenderer):Void
	{
		for (shape in body.shapeList)
		{
			var renderer:T = Type.createInstance(shapeRenderer, [shape, camera, vr]);
			_list.pushBack(renderer);
			_lookup.set(shape, renderer);
		}
	}
	
	public function removeRenderer(shape:AbstractShape):Void
	{
		var renderer = getRenderer(shape);
		if (renderer != null)
		{
			_lookup.clr(shape);
			_list.remove(renderer);
		}
	}
}