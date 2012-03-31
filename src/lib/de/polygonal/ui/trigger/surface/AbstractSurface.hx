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
import de.polygonal.ds.Bits;
import de.polygonal.ds.DA;
import de.polygonal.motor.geom.primitive.AABB2;
import de.polygonal.ui.trigger.pointer.Pointer;

class AbstractSurface implements Surface
{
	public var userData:Dynamic;
	public var applyConstraints:Bool;
	
	var _bound:AABB2;
	var _constraints:DA<SurfaceConstraint>;
	var _constraintMap:Hash<SurfaceConstraint>;
	var _syncProxy:Bool;
	
	function new()
	{
		applyConstraints = true;
		userData = null;
		
		_bound = new AABB2();
		_constraints = null;
		_constraintMap = null;
		_syncProxy = true;
	}
	
	public function free():Void
	{
		userData = null;
		
		_bound = null;
		if (_constraints != null)
		{
			_constraints.free();
			_constraints = null;
			_constraintMap = null;
		}
	}
	
	public function getCenter():Vec2
	{
		return throw 'override for implementation';
	}
	
	public function setCenter(x:Float, y:Float):Void
	{
		throw 'override for implementation';
	}
	
	public function getBound():AABB2
	{
		return _bound;
	}
	
	public function isTouching(pointer:Pointer):Bool
	{
		return throw 'override for implementation';
	}
	
	public function update():Void
	{
		if (applyConstraints && _constraints != null)
		{
			for (constraint in _constraints)
			{
				var center = getCenter();
				constraint.evaluate(center);
				setCenter(center.x, center.y);
			}
		}
		
		if (_syncProxy)
		{
			_syncProxy = false;
			_updateProxy();
		}
	}
	
	public function getConstraint(name:String):SurfaceConstraint
	{
		if (_constraintMap == null) return null;
		return _constraintMap.get(name);
	}
	
	public function registerConstraint(x:SurfaceConstraint, ?name:String):Void
	{
		if (_constraintMap == null)
		{
			_constraintMap = new Hash();
			_constraints = new DA();
			_constraints.reuseIterator = true;
		}
		if (name != null)
		{
			if (_constraintMap.exists(name)) return;
			_constraintMap.set(name, x);
		}
		_constraints.pushBack(x);
		update();
	}
	
	public function unregisterConstraint(name:String):Void
	{
		if (_constraintMap == null) return;
		if (_constraintMap.exists(name))
		{
			var constraint = _constraintMap.get(name);
			_constraintMap.remove(name);
			_constraints.remove(constraint);
			update();
		}
	}
	
	function _updateProxy():Void
	{
		throw 'override for implementation';
	}
}