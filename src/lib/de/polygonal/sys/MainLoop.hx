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
package de.polygonal.sys;

import de.polygonal.core.event.IObservable;
import de.polygonal.core.time.Timebase;
import de.polygonal.core.time.TimebaseEvent;
import de.polygonal.core.time.Timeline;
import de.polygonal.gl.Window;
import de.polygonal.gl.WindowEvent;

import de.polygonal.core.event.Observable.ObserverNode;

class MainLoop extends Entity
{
	var _timebase:Timebase;
	var _timeline:Timeline;
	
	var _paused:Bool;
	
	public function new()
	{
		super();
		
		_timebase = Timebase.instance();
		_timebase.attach(this);
		_timeline = Timeline.instance();
		
		#if debug
		de.polygonal.ui.UI.get.attach(this, de.polygonal.ui.UIEvent.KEY_DOWN);
		#end
		
		Window.getObservable().attach(this);
	}
	
	public function pause():Void
	{
		_timebase.halt();
		_paused = true;
	}
	
	public function resume():Void
	{
		_timebase.resume();
		_paused = false;
	}
	
	override public function update(type:Int, source:IObservable, userData:Dynamic):Void
	{
		switch (type)
		{
			case WindowEvent.ACTIVATE:
				resume();
				
			case WindowEvent.DEACTIVATE:
				pause();
			
			case TimebaseEvent.TICK:
				_timeline.advance();
				
				#if (debug && !no_traces)
				//identify update step
				for (handler in de.polygonal.core.Root.log().getLogHandler())
					handler.setPrefix(de.polygonal.core.fmt.Sprintf.format("t%03d", [_timebase.getProcessedTicks() % 1000]));
				#end
				
				commit();
				advance(userData);
				
			case TimebaseEvent.RENDER:
				#if debug
				//identify rendering step
				for (handler in de.polygonal.core.Root.log().getLogHandler())
					handler.setPrefix(de.polygonal.core.fmt.Sprintf.format("r%03d", [_timebase.getProcessedFrames() % 1000]));
				#end
				
				render(userData);
				
			#if debug
			//pause game graph traversal; perform manual updates when pressing '`'
			case de.polygonal.ui.UIEvent.KEY_DOWN:
				#if flash
				if (de.polygonal.ui.UI.instance().currCharCode == de.polygonal.core.fmt.ASCII.TILDE)
				{
					if (_paused)
					{
						_propagateAdvance(_timebase.getGameTimeDelta(), this);
						_propagateRender(1, this);
					}
				}
				if (de.polygonal.ui.UI.instance().currCharCode == de.polygonal.core.fmt.ASCII.GRAVE)
				{
					_paused ? resume() : pause();
				}
				#end
			#end
		}
	}
}