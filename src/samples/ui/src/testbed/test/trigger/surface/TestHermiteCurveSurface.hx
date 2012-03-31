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
import de.polygonal.ui.trigger.surface.HermiteCurveSurface;
import de.polygonal.ui.trigger.surface.LineSurface;
import de.polygonal.ui.trigger.Trigger;

class TestHermiteCurveSurface extends TestTrigger
{
	 //An array of point coordinates.  The first point's x        
    //coordinate is at index [0] and its y coordinate at index [1], followed */
    //by the coordinates of the remaining points.  Each point occupies two   */
	override public function getName():String 
	{
		return "hermite curve surface";
	}
	
	override function _createTriggerHook() 
	{
		var extent = 50;
		var a = new Vec2(centerX - 150, centerY + 50);
		var b = new Vec2(1, 0);
		var c = new Vec2(1, 0);
		var d = new Vec2(centerX + 150, centerY - 100);
		
		var surface = new HermiteCurveSurface(a, b, c, d, 20, 10);
		var trigger = new Trigger(pointer, surface);
		trigger.attach(this);
		return trigger;
	}
	
	override function _renderHook()
	{
		super._renderHook();
		
		//draw surface shape
		_vr.setLineStyle(0xffffff, 1, 0);
		var surface = cast(_trigger.surface, HermiteCurveSurface);
		_vr.polyLineScalar(surface.vertexList.getArray());
	}
}