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
import de.polygonal.core.fmt.Sprintf;
import de.polygonal.core.fmt.StringUtil;
import de.polygonal.ds.HashKey;
import de.polygonal.gl.Window;
import de.polygonal.ui.Key;
import de.polygonal.ui.UI;
import de.polygonal.ui.UIEvent;
import flash.display.Sprite;

class TestRunner extends Sprite, implements IObserver
{
	public var key(default, null):Int;
	
	var _tests:Array<Class<Dynamic>>;
	var _index:Int;
	var _test:TestCase;
	
	public function new():Void
	{
		super();
		
		key = HashKey.next();
		
		_tests = new Array<Class<TestCase>>();
		_index = -1;
	}
	
	public function add(x:Class<Dynamic>):Void
	{
		_tests.push(x);
	}
	
	public function run():Void
	{
		_next();
		UI.sAttach(this, UIEvent.KEY_DOWN);
	}
	
	public function update(type:Int, source:IObservable, userData:Dynamic):Void
	{
		if (type == UIEvent.KEY_DOWN)
		{
			switch (userData)
			{
				case Key.RIGHT:
					_next();
				
				case Key.LEFT:
					_prev();
				
				case Key.BACKSPACE:
					_reset();
			}
		}
	}
	
	function _reset():Void
	{
		_index--;
		_next();
	}
	
	function _next():Void
	{
		#if debug
		de.polygonal.core.macro.Assert.assert(_tests.length > 0, "_tests.length > 0");
		#end
		
		_index++;
		if (_index == _tests.length) _index = 0;
		
		if (_test != null) removeChild(_test);
		
		_test = Type.createInstance(_tests[_index], []);
		
		#if debug
		de.polygonal.core.macro.Assert.assert(Std.is(_test, TestCase), "Std.is(_test, TestCase)");
		#end
		
		addChild(_test);
		
		_drawTestName(_test);
	}
	
	function _prev():Void
	{
		_index--;
		if (_index < 0) _index = _tests.length - 1;
		
		if (_test != null)
			removeChild(_test);
		
		_test = Type.createInstance(_tests[_index], []);
		
		#if debug
		de.polygonal.core.macro.Assert.assert(Std.is(_test, TestCase), "Std.is(_test, TestCase)");
		#end
		
		addChild(_test);
		
		_drawTestName(_test);
	}
	
	function _drawTestName(test:TestCase):Void
	{
		var vr = TestCase.getVectorRenderer();
		vr.setFillColor(0xffffff, 1);
		vr.fillStart();
		
		var font = TestCase.getFont();
		font.write(Sprintf.format("%s [%02d/%02d]\n%s", [test.getName(), _index + 1, _tests.length, StringUtil.getUnqualifiedClassName(test)]), 1, Window.bound().intervalY - font.size * 2);
		
		vr.fillEnd(); 
		vr.flush(graphics);
	}
}