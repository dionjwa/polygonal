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

import de.polygonal.core.Root;
import de.polygonal.gl.Window;
import de.polygonal.motor.geom.ddaa.DDAASegmentGrid;
import de.polygonal.motor.geom.ddaa.DDAAVisitor;
import de.polygonal.core.math.Vec2;
import de.polygonal.core.math.Vec2;
import de.polygonal.motor.geom.primitive.AABB2;
import de.polygonal.ui.trigger.behavior.MutableSegment;

class TestGeomDDAASegment extends TestGeom, implements DDAAVisitor
{
	var _viewSegment:MutableSegment;
	var _gridBound:AABB2;
	var _gridSize:Vec2;
	
	override public function getName():String 
	{
		return "DDAA segment traversal";
	}
	
	override function _init():Void
	{
		super._init();
		
		_viewSegment = _createInteractiveSegment(220, centerY, 400, centerY - 20, 20, 200);
		_gridBound = Window.bound().clone();
		_gridSize = new Vec2(25, 25);
	}
	
	override function _free():Void
	{
		_viewSegment.free();
		super._free();
	}
	
	override function _tick(tick:Int):Void
	{
		var segment = _viewSegment.getSegment();
	}
	
	override function _draw(alpha:Float):Void
	{
		_vr.setLineStyle(0xffffff, .25, 0);
		
		_vr.grid3(_gridSize.x, _gridBound, true);
		
		var segment = _viewSegment.getSegment();
		
		_vr.setFillColor(0xFFFF00, .5);
		_vr.fillStart();
		DDAASegmentGrid.shoot3(segment, _gridSize, this);
		_vr.fillEnd();
		
		_vr.setLineStyle(0xffffff, 1, 0);
		_drawSegment(_viewSegment.getSegment().a, _viewSegment.getSegment().b);
	}
	
	public function visit(x:Int, y:Int, i:Int, userData:Dynamic):Bool
	{
		_vr.aabbMinMax4
		(
			x * _gridSize.x,
			y * _gridSize.y, 
			x * _gridSize.x + _gridSize.x,
			y * _gridSize.y + _gridSize.y
		);
		
		if (i == 30) return false;
		
		return true;
	}
}