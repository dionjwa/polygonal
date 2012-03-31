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

import de.polygonal.motor.geom.intersect.IntersectAABB;
import de.polygonal.ui.trigger.surface.BoxSurface;
import de.polygonal.ui.trigger.Trigger;

class TestGeomIntersectAABB extends TestGeom
{
	var _viewBox1:Trigger;
	var _viewBox2:Trigger;
	
	override public function getName():String 
	{
		return "intersect AABB against AABB";
	}
	
	override function _init():Void
	{
		super._init();
		
		_viewBox1 = _createInteractiveBox(centerX - 100, centerY - 100, 200, 200);
		_viewBox2 = _createInteractiveBox(centerX - 180, centerY - 80, 100, 100);
		_viewBox1.appendChild(_viewBox2);
	}
	
	override function _tick(tick:Int):Void
	{
		var aabb1 = cast(_viewBox1.surface, BoxSurface).getBound();
		var aabb2 = cast(_viewBox2.surface, BoxSurface).getBound();
		
		_bIntersect = IntersectAABB.test2(aabb1, aabb2);
	}
	
	override function _draw(alpha:Float):Void
	{
		var aabb = cast(_viewBox1.surface, BoxSurface).getBound();
		_vr.aabb(aabb);
		
		var aabb = cast(_viewBox2.surface, BoxSurface).getBound();
		_vr.aabb(aabb);
	}
}