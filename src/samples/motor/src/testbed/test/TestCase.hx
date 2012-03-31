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
package testbed.test;

import de.polygonal.core.event.IObservable;
import de.polygonal.core.event.IObserver;
import de.polygonal.core.math.Mathematics;
import de.polygonal.core.math.random.ParkMiller;
import de.polygonal.core.math.Vec2Util;
import de.polygonal.core.time.Timebase;
import de.polygonal.core.time.TimebaseEvent;
import de.polygonal.ds.Bits;
import de.polygonal.ds.HashKey;
import de.polygonal.flash.DisplayListUtils;
import de.polygonal.gl.text.fonts.rondaseven.PFRondaSeven;
import de.polygonal.gl.text.VectorFont;
import de.polygonal.gl.VectorRenderer;
import de.polygonal.gl.Window;
import de.polygonal.core.math.Vec2;
import de.polygonal.motor.geom.primitive.AABB2;
import de.polygonal.ui.Key;
import de.polygonal.ui.UI;
import de.polygonal.ui.UIEvent;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;

import testbed.display.Camera;

using de.polygonal.ds.Bits;
using de.polygonal.ds.BitFlags;

class TestCase extends Sprite, implements IObserver
{
	static var _vectorRenderer:VectorRenderer;
	public static function getVectorRenderer():VectorRenderer
	{
		if (_vectorRenderer == null)
			_vectorRenderer = new VectorRenderer(1024, 1024);
		return _vectorRenderer;
	}
	
	static var _font:VectorFont;
	public static function getFont():VectorFont
	{
		if (_font == null)
		{
			_font = new PFRondaSeven();
			_font.setRenderer(getVectorRenderer());
		}
		return _font;
	}
	
	inline static var DO_ZOOM = Bits.BIT_28;
	inline static var DO_PAN  = Bits.BIT_29;
	
	var _bits:Int;
	
	var _vr:VectorRenderer;
	var _menu:Menu;
	var _camera:Camera;
	var _canvas:Shape;
	var _worldMouse:Vec2;
	var _snap:Float;
	var _t0:Vec2;
	var _t1:Vec2;
	var _tmpAABB:AABB2;
	var _tmpVec:Vec2;
	
	var _random:ParkMiller;
	
	public var key(default, null):Int;
	
	function new()
	{
		super();
		
		key = HashKey.next();
		
		_random = new ParkMiller();
		_vr = getVectorRenderer();
		addEventListener(Event.ADDED_TO_STAGE, _onAddedToStage);
	}
	
	public function getName():String
	{
		throw "override for implementation";
		return null;
	}
	
	public function update(type:Int, source:IObservable, userData:Dynamic):Void
	{
		switch (type)
		{
			case TimebaseEvent.TICK:
				if (hasf(DO_PAN) && UI.get.isKeyDown(Key.SPACE) && UI.get.isMouseDown)
				{
					_camera.x = _t0.x + (UI.instance().mouse.x - _t1.x);
					_camera.y = _t0.y + (UI.instance().mouse.y - _t1.y);
					_camera.x = Mathematics.fclamp(_camera.x, Window.bound().centerX - _camera.scale(10), Window.bound().centerX + _camera.scale(10));
					_camera.y = Mathematics.fclamp(_camera.y, Window.bound().centerY - _camera.scale(10), Window.bound().centerY + _camera.scale(10));
				}
				_tickInternal(userData);
			
			case TimebaseEvent.RENDER:
				_drawInternal(userData);
				_vr.flush(_canvas.graphics);
			
			case UIEvent.KEY_DOWN:
				if (hasf(DO_PAN) && userData == Key.SPACE)
				{
					_t0.x = _camera.x;
					_t0.y = _camera.y;
					_t1.x = UI.instance().mouse.x;
					_t1.y = UI.instance().mouse.y;
				}
				_onKeyDown(userData);
			
			case UIEvent.KEY_UP:
				_onKeyUp(userData);
			
			case UIEvent.MOUSE_DOWN:
				if (hasf(DO_PAN) && UI.get.isKeyDown(Key.SPACE))
				{
					_t0.x = _camera.x;
					_t0.y = _camera.y;
					_t1.x = UI.instance().mouse.x;
					_t1.y = UI.instance().mouse.y;
				}
				_onMouseDown(userData);
			
			case UIEvent.MOUSE_UP:
				_onMouseUp(userData);
			
			case UIEvent.MOUSE_WHEEL:
				if (hasf(DO_ZOOM) && UI.get.isKeyDown(Key.SPACE))
				{
					_camera.zoom += 5. * Mathematics.sgn(userData);
					_camera.zoom = Mathematics.fclamp(_camera.zoom, 5, 200);
					_camera.x = Mathematics.fclamp(_camera.x, Window.bound().centerX - _camera.scale(10), Window.bound().centerX + _camera.scale(10));
					_camera.y = Mathematics.fclamp(_camera.y, Window.bound().centerY - _camera.scale(10), Window.bound().centerY + _camera.scale(10));
				}
				else
					_onMouseWheel(userData);
		}
	}
	
	function _init():Void
	{
		throw "override for implementation";
	}
	
	function _free():Void
	{
		Timebase.sDetach(this);
		UI.sDetach(this);
		DisplayListUtils.detachChildren(this);
		
		_vr.flush(null);
		_vr   = null;
		_menu = null;
	}
	
	function _tickInternal(tick:Int):Void {}
	function _drawInternal(alpha:Float):Void {}
	function _onKeyDown(keyCode:Int):Void {}
	function _onKeyUp(keyCode:Int):Void {}
	function _onMouseDown(mouse:Vec2):Void {}
	function _onMouseUp(mouse:Vec2):Void {}
	function _onMouseWheel(delta:Int):Void {}
	
	function _onAddedToStage(e:Event):Void
	{
		removeEventListener(Event.ADDED_TO_STAGE, _onAddedToStage);
		addEventListener(Event.REMOVED_FROM_STAGE, _onRemovedFromStage);
		
		Timebase.instance().setTickRate(60);
		
		_camera = new Camera(Window.bound().centerX, Window.bound().centerY, 50);
		
		addChild(_canvas = new Shape());
		
		_worldMouse = new Vec2();
		_tmpAABB    = new AABB2();
		_tmpVec     = new Vec2();
		_t0         = new Vec2();
		_t1         = new Vec2();
		_snap       = 0.;
		_bits       = 0;
		
		Timebase.sAttach(this, TimebaseEvent.TICK | TimebaseEvent.RENDER);
		UI.sAttach(this, UIEvent.KEY_DOWN | UIEvent.KEY_UP | UIEvent.MOUSE_WHEEL | UIEvent.MOUSE_DOWN | UIEvent.MOUSE_UP);
		
		_init();
	}
	
	function _onRemovedFromStage(e:Event):Void
	{
		removeEventListener(Event.REMOVED_FROM_STAGE, _onRemovedFromStage);
		_free();
	}
	
	function _getWorldBound():AABB2
	{
		_tmpAABB.set4(-15, -15, 15, 15);
		return _tmpAABB;
	}
	
	function _getRandomScreenVector(stagePadding:Float):Vec2
	{
		return Vec2Util.random
		(
			stagePadding, Window.bound().intervalX - stagePadding,
			stagePadding, Window.bound().intervalY - stagePadding
		);
	}
	
	function _getDistancePointMouse(p:Vec2):Float
	{
		var dx = UI.instance().mouse.x - p.x;
		var dy = UI.instance().mouse.y - p.y;
		return Math.sqrt(dx * dx + dy * dy);
	}
	
	function _getWorldMouse():Vec2
	{
		var p = UI.instance().mouse;
		_camera.toWorld(p, _worldMouse);
		
		if (_snap != 0)
		{
			_worldMouse.x = Mathematics.roundTo(_worldMouse.x, _snap);
			_worldMouse.y = Mathematics.roundTo(_worldMouse.y, _snap);
		}
		
		return _worldMouse;
	}
	
	function _getRandomFloat(min:Float, max:Float):Float
	{
		return Mathematics.lerp(min , max, _random.randomFloat());
	}
	
	function _initMenu(menuEntries:Array<String>, ?activeEntries = 0):Void
	{
		_menu = new Menu(menuEntries, _vr);
		_menu.x = 1;
		
		if (Window.stage.getChildByName("SysMon") != null)
			_menu.y = 100;
		else
			_menu.y = TestCase.getFont().size - 1;
		
		addChild(_menu);
		
		if (activeEntries != 0)
		{
			for (i in 0...32 - 5)
			{
				if (activeEntries.hasBitAt(i))
				{
					_menu.toggleMenuEntry(i + 1); //0=help
				}
			}
		}
	}
	
	function _drawGrid():Void
	{
		_vr.setLineStyle(0xffffff, 0.02, 0);
		
		var maxX = Window.bound().intervalX;
		var maxY = Window.bound().intervalY;
		var spacing;
		
		spacing = _camera.scale(.5);
		_vr.grid6(spacing, _camera.x % spacing, _camera.y % spacing, maxX, maxY, false);
	}
	
	function _drawViewCenter():Void
	{
		_vr.setLineStyle(0xffffff, .1, 0);
		_vr.crossHair3(_camera.x, _camera.y, _camera.scale(3));
	}
	
	function _annotate(p:Vec2, text:String)
	{
		_vr.clearStroke();
		
		if (text != null)
		{
			var b = new AABB2();
			_font.getBound(text, p.x, p.y + 10, true, true, b);
			_vr.setFillColor(0);
			_vr.fillStart();
			
			b.minX = Std.int(b.minX);
			b.minY = Std.int(b.minY);
			b.maxX = Std.int(b.maxX);
			b.maxY = Std.int(b.maxY);
			
			b.inflate2(2, 2);
			
			_vr.aabb(b);
			_vr.fillEnd();
			
			_vr.setFillColor(0xffffff, 1);
			_vr.fillStart();
			
			_font.write(text, b.minX + 2, b.maxY - 2, false);
			_vr.fillEnd(); 
		}
	}
	
	function _drawMarker(x:Vec2, ?label = "", ?clr = 0xFFFF00, ?labelOffset:Vec2)
	{
		_vr.clearStroke();
		_vr.setFillColor(clr, 1);
		
		_vr.fillStart();
		_vr.box2(x, 4);
		_vr.fillEnd();
		
		if (label != "")
		{
			_vr.clearStroke();
			
			var a = _font.getBound(label, x.x, x.y + 10, true, true, new AABB2());
			
			if (labelOffset != null)
			{
				a.centerX += labelOffset.x;
				a.centerY += labelOffset.y;
			}
			
			_vr.setFillColor(0);
			_vr.fillStart();
			
			a.minX = Std.int(a.minX);
			a.minY = Std.int(a.minY);
			a.maxX = Std.int(a.maxX);
			a.maxY = Std.int(a.maxY);
			a.inflate2(2, 2);
			
			_vr.aabb(a);
			_vr.fillEnd();
			
			_vr.setFillColor(0xffffff, 1);
			_vr.fillStart();
			
			_font.write(label, a.minX + 2, a.maxY - 2, false);
			_vr.fillEnd();
		}
	}
}

private class Menu extends Sprite
{
	static var isVisible = false;
	
	inline static var MIN_ALPHA = .5;
	inline static var MAX_ALPHA = 1.;
	
	var _entries:Array<String>;
	var _alphaBits:Int;
	var _visible:Bool;
	
	public function new(entries:Array<String>, vr:VectorRenderer)
	{
		super();
		
		_entries = entries;
		
		var tabSize = TestCase.getFont().tabSize;
		TestCase.getFont().tabSize = 10;
		
		vr.clearStroke();
		vr.setFillColor(0xffffff, 1);
		
		for (i in 0...entries.length)
		{
			var shape = new Shape();
			shape.cacheAsBitmap = true;
			addChild(shape);
			shape.y = i * 12;
			shape.alpha = MIN_ALPHA;
			
			vr.fillStart();
			TestCase.getFont().write(entries[i], 0, 0);
			vr.fillEnd();
			vr.flush(shape.graphics);
		}
		
		TestCase.getFont().tabSize = tabSize;
		
		getChildAt(0).visible = true;
		getChildAt(0).alpha = MIN_ALPHA;
		for (i in 1..._entries.length)
		{
			var child = getChildAt(i);
			child.visible = false;
			child.alpha = MIN_ALPHA;
		}
		
		if (isVisible)
		{
			toggleMenu();
			isVisible = true;
		}
	}
	
	public function toggleMenu():Void
	{
		getChildAt(0).visible = true;
		toggleMenuEntry(0);
		
		for (i in 1..._entries.length)
		{
			var child = getChildAt(i);
			child.visible = !child.visible;
			child.alpha = _alphaBits.hasBitAt(i) ? MAX_ALPHA : MIN_ALPHA;
		}
		
		isVisible = !isVisible;
	}
	
	public function toggleMenuEntry(entryIndex:Int):Void
	{
		var pos = entryIndex;
		if (_alphaBits.hasBitAt(pos))
		{
			getChildAt(entryIndex).alpha = MIN_ALPHA;
			_alphaBits = _alphaBits.clrBitAt(pos);
		}
		else
		{
			getChildAt(entryIndex).alpha = MAX_ALPHA;
			_alphaBits = _alphaBits.setBitAt(pos);
		}
	}
}