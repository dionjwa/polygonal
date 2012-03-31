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
import de.polygonal.ds.DA;
import de.polygonal.flash.DisplayListUtils;
import de.polygonal.gl.text.VectorFont;
import de.polygonal.gl.VectorRenderer;
import de.polygonal.ui.UI;
import de.polygonal.ui.UIEvent;
import flash.display.Shape;
import flash.display.Sprite;
import flash.ui.Keyboard;

using de.polygonal.ds.Bits;

class MenuEntry
{
	public var name:String;
	public var code:Int;
	public var func:Bool->Void;
	public var active:Bool;
	
	public function new(name:String, ?code = -1, ?func:Bool->Void, active = false)
	{
		this.name   = name;
		this.code   = code;
		this.func   = func;
		this.active = active;
	}
}

class Menu extends Sprite, implements IObserver
{
	public static var sOpen = true;
	
	var _entryLookup:Hash<MenuEntry>;
	var _state:Hash<Bool>;
	var _menuEntry:MenuEntry;
	
	public function new(entries:Array<MenuEntry>, vr:VectorRenderer, font:VectorFont)
	{
		super();
		
		_entryLookup = new Hash();
		_state       = new Hash();
		
		//override tab size
		var tabSize = font.tabSize;
		font.tabSize = 10;
		
		vr.clearStroke();
		vr.setFillColor(0xffffff, 1);
		
		entries.unshift(_menuEntry = new MenuEntry("F1\tMenu", Keyboard.F1, _onToggleMenu, true));
		
		var i = 1;
		for (entry in entries)
		{
			var shape = _drawLabel(vr, font, entry.name);
			shape.name = entry.name;
			shape.y = i++ * 12;
			shape.alpha = .5;
			_entryLookup.set(entry.name, entry);
			_state.set(entry.name, entry.active);
		}
		
		//restore tab size
		font.tabSize = tabSize;
		
		if (sOpen)
			showMenu();
		else
			hideMenu();
		
		UI.sAttach(this, UIEvent.KEY_DOWN);
	}
	
	public function free():Void
	{
		UI.sDetach(this);
		DisplayListUtils.detachAll(this);
	}
	
	public function update(type:Int, source:IObservable, userData:Dynamic):Void 
	{
		for (entry in _entryLookup)
		{
			if (entry.code == userData)
			{
				toggleMenuEntry(entry.name);
				entry.func(_state.get(entry.name));
			}
		}
	}
	
	public function showMenu():Void
	{
		sOpen = false;
		toggleMenu();
	}
	
	public function hideMenu():Void
	{
		sOpen = true;
		toggleMenu();
	}
	
	public function toggleMenu():Void
	{
		sOpen = !sOpen;
		for (entry in _entryLookup)
		{
			var shape = getChildByName(entry.name);
			shape.visible = sOpen;
			if (_state.get(shape.name))
				shape.alpha = 1.;
			else
				shape.alpha = .5;
		}
		
		getChildByName(_menuEntry.name).visible = true;
		getChildByName(_menuEntry.name).alpha = sOpen ? 1. : .5;
	}
	
	public function enableMenuEntry(name:String):Void
	{
		_state.set(name, true);
		
		var entry = _entryLookup.get(name);
		var shape = getChildByName(entry.name);
		shape.alpha = 1;
	}
	
	public function disableMenuEntry(name:String):Void
	{
		_state.set(name, false);
		
		var entry = _entryLookup.get(name);
		var shape = getChildByName(entry.name);
		shape.alpha = .5;
	}
	
	public function toggleMenuEntry(name:String):Void
	{
		var entry = _entryLookup.get(name);
		var shape = getChildByName(entry.name);
		
		if (_state.get(name))
			disableMenuEntry(name);
		else
			enableMenuEntry(name);
	}
	
	function _onToggleMenu(active:Bool)
	{
		toggleMenu();
	}
	
	function _drawLabel(vr:VectorRenderer, font:VectorFont, label:String)
	{
		var shape = new Shape();
		shape.cacheAsBitmap = true;
		addChild(shape);
		
		vr.fillStart();
		font.write(label, 0, 0);
		vr.fillEnd();
		vr.flush(shape.graphics);
		
		return shape;
	}
}