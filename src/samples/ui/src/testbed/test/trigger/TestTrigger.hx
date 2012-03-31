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
package testbed.test.trigger;

import de.polygonal.ds.Bits;
import de.polygonal.ui.trigger.pointer.MousePointer;
import de.polygonal.ui.trigger.Trigger;
import flash.ui.Keyboard;
import testbed.display.TreeRenderer;
import testbed.test.TestCase;
import testbed.test.Menu;

using de.polygonal.gl.color.ARGB;
using de.polygonal.ds.BitFlags;

class TestTrigger extends TestCase
{
	inline public static var DRAG_ENABLED         = Bits.BIT_01;
	inline public static var DRAG_LOCK_CENTER     = Bits.BIT_02;
	inline public static var TOUCH_MODE           = Bits.BIT_03;
	inline public static var DRAW_SURFACE_BOUND   = Bits.BIT_04;
	inline public static var DRAW_SURFACE_CENTER  = Bits.BIT_05;
	inline public static var DRAW_POINTER         = Bits.BIT_06;
	
	/* root trigger */
	var _trigger:Trigger;
	
	var _treeRenderer:TreeRenderer;
	
	override function _getMenuEntriesHook()
	{
		return
		[
			new MenuEntry("F2\tenable dragging"    , Keyboard.F2, _onToggleDragging         , hasf(TestTrigger.DRAG_ENABLED)),
			new MenuEntry("F3\tdrag lock to center", Keyboard.F3, _onToggleDragLockCenter   , hasf(TestTrigger.DRAG_LOCK_CENTER)),
			new MenuEntry("F4\tenable touch mode"  , Keyboard.F4, _onToggleTouchMode        , hasf(TestTrigger.TOUCH_MODE)),
			new MenuEntry("F5\tdraw surface bound" , Keyboard.F5, _onToggleDrawSurfaceBound, hasf(TestTrigger.DRAW_SURFACE_BOUND)),
			new MenuEntry("F6\tdraw surface center", Keyboard.F6, _onToggleDrawSurfaceCenter, hasf(TestTrigger.DRAW_SURFACE_CENTER)),
			new MenuEntry("F7\tdraw pointer"       , Keyboard.F7, _onToggleDrawPointer      , hasf(TestTrigger.DRAW_POINTER))
		];
	}
	
	override function _getFlagsHook()
	{
		return DRAG_ENABLED;
	}
	
	override function _initHook()
	{
		_trigger = _createTriggerHook();
		_trigger.attach(this);
		
		for (t in _trigger)
		{
			if (hasf(DRAG_ENABLED))     t.dragEnabled = true;
			if (hasf(DRAG_LOCK_CENTER)) t.dragLockCenter = true;
			if (hasf(TOUCH_MODE))       t.touchMode = true;
		}
		
		_treeRenderer = new TreeRenderer();
		_treeRenderer.font = TestCase.getFont();
		TreeRenderer.setDefaultColors();
	}
	
	override function _freeHook() 
	{
		if (_trigger.surface != null)
			_trigger.surface.free();
		_trigger.free();
	}
	
	override function _renderHook()
	{
		if (hasf(DRAW_SURFACE_BOUND))
			_treeRenderer.render(_trigger, _vr, TreeRenderer.DRAW_SURFACE_BOUND);
		
		if (hasf(DRAW_SURFACE_CENTER))
			_treeRenderer.render(_trigger, _vr, TreeRenderer.DRAW_SURFACE_CENTER);
		
		if (hasf(DRAW_POINTER))
			_drawPointer();
	}
	
	function _onToggleDragging(active:Bool)
	{
		invf(DRAG_ENABLED);
		for (trigger in _trigger)
			trigger.dragEnabled = hasf(DRAG_ENABLED);
	}
	
	function _onToggleDragLockCenter(active:Bool)
	{
		invf(DRAG_LOCK_CENTER);
		for (trigger in _trigger)
			trigger.dragLockCenter = hasf(DRAG_LOCK_CENTER);
	}
	
	function _onToggleTouchMode(active:Bool)
	{
		invf(TOUCH_MODE);
		for (trigger in _trigger)
			trigger.touchMode = hasf(TOUCH_MODE);
	}
	
	function _onToggleDrawSurfaceBound(active:Bool)
	{
		invf(DRAW_SURFACE_BOUND);
	}
	
	function _onToggleDrawSurfaceCenter(active:Bool)
	{
		invf(DRAW_SURFACE_CENTER);
	}
	
	function _onToggleDrawPointer(active:Bool)
	{
		invf(DRAW_POINTER);
	}
	
	function _createTriggerHook()
	{
		throw "override for implementation";
		return null;
	}
	
	function _drawPointer()
	{
		if (hasf(DRAW_POINTER))
		{
			var pointer = MousePointer.instance();
			_vr.setLineStyle(0xffffff, .5);
			_vr.crossSkewed2(pointer.position(), 4);
		}
	}
}