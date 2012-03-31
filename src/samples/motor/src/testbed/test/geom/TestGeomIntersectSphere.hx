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
package testbed.test.geom;

import de.polygonal.motor.geom.intersect.IntersectSphere;
import de.polygonal.ui.trigger.surface.CircleSurface;
import de.polygonal.ui.trigger.Trigger;

class TestGeomIntersectSphere extends TestGeom
{
	var _viewCircle1:Trigger;
	var _viewCircle2:Trigger;
	
	override public function getName():String 
	{
		return "intersect sphere against sphere";
	}
	
	override function _init():Void
	{
		super._init();
		
		_viewCircle1 = _createInteractiveCircle(centerX, centerY, 80);
		_viewCircle2 = _createInteractiveCircle(centerX - 100, centerY - 30, 50);
		_viewCircle1.appendChild(_viewCircle2);
	}
	
	override function _tick(tick:Int):Void
	{
		var sphere1 = cast(_viewCircle1.surface, CircleSurface).getShape();
		var sphere2 = cast(_viewCircle2.surface, CircleSurface).getShape();
		
		_bIntersect = IntersectSphere.test2(sphere1, sphere2);
	}
	
	override function _draw(alpha:Float):Void
	{
		var circle = cast(_viewCircle1.surface, CircleSurface).getShape();
		_vr.circle(circle);
		
		var circle = cast(_viewCircle2.surface, CircleSurface).getShape();
		_vr.circle(circle);
	}
}