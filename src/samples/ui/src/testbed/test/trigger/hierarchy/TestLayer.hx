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
import de.polygonal.ui.trigger.TriggerLayerManager;
import testbed.display.TreeRenderer;
import testbed.test.trigger.TestTrigger;

using de.polygonal.ds.BitFlags;

class TestLayer extends TestTrigger
{
	var _trigger1:Trigger;
	var _trigger2:Trigger;
	var _trigger3:Trigger;
	
	override public function getName():String 
	{
		return "simple trigger hierarchy";
	}
	
	override function _createTriggerHook()
	{
		_trigger1 = _createBoxTrigger(200, 250, 100, 100, "layer 1");
		TriggerLayerManager.append(_trigger1, 1);
		
		_trigger2 = _createBoxTrigger(300, 150, 100, 100, "layer 4");
		TriggerLayerManager.append(_trigger2, 4);
		
		_trigger3 = _createBoxTrigger(250, 200, 100, 100, "layer 2");
		TriggerLayerManager.append(_trigger3, 2);
		
		return untyped TriggerLayerManager._root;
	}
	
	override function _freeHook() 
	{
		_trigger1.free();
		_trigger2.free();
		_trigger3.free();
	}
	
	override function _renderHook() 
	{
		super._renderHook();
		
		_treeRenderer.render(untyped TriggerLayerManager._root, _vr,
			TreeRenderer.DRAW_SURFACE_BOUND |
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