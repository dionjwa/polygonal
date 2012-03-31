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
package testbed.test.trigger.hierarchy;

import de.polygonal.ui.trigger.pointer.MousePointer;
import de.polygonal.ui.trigger.surface.BoxSurface;
import de.polygonal.ui.trigger.Trigger;
import flash.ui.Keyboard;
import testbed.display.TreeRenderer;
import testbed.test.trigger.TestTrigger;
import testbed.test.Menu;

using de.polygonal.ds.BitFlags;

class TestSmallTree extends TestTrigger
{
	override public function getName():String 
	{
		return "simple trigger hierarchy";
	}
	
	override function _getMenuEntriesHook()
	{
		return
		[
			new MenuEntry("F2\tenable dragging"    , Keyboard.F2, _onToggleDragging         , hasf(TestTrigger.DRAG_ENABLED)),
			new MenuEntry("F3\tdrag lock to center", Keyboard.F3, _onToggleDragLockCenter   , hasf(TestTrigger.DRAG_LOCK_CENTER)),
			new MenuEntry("F4\tenable touch mode"  , Keyboard.F4, _onToggleTouchMode        , hasf(TestTrigger.TOUCH_MODE)),
			new MenuEntry("F7\tdraw pointer"       , Keyboard.F7, _onToggleDrawPointer      , hasf(TestTrigger.DRAW_POINTER))
		];
	}
	
	override function _createTriggerHook()
	{
		//build tree
		var ta  = _createBoxTrigger(245, 260-150, 200, 200, "A0");
		var tb1 = _createBoxTrigger(200, 300-150, 100, 100, "B1");
		var tb2 = _createBoxTrigger(280, 320-150, 100, 100, "B2");
		var tb3 = _createBoxTrigger(360, 340-150, 100, 100, "B3");
		var tc  = _createBoxTrigger(205, 390-150,  50,  50, "C");
		var td  = _createBoxTrigger(285, 415-150,  50,  50, "D");
		var te  = _createBoxTrigger(365, 436-150,  50,  50, "E");
		
		tb1.appendChild(tc);
		tb2.appendChild(td);
		tb3.appendChild(te);
		
		ta.appendChild(tb1);
		ta.appendChild(tb2);
		ta.appendChild(tb3);
		
		return ta;
	}
	
	override function _renderHook() 
	{
		_treeRenderer.render(_trigger, _vr,
			TreeRenderer.DRAW_SURFACE_BOUND |
			TreeRenderer.DRAW_TRIGGER_BOUND |
			TreeRenderer.DRAW_HIERARCHY |
			TreeRenderer.DRAW_USER_DATA);
		
		if (hasf(TestTrigger.DRAW_POINTER))
			_drawPointer();
	}
	
	function _createBoxTrigger(x:Float, y:Float, w:Float, h:Float, userData:Dynamic)
	{
		var surface            = new BoxSurface(x, y, w, h);
		var trigger            = new Trigger(surface);
		trigger.userData       = userData;
		trigger.dragEnabled    = hasf(TestTrigger.DRAG_ENABLED);
		trigger.dragLockCenter = hasf(TestTrigger.DRAG_LOCK_CENTER);
		trigger.touchMode      = hasf(TestTrigger.TOUCH_MODE);
		trigger.attach(this);
		return trigger;
	}
}