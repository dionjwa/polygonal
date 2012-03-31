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

import de.polygonal.core.math.Mathematics;
import de.polygonal.gl.color.RainbowGradient;
import de.polygonal.ui.trigger.behavior.MutablePane;
import flash.ui.Keyboard;
import testbed.display.TreeRenderer;
import testbed.test.TestCase;
import testbed.test.Menu;

class TestMutablePane extends TestCase
{
	var _pane1:MutablePane;
	var _pane2:MutablePane;
	
	var _drawInternals:Bool;
	
	override public function free():Void
	{
		_pane1.free();
		_pane2.free();
		super.free();
	}
	
	override public function getName():String 
	{
		return "draggable + resizable pane";
	}
	
	override function _getMenuEntriesHook():Array<MenuEntry>
	{
		return
		[
			new MenuEntry("F2\tdraw internals", Keyboard.F2, _onDrawInternals),
			new MenuEntry("...drag face, edges and vertices!")
		];
	}
	
	override function _initHook():Void 
	{
		_pane1 = new MutablePane(100, 100, 100, 100);
		_pane1.userData = "1";
		
		_pane2 = new MutablePane(400, 200, 50, 90);
		_pane2.userData = "2";
		
		_pane1.trigger.appendChild(_pane2.trigger);
	}
	
	override function _renderHook():Void 
	{
		_drawPane(_pane1, RainbowGradient.instance().getColor(2, 0, .6, .6).get24());
		_drawPane(_pane2, RainbowGradient.instance().getColor(2, 1, .6, .6).get24());
		
		if (_drawInternals)
		{
			_renderer.render(_pane1.trigger, _vr,
			TreeRenderer.DRAW_SURFACE_BOUND |
			TreeRenderer.DRAW_TRIGGER_BOUND);
			super._renderHook();
		}
	}
	
	function _drawPane(pane:MutablePane, color:Int)
	{
		if (_drawInternals) untyped
		{
			var bin = pane.bin;
			_vr.setLineStyle(0x00FFFF, 0.25, 0);
			if (bin._minInnerSize.x != Mathematics.NEGATIVE_INFINITY && bin._minInnerSize.y != Mathematics.NEGATIVE_INFINITY)
				_vr.aabbCenExt4(bin.centerX, bin.centerY, bin._minInnerSize.x / 2, bin._minInnerSize.y / 2);
			
			if (bin._maxInnerSize.x != Mathematics.POSITIVE_INFINITY && bin._maxInnerSize.y != Mathematics.POSITIVE_INFINITY)
				_vr.aabbCenExt4(bin.centerX, bin.centerY, bin._maxInnerSize.x / 2, bin._maxInnerSize.y / 2);
			
			_vr.setLineStyle(0x00FFFF, 1, 0);
			_vr.crossHair3(centerX, centerY, 4);
		}
		else
		{
			_vr.clearStroke();
			_vr.setFillColor(color, 1);
			_vr.fillStart();
			_vr.aabb(pane.bin.outerBound);
			_vr.fillEnd();
			var bin = pane.bin;
			//_vr.setLineStyle(0xFFFFFF, 1, 0);
			//_vr.aabb(bin.innerBound);
			//_vr.aabb(bin.outerBound);
		}
	}
	
	function _onDrawInternals(active:Bool):Void 
	{
		_drawInternals = active;
	}
}