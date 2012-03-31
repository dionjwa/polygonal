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
package testbed.test.trigger.constraint;

import de.polygonal.motor.geom.primitive.AABB2;
import de.polygonal.ui.trigger.surface.BoxSurface;
import de.polygonal.ui.trigger.surface.constraint.AABBConstraint;
import de.polygonal.ui.trigger.Trigger;
import testbed.test.trigger.TestTrigger;

using de.polygonal.ds.BitFlags;

class TestAABBConstraint extends TestTrigger
{
	var _constraint:AABBConstraint;
	
	override public function getName():String 
	{
		return "simple box surface + aabb constraint";
	}
	
	override function _getFlagsHook()
	{
		return TestTrigger.DRAG_ENABLED | TestTrigger.DRAW_SURFACE_BOUND | TestTrigger.DRAW_SURFACE_CENTER;
	}
	
	override function _createTriggerHook()
	{
		var size = 40;
		
		var surface = new BoxSurface(centerX - size / 2, centerY - size / 2, size, size);
		
		_constraint = new AABBConstraint(new AABB2(centerX - 100, centerY - 100, centerX + 100, centerY + 100));
		surface.registerConstraint(_constraint);
		
		var trigger = new Trigger(surface);
		trigger.userData = "box";
		trigger.dragEnabled = true;
		trigger.dragLockCenter = hasf(TestTrigger.DRAG_LOCK_CENTER);
		trigger.touchMode = hasf(TestTrigger.TOUCH_MODE);
		trigger.attach(this);
		return trigger;
	}
	
	override function _renderHook()
	{
		//draw constraint
		_vr.setLineStyle(0x408080);
		_vr.aabb(_constraint.bound);
		
		super._renderHook();
	}
}