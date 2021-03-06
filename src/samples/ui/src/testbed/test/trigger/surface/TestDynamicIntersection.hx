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
package testbed.test.trigger.surface;

import de.polygonal.ui.trigger.pointer.MousePointer;
import de.polygonal.ui.trigger.surface.BoxSurface;
import de.polygonal.ui.trigger.Trigger;
import testbed.display.TreeRenderer;
import testbed.test.trigger.TestTrigger;

using de.polygonal.gl.color.ARGB;
using de.polygonal.ds.BitFlags;

class TestDynamicIntersection extends TestTrigger
{
	override public function getName():String 
	{
		return "simple box surface";
	}
	
	override function _getFlags()
	{
		return super._getFlags() | TestTrigger.DYNAMIC_INTERSECTION | TestTrigger.DRAW_SURFACE_BOUND |TestTrigger.DRAW_POINTER;
	}
	
	override function _createTriggerHook()
	{
		var pointer = MousePointer.instance();
		
		var size = 40;
		var surface = new BoxSurface(centerX - size / 2, centerY - size * 4, size, size * 2);
		var trigger = new Trigger(pointer, surface);
		trigger.dynamicIntersection = true;
		
		_triggerList = new Array();
		var c = 40;
		var w = 6;
		var h = 100;
		var s = 3;
		var x = centerX - c / 2 * (w + s) - (w / 2);
		for (i in 0...c)
		{
			var surface = new BoxSurface(x, centerY - w / 2, w, h);
			var t = new Trigger(pointer, surface);
			t.dynamicIntersection = true;
			_triggerList.push(t);
			
			x += w + s;
		}
		
		return trigger;
	}
	
	override function _renderHook()
	{
		super._renderHook();
		
		for (trigger in _triggerList)
			_treeRenderer.render(trigger, _vr, TreeRenderer.DRAW_SURFACE_BOUND);
	}
}