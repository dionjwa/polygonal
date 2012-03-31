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
package testbed.test.trigger.complex;

import de.polygonal.core.event.IObservable;
import de.polygonal.core.fmt.Sprintf;
import de.polygonal.ui.alignment.Axis;
import de.polygonal.ui.trigger.pointer.MousePointer;
import de.polygonal.ui.trigger.surface.BoxSurface;
import de.polygonal.ui.trigger.surface.constraint.AxisConstraint;
import de.polygonal.ui.trigger.Trigger;
import de.polygonal.ui.trigger.TriggerEvent;
import testbed.test.TestCase;
import testbed.test.trigger.TestTrigger;
import testbed.test.Menu;

class TestSlider extends TestTrigger
{
	var _ratio:Float;
	
	override public function free():Void
	{
		super.free();
	}
	
	override public function getName():String 
	{
		return "a slider";
	}
	
	override function _getFlagsHook()
	{
		return TestTrigger.DRAG_ENABLED;
	}
	
	override function _getMenuEntriesHook():Array<MenuEntry>
	{
		return
		[
			new MenuEntry("...a lightweight slider")
		];
	}
	
	override function _createTriggerHook():Trigger
	{
		var sliderY    = centerY;
		var sliderMinX = centerX - 100;
		var sliderMaxX = centerX + 100;
		
		var surface = new BoxSurface(0, 0, 10, 10);
		var axisConstraint = new AxisConstraint(sliderY, sliderMinX, sliderMaxX, Axis.x);
		surface.registerConstraint(axisConstraint);
		
		var trigger = new Trigger(surface);
		trigger.attach(this, TriggerEvent.DRAG);
		
		_ratio = .0;
		
		return trigger;
	}
	
	override public function update(type:Int, source:IObservable, userData:Dynamic):Void
	{
		super.update(type, source, userData);
		
		if (type == TriggerEvent.DRAG)
			_computeRatio();
	}
	
	override function _renderHook():Void 
	{
		super._renderHook();
		
		_vr.clearStroke();
		_vr.setFillColor(0xffffff);
		_vr.fillStart();
		_vr.aabb(_trigger.surface.getBound());
		_vr.fillEnd();
		
		var font = TestCase.getFont();
		
		_vr.fillStart();
		font.write(Sprintf.format("%.2f", [_ratio]), centerX - 100, centerY + 20);
		_vr.fillEnd();
		
		_vr.setLineStyle(0xffffff);
		_vr.aabbMinMax4(centerX - 105, centerY - 5, centerX + 105, centerY + 5);
	}
	
	function _computeRatio()
	{
		var sliderMinX = centerX - 100;
		var sliderMaxX = centerX + 100;
		_ratio = (_trigger.surface.getCenter().x - sliderMinX) / (sliderMaxX - sliderMinX);
	}
}