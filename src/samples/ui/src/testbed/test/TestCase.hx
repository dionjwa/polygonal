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
import de.polygonal.core.time.Timebase;
import de.polygonal.core.time.TimebaseEvent;
import de.polygonal.ds.ArrayedQueue;
import de.polygonal.flash.DisplayListUtils;
import de.polygonal.gl.text.fonts.rondaseven.PFRondaSeven;
import de.polygonal.gl.text.VectorFont;
import de.polygonal.gl.VectorRenderer;
import de.polygonal.gl.Window;
import de.polygonal.ui.trigger.TriggerEvent;
import de.polygonal.ui.UI;
import de.polygonal.ui.UIEvent;
import flash.display.Shape;
import flash.events.Event;
import testbed.display.TreeRenderer;
import testbed.test.Menu;

class TestCase extends Shape, implements IObserver
{
	static var _vectorRenderer:VectorRenderer;
	public static function getVectorRenderer():VectorRenderer
	{
		if (_vectorRenderer == null)
			_vectorRenderer = new VectorRenderer(1024, 1024);
		return _vectorRenderer;
	}
	
	public static var sActiveFlags = 0;
	
	static var _font:VectorFont;
	public static function getFont():VectorFont
	{
		if (_font == null)
		{
			_font = new PFRondaSeven();
			_font.setRenderer(getVectorRenderer());
		}
		return _font;
	}
	
	static var _fontEventLog:VectorFont;
	
	var _vr:VectorRenderer;
	var _eventLog:ArrayedQueue<String>;
	var _menu:Menu;
	var _renderer:TreeRenderer;
	var _bits:Int;
	
	function new()
	{
		super();
		
		_vr = TestCase.getVectorRenderer();
		Timebase.sAttach(this, TimebaseEvent.RENDER);
		UI.sAttach(this, UIEvent.KEY_DOWN);
		
		if (_fontEventLog == null)
		{
			_fontEventLog = TestCase.getFont();
			_fontEventLog.tabSize = 20;
		}
		_fontEventLog.setRenderer(_vr);
		
		_eventLog = new ArrayedQueue<String>(16);
		_renderer = new TreeRenderer();
		
		addEventListener(Event.REMOVED_FROM_STAGE, _onRemovedFromStage);
		
		//remember flags from previous test
		_bits = _getFlagsHook() | sActiveFlags;
		
		_initMenu();
		
		_initHook();
	}
	
	public var centerX(_centerXGetter, never):Float;
	inline function _centerXGetter():Float { return Window.bound().centerX; }
	
	public var centerY(_centerYGetter, never):Float;
	inline function _centerYGetter():Float { return Window.bound().centerY; }
	
	public function getName():String
	{
		return "?";
	}
	
	public function update(type:Int, source:IObservable, userData:Dynamic):Void
	{
		if (TriggerEvent.has(type))
		{
			//build event log
			if (_eventLog.size() == 16) _eventLog.dequeue();
			if (userData != null)
				_eventLog.enqueue(Sprintf.format("%s (%s)", [TriggerEvent.getName(type), userData]));
			else
				_eventLog.enqueue(TriggerEvent.getName(type)[0]);
		}
		else
		if (type == TimebaseEvent.RENDER)
		{
			//dump event log
			_vr.setFillColor(0xffffff, .25);
			_vr.fillStart();
			
			if (!_eventLog.isEmpty())
				_fontEventLog.write("trigger events", Window.bound().maxX - 200, Window.bound().minY + 20);
			
			for (i in 0..._eventLog.size())
			{
				var s = _eventLog.get(i);
				_fontEventLog.write(s, Window.bound().maxX - 200, Window.bound().minY + 30 + i * 10);
			}
			_vr.fillEnd();
			
			//render scene
			_renderHook();
			
			//draw on screen
			_vr.flush(graphics);
		}
		else
		if (type == UIEvent.KEY_DOWN)
		{
			_keyHook(userData);
		}
	}
	
	public function free():Void
	{
		//remember active flags
		sActiveFlags = _bits;
		
		_freeHook();
		
		_menu.free();
		_vr.flush(null);
		DisplayListUtils.detach(_menu);
		UI.sDetach(this);
		Timebase.sDetach(this);
	}
	
	function _keyHook(keyCode:Int)
	{
	}
	
	function _initHook()
	{
	}
	
	function _freeHook()
	{
	}
	
	function _renderHook()
	{
	}
	
	function _getMenuEntriesHook():Array<MenuEntry>
	{
		throw "override for implementation";
		return null;
	}
	
	function _getFlagsHook()
	{
		return sActiveFlags;
	}
	
	function _initMenu()
	{
		var entries = _getMenuEntriesHook();
		entries.push(new MenuEntry("left/right: prev/next test"));
		
		_menu = new Menu(entries, _vr, TestCase.getFont());
		_menu.x = 4;
		_menu.y = 20;
		Window.surface.addChild(_menu);
	}
	
	function _onRemovedFromStage(e:Event)
	{
		removeEventListener(Event.REMOVED_FROM_STAGE, _onRemovedFromStage);
		free();
	}
}