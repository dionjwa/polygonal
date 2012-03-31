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
package de.polygonal.sys.scene;

import de.polygonal.core.math.Limits;
import de.polygonal.ds.LinkedStack;
import de.polygonal.sys.Entity;
import de.polygonal.sys.scene.transition.Transition;
import de.polygonal.core.util.Assert;

class SceneStack extends Entity
{
	var _transitions:Hash<Class<Transition>>;
	var _stack:LinkedStack<Scene>;
	
	public function new()
	{
		super();
		_transitions = new Hash<Class<Transition>>();
		_stack = new LinkedStack();
	}
	
	public function setTransition(a:Dynamic, b:Dynamic, transition:Class<Transition>, ?invertTransition:Class<Transition>):Void
	{
		_transitions.set(_key(a, b), transition);
		if (invertTransition != null)
			_transitions.set(_key(b, a), invertTransition);
	}
	
	public function setDefaultTransition(transition:Class<Transition>):Void
	{
		_transitions.set(_key(null, null), transition);
	}
	
	override public function add(child:Entity, priority = Limits.UINT16_MAX):Void 
	{
		throw 'use push() instead';
	}
	
	public function push(scene:Scene):Void
	{
		var a:Scene = _stack.isEmpty() ? null : _stack.top();
		var b:Scene = scene;
		
		_stack.push(scene);
		
		var z = node.numChildren();
		super.add(b, z);

		var transition = _getTransition(a, b);
		if (transition == null)
		{
			if (a != null)
			{
				a.onHide0(b);
				a.onHide1(b);
			}
			b.onShow0(a);
			b.onShow1(a);
			return;
		}
		
		super.add(transition);
	}
	
	public function pop():Void
	{
		var a = _stack.pop();
		var b = _stack.size() == 1 ? null : _stack.top();

		var transition = _getTransition(a, b);
		if (transition == null)
		{
			var n = a.node;
			while (n != null)
			{
				a.onHide0(b);
				a.onHide1(b);
				n = n.next;
			}
			b.onShow0(b);
			b.onShow1(b);
			return;
		}
		
		super.add(transition);
	}
	
	function _getTransition(a:Scene, b:Scene):Transition
	{
		var transitionClass = _transitions.get(_key(a, b));
		if (transitionClass == null)
			transitionClass = _transitions.get(_key(null, null));
		
		return
		if (transitionClass != null)
		{
			var transition = Type.createInstance(transitionClass, []);
			transition.id = 'transition';
			transition.a = cast a;
			transition.b = cast b;
			transition;
		}
		else
			null;
	}
	
	function _key(a:Dynamic, b:Dynamic):String
	{
		var key = '';
		if (Std.is(a, Scene))
			key += Std.string(a.id);
		else
			key += Std.string(a);
			
		if (Std.is(b, Scene))
			key += Std.string(b.id);
		else
			key += Std.string(b);
		return key;
	}
}