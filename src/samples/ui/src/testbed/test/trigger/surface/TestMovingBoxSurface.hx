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

import de.polygonal.core.math.Vec2;
import de.polygonal.ui.trigger.surface.BoxSurface;
import de.polygonal.ui.trigger.Trigger;
import testbed.test.trigger.TestTrigger;

using de.polygonal.gl.color.ARGB;

class TestMovingBoxSurface extends TestTrigger
{
	override public function getName():String 
	{
		return "simple box surface";
	}
	
	override function _getFlags()
	{
		return super._getFlags() | TestTrigger.DRAW_SURFACE_BOUND | TestTrigger.DRAW_SURFACE_CENTER | TestTrigger.DRAG_ENABLED;
	}
	
	override function _createTriggerHook()
	{
		var size = 40;
		
		var surface = new BoxSurface(centerX - size / 2, centerY - size / 2, size, size);
		var trigger = new Trigger(surface);
		
		var displacement = new Vec2(100, 100);
		
		var surface = new BoxSurface(centerX - size / 2 + displacement.x, centerY - size / 2 + displacement.y, size, size);
		var child = new Trigger(pointer, surface);
		trigger.appendChild(child);
		
		return trigger;
	}
	
	override function _renderHook()
	{
		super._renderHook();
		
		_vr.setLineStyle(0xffffff, 1);
		
		var a = _trigger.surface.getBound();
		var b = _trigger.getNode().getFirstChild().val.getBound();
		
		_vr.arrowLine5(a.centerX, a.centerY, b.centerX, b.centerY, 4);
	}
}