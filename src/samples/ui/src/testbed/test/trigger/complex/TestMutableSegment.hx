
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

import de.polygonal.ui.trigger.behavior.MutableSegment;
import de.polygonal.ui.trigger.pointer.MousePointer;
import de.polygonal.ui.trigger.surface.constraint.DistanceConstraint;
import de.polygonal.ui.trigger.Trigger;
import flash.ui.Keyboard;
import testbed.display.TreeRenderer;
import testbed.test.trigger.TestTrigger;
import testbed.test.Menu;

class TestMutableSegment extends TestTrigger
{
	static var sExtent    = 100;
	static var sMinLength = 50;
	static var sMaxLength = 300;
	
	var _drawInternals:Bool;
	var _mutableSegment:MutableSegment;
	
	override public function free():Void
	{
		_mutableSegment.free();
		super.free();
	}
	
	override function _getMenuEntriesHook():Array<MenuEntry>
	{
		return
		[
			new MenuEntry("F2\tdraw internals", Keyboard.F2, _onDrawInternals),
			new MenuEntry("...drag segment and endpoints!")
		];
	}
	
	override public function getName():String 
	{
		return "draggable & resizable segment";
	}
	
	override function _createTriggerHook()
	{
		var extent = 100;
		var minLength = 50;
		var maxLength = 200;
		
		_mutableSegment = new MutableSegment(centerX - extent, centerY - extent, centerX + extent, centerY + extent, 10, MousePointer.instance());
		_mutableSegment.minLength = minLength;
		_mutableSegment.maxLength = maxLength;
		
		return _mutableSegment.getTrigger();
	}
	
	override function _renderHook() 
	{
		if (_drawInternals)
		{
			_treeRenderer.render(_trigger, _vr,
			TreeRenderer.DRAW_SURFACE_BOUND |
			TreeRenderer.DRAW_TRIGGER_BOUND);
			
			var vert1:Trigger = _mutableSegment.getTrigger().getNode().children.val;
			var vert2:Trigger = _mutableSegment.getTrigger().getNode().children.next.val;
			
			var c:DistanceConstraint = cast vert1.surface.getConstraint("vert1");
			_vr.setLineStyle(0x00FFFF, .25);
			_vr.circle2(vert1.surface.getCenter(), c.minDistance);
			_vr.circle2(vert1.surface.getCenter(), c.maxDistance);
			
			var c:DistanceConstraint = cast vert2.surface.getConstraint("vert2");
			_vr.setLineStyle(0x00FFFF, .25);
			_vr.circle2(vert2.surface.getCenter(), c.minDistance);
			_vr.circle2(vert2.surface.getCenter(), c.maxDistance);
			
			_vr.setLineStyle(0xffffff);
			_vr.line2(_mutableSegment.getSegment().a, _mutableSegment.getSegment().b);
		}
		else
		{
			super._renderHook();
			
			_vr.setLineStyle(0xffffff);
			_vr.line2(_mutableSegment.getSegment().a, _mutableSegment.getSegment().b);
		}
	}
	
	function _onDrawInternals(active:Bool):Void 
	{
		trace( "TestMutableSegment._onDrawInternals > active : " + active );
		_drawInternals = active;
	}
}