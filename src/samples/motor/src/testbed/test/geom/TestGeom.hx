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

import de.polygonal.core.event.IObservable;
import de.polygonal.core.math.Mathematics;
import de.polygonal.core.math.Vec2Util;
import de.polygonal.core.Root;
import de.polygonal.ds.Bits;
import de.polygonal.gl.Window;
import de.polygonal.core.math.Vec2;
import de.polygonal.core.math.Vec2;
import de.polygonal.motor.geom.primitive.AABB2;
import de.polygonal.motor.geom.primitive.Poly2;
import de.polygonal.motor.geom.primitive.Sphere2;
import de.polygonal.ui.Key;
import de.polygonal.ui.trigger.behavior.MutableSegment;
import de.polygonal.ui.trigger.pointer.MousePointer;
import de.polygonal.ui.trigger.surface.BoxSurface;
import de.polygonal.ui.trigger.surface.CircleSurface;
import de.polygonal.ui.trigger.surface.PolySurface;
import de.polygonal.ui.trigger.Trigger;
import de.polygonal.ui.trigger.TriggerEvent;
import de.polygonal.ui.UI;
import de.polygonal.ui.UIEvent;
import testbed.test.TestCase;
import testbed.test.TestRunner;

using de.polygonal.ds.BitFlags;

class TestGeom extends TestCase
{
	inline static var SNAP_ACTIVE = Bits.BIT_01;
	inline static var DRAW_GRID   = Bits.BIT_02;
	
	public static var ACTIVE_FLAGS = DRAW_GRID;
	
	public static var SPEED = 5.0;
	
	var _speed:Float;
	
	var _text:String;
	var _triggerList:Array<Trigger>;
	
	var _movement:Vec2;
	
	var _bIntersect:Bool;
	var _fIntersect:Float;
	
	function new() 
	{
		super();
		
		_movement = new Vec2();
		_triggerList = new Array<Trigger>();
		
	}
	
	public var centerX(_centerXGetter, never):Float;
	inline function _centerXGetter():Float { return bound.centerX; }
	
	public var centerY(_centerYGetter, never):Float;
	inline function _centerYGetter():Float { return bound.centerY; }
	
	public var bound(_boundGetter, never):AABB2;
	inline function _boundGetter():AABB2 { return Window.bound(); }
	
	public var mouse(_mouseGetter, never):Vec2;
	inline function _mouseGetter():Vec2
	{
		var p = UI.instance().mouse;
		if (hasf(SNAP_ACTIVE))
		{
			var snap = _camera.scale(.5);
			p.x = Mathematics.snap(p.x, snap) * snap;
			p.y = Mathematics.snap(p.y, snap) * snap;
		}
		
		return p;
	}
	
	override public function update(type:Int, source:IObservable, userData:Dynamic):Void
	{
		super.update(type, source, userData);
		
		if (UIEvent.has(type))
		{
			if (type == UIEvent.MOUSE_WHEEL)
			{
				var delta = userData;
				
				for (trigger in _triggerList)
				{
					if (Std.is(trigger.userData, Sphere2))
					{
						var s = cast(trigger.userData, Sphere2);
						
						var p = MousePointer.instance().position();
						
						var dx = p.x - s.c.x;
						var dy = p.y - s.c.y;
						if (dx * dx + dy * dy < s.r * s.r)
						{
							s.r += userData;
						}
					}
				}
			}
		}
		else
		if (TriggerEvent.has(type))
		{
			if (type == TriggerEvent.DRAG)
			{
				var trigger = cast(source, Trigger);
				var p = trigger.pointer.position();
				
				if (Std.is(trigger.userData, Sphere2))
				{
					var c = cast(trigger.userData, Sphere2).c;
					c.x = p.x;
					c.y = p.y;
				}
			}
		}
	}
	
	override function _free():Void
	{
		ACTIVE_FLAGS = _bits;
		
		for (trigger in _triggerList)
		{
			trigger.detach(this);
			trigger.free();
		}
		super._free();
	}
	
	override function _init():Void
	{
		_bits = ACTIVE_FLAGS;
		_speed = SPEED;
		
		_tmpVec = new Vec2();
		_movement = new Vec2();
		
		//setup menu
		var menuEntries = new Array<String>();
		menuEntries.push("F1\tmenu");
		menuEntries.push("F2\tsnap to grid");
		menuEntries.push("g\tdraw grid");
		menuEntries.push("<- -> prev/next test");
		_initMenu(menuEntries, _bits);
	}
	
	override function _onKeyDown(keyCode:Int):Void
	{
		switch (keyCode)
		{
			case Key.F1:
				_menu.toggleMenu();
			
			case Key.F2:
				_menu.toggleMenuEntry(1);
				invf(SNAP_ACTIVE);
				MousePointer.instance().snap = hasf(SNAP_ACTIVE) ? _camera.scale(.5) : 0;
				
			case Key.G:
				_menu.toggleMenuEntry(2);
				invf(DRAW_GRID);
		}
	}
	
	override function _tickInternal(tick:Int):Void
	{
		_tick(tick);
	}
	
	function _tick(tick:Int):Void {}
	
	override function _drawInternal(alpha:Float):Void
	{
		if (hasf(DRAW_GRID))
		{
			_drawViewCenter();
			_drawGrid();
		}
		
		if (_text != null)
		{
			_vr.clearStroke();
			_vr.setFillColor(0xffffff, 1);
			_vr.fillStart();
			
			TestCase.getFont().write(_text, Window.bound().maxX - 300, Window.bound().intervalY - 10, false);
			_vr.fillEnd();
		}
		
		_setDefaultLineStyle();
		_draw(alpha);
	}
	
	function _draw(alpha:Float):Void
	{
		throw "override for implementation";
	}
	
	function _drawNormal(px:Float, py:Float, nx:Float, ny:Float)
	{
		_vr.setLineStyle(0xFFFF00, 1, 0);
		_vr.arrowRay6(px, py, nx, ny, 20, 4);
	}
	
	function _createInteractiveSegment(ax:Float, ay:Float, bx:Float, by:Float, ?minLength = .0, ?maxLength = .0, ?infinite = false)
	{
		var s = new MutableSegment(ax, ay, bx, by, 10, null, infinite);
		//if (minLength != 0) s.minLength = minLength;
		//if (maxLength != 0) s.maxLength = maxLength;
		return s;
	}
	
	function _createInteractiveBox(x:Float, y:Float, w:Float, h:Float):Trigger
	{
		var trigger = new Trigger(new BoxSurface(x, y, w, h));
		trigger.dragEnabled = true;
		_triggerList.push(trigger);
		return trigger;
	}
	
	function _createInteractiveCircle(x:Float, y:Float, r:Float):Trigger
	{
		var trigger = new Trigger(new CircleSurface(x, y, r));
		trigger.dragEnabled = true;
		_triggerList.push(trigger);
		return trigger;
	}
	
	function _createInteractivePoly(x:Float, y:Float, sides:Int, radius:Float):Trigger
	{
		var trigger = new Trigger(new PolySurface(x, y, Poly2.createBlob(sides, radius)));
		trigger.dragEnabled = true;
		_triggerList.push(trigger);
		return trigger;
	}
	
	function _makeSphereInteractive(sphere:Sphere2):Trigger
	{
		var trigger = new Trigger(new CircleSurface(sphere.c.x, sphere.c.y, sphere.r));
		trigger.dragEnabled = true;
		trigger.attach(this);
		trigger.userData = sphere;
		
		_triggerList.push(trigger);
		
		return trigger;
	}
	
	function _setDefaultLineStyle()
	{
		_vr.setLineStyle(0xffffff, _bIntersect ? 1 : .5, 0);
	}
	
	function _drawSegment(a:Vec2, b:Vec2)
	{
		_vr.arrowLine3(a, b, 6);
		
		var dx =-b.y + a.y;
		var dy = b.x - a.x;
		var l = Vec2Util.length(dx, dy);
		dx /= l;
		dy /= l;
		var e = 8;
		
		_vr.moveTo2(a.x + dx * e, a.y + dy * e);
		_vr.lineTo2(a.x - dx * e, a.y - dy * e);
		
		_vr.moveTo2(b.x + dx * e, b.y + dy * e);
		_vr.lineTo2(b.x - dx * e, b.y - dy * e);
	}
}