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
package testbed.test.manifold.misc;

import de.polygonal.core.event.IObserver;
import de.polygonal.core.fmt.Sprintf;
import de.polygonal.core.math.Mean;
import de.polygonal.core.math.Mathematics;
import de.polygonal.core.math.random.Random;
import de.polygonal.core.math.Vec2Util;
import de.polygonal.core.Root;
import de.polygonal.ds.Bits;
import de.polygonal.gl.Window;
import de.polygonal.motor.collision.shape.AbstractShape;
import de.polygonal.motor.collision.shape.feature.Vertex;
import de.polygonal.motor.data.BoxData;
import de.polygonal.motor.data.PolyData;
import de.polygonal.motor.data.RigidBodyData;
import de.polygonal.motor.dynamics.RigidBody;
import de.polygonal.core.math.Vec2;
import de.polygonal.motor.geom.primitive.AABB2;
import de.polygonal.motor.Settings;
import de.polygonal.motor.World;
import de.polygonal.ui.Key;
import de.polygonal.ui.UI;
import testbed.display.ShapeFeatureRenderer;
import testbed.test.TestCase;

using de.polygonal.ds.Bits;
using de.polygonal.gl.color.ARGB;
using de.polygonal.ds.BitFlags;

class TestSupportMapping extends TestCase
{
	inline static var DRAW_NORMALS     = Bits.BIT_03;
	inline static var FORCE_BSP        = Bits.BIT_04;
	inline static var BENCHMARK_ACTIVE = Bits.BIT_05;
	
	var _nullWorld:World;
	var _body:RigidBody;
	var _shape:AbstractShape;
	
	var _shapeRenderer:ShapeFeatureRenderer;
	var _mean:Mean;
	
	override public function getName():String 
	{
		return "support mapping";
	}

	function _createShape(vertexCount:Int):Void
	{
		vertexCount = Mathematics.clamp(vertexCount, 3, 20);
		
		var bd = new RigidBodyData(0, 0, 0);
		
		if (vertexCount == 4)
		{
			var w = Random.frandRange(1.5, 2.5);
			var h = Random.frandRange(1.5, 2.5);
			var sd = new BoxData(0, w, h);
			bd.addShapeData(sd);
		}
		else
		{
			var sd = new PolyData(0);
			sd.setCircle(vertexCount, 2);
			bd.addShapeData(sd);
		}
		
		if (_body != null)
		{
			_body.free();
		}
		
		_body = _nullWorld.createBody(bd);
		_shape = _body.shape;
		
		_shapeRenderer = new ShapeFeatureRenderer(_body.shape, _camera, _vr);
		_setupShapeRenderer(_shapeRenderer);
	}
	
	override function _drawInternal(alpha:Float):Void
	{
		_shapeRenderer.update();
		
		_vr.setLineStyle(0xffffff, .75, 0);
		_shapeRenderer.render(1);
		_shapeRenderer.drawVertexChain(alpha);
		
		if (hasf(DRAW_NORMALS))
			_shapeRenderer.drawNormalChain(alpha);
		
		//use body->mouse as support direction
		var p = _getWorldMouse();
		var b = _body.origin;
		
		//draw support direction
		_vr.setLineStyle(0x00ffff, 0.5, 0);
		
		var s = new Vec2(p.x - b.x, p.y - b.y);
		var length = s.unit();
		
		var w = _camera.toScreen(b, new Vec2());
		_vr.arrowRay4(w, s, _camera.scale(length), 4 + _camera.scale(length) / 20);
		
		//compute support point
		var min:Vertex = null;
		
		var iter = 1000000;
		
		//choose strategy
		if (_body.shape.vertexCount > 4 || hasf(FORCE_BSP))
		{
			if (hasf(BENCHMARK_ACTIVE))
			{
				var time = flash.Lib.getTimer();
				for (j in 0...iter) min = _supportBSP(s);
				_mean.add(flash.Lib.getTimer() - time);
			}
			else
				min = _supportBSP(s);
		}
		else
		if (_body.shape.vertexCount == 3)
		{
			if (hasf(BENCHMARK_ACTIVE))
			{
				var time = flash.Lib.getTimer();
				for (j in 0...iter) min = _supportTriangle(s);
				_mean.add(flash.Lib.getTimer() - time);
			}
			else
				min = _supportTriangle(s);
		}
		else
		if (_body.shape.vertexCount == 4)
		{
			if (Mathematics.fabs(_shape.body.angle) <= .5)
			{
				if (hasf(BENCHMARK_ACTIVE))
				{
					var time = flash.Lib.getTimer();
					for (j in 0...iter) min = _supportAABB(s);
					_mean.add(flash.Lib.getTimer() - time);
				}
				else
					min = _supportAABB(s);
			}
			else
			{
				if (hasf(BENCHMARK_ACTIVE))
				{
					var time = flash.Lib.getTimer();
					for (j in 0...iter) min = _supportOBB(s);
					_mean.add(flash.Lib.getTimer() - time);
				}
				else
					min = _supportOBB(s);
			}
		}
		
		if (hasf(BENCHMARK_ACTIVE))
		{
			_vr.clearStroke();
			_vr.setFillColor(0xffffff, 1);
			_vr.fillStart();
			
			var s = Sprintf.format("%.1f ms (x1.000.000)", [_mean.val]);
			TestCase.getFont().getBound(s, 0, 0, false, true, _tmpAABB);
			TestCase.getFont().write(s, Window.bound().intervalX - _tmpAABB.intervalX - 10, 22);
			_vr.fillEnd();
		}
		
		//draw support point
		_camera.toScreen(_shape.worldVertexChain.getAt(min.i), w);
		
		_vr.clearStroke();
		_vr.style.setFillColor(0xFFFF00, 1.0);
		_vr.fillStart();
		_vr.box2(w, 4);
		_vr.fillEnd();
		
		//draw support levels
		_vr.setLineStyle(0x00ffff, 0.25, 0);
		var v = _shape.worldVertexChain;
		for (i in 0..._shape.vertexCount)
		{
			var tx = v.x - _shape.x;
			var ty = v.y - _shape.y;
			var dot = tx * s.x + ty * s.y;
			
			var px = _shape.x + dot * s.x;
			var py = _shape.y + dot * s.y;
			
			_camera.toScreen(v, w);
			
			var tx = w.x;
			var ty = w.y;
			
			_camera.toScreen(new Vec2(px, py), w);
			
			_vr.line4(tx, ty, w.x, w.y);
			
			v = v.next;
		}
	}
	
	override function _onMouseWheel(delta:Int):Void
	{
		var angle = UI.get.isShiftDown ? 1 : 5;
		var p = _shape.body.origin;
		var a = _shape.body.angle + ((angle * Mathematics.DEG_RAD) * Mathematics.sgn(delta));
		_shape.body.transform(p.x, p.y, a);
	}
	
	override function _onKeyDown(keyCode:Int):Void
	{
		if (hasf(BENCHMARK_ACTIVE) && keyCode != Key.B) return;
		
		switch (keyCode)
		{
			case Key.F1 : _menu.toggleMenu();
			case Key.F2 : _createShape(_shape.vertexCount + 1);
			case Key.F3 : _createShape(_shape.vertexCount - 1);
			case Key.F4 : _menu.toggleMenuEntry( 3); invf(DRAW_NORMALS);
			case Key.F5 : _menu.toggleMenuEntry( 4); invf(FORCE_BSP);
			case Key.B : _menu.toggleMenuEntry( 5); invf(BENCHMARK_ACTIVE); _mean = new Mean(100);
		}
	}
	
	override function _init():Void
	{
		var settings = new Settings();
		settings.worldBound = new AABB2(-100, -100, 100, 100);
		settings.maxProxies = settings.maxPairs = 16;
		_nullWorld = new World(settings);
		
		_createShape(10);
		
		_mean = new Mean(100);
		
		//setup menu
		var menuEntries = new Array<String>();
		menuEntries.push("F1\tmenu");
		menuEntries.push("F2\tadd vertex");
		menuEntries.push("F3\tdelete vertex");
		menuEntries.push("F4\tdraw normals");
		menuEntries.push("F5\tforce BSP");
		menuEntries.push("b\tbenchmark");
		menuEntries.push("");
		menuEntries.push("left/right: prev/next test");
		_initMenu(menuEntries, _bits);
	}
	
	override function _free():Void
	{
		_nullWorld.free();
		_mean.free();
		super._free();
	}
	
	inline function _supportTriangle(s:Vec2):Vertex
	{
		var shape = _shape;
		
		var dx = s.x;
		var dy = s.y;
		
		var min0 = shape.v0.x * dx + shape.v0.y * dy;
		var min1 = shape.v1.x * dx + shape.v1.y * dy;
		if (min1 > min0)
			if (shape.v2.x * dx + shape.v2.y * dy < min1)
				return shape.v1;
			else
				return shape.v2;
		else
			if (shape.v2.x * dx + shape.v2.y * dy < min0)
				return shape.v0;
			else
				return shape.v2;
	}
	
	inline function _supportAABB(s:Vec2):Vertex
	{
		if (s.x > 0)
			if (s.y > 0)
				return _shape.v0;
			else
				return _shape.v3;
		else
			if (s.y > 0)
				return _shape.v1;
			else
				return _shape.v2;
	}
	
	function _supportOBB(s:Vec2):Vertex
	{
		var shape = _shape;
		var T = shape.TWorld;
		var sx = s.x;
		var sy = s.y;
		
		if (T.mul22Tx(sx, sy) > 0)
		{
			if (T.mul22Ty(sx, sy) > 0)
				return shape.v0;
			else
				return shape.v3;
		}
		else
		{
			if (T.mul22Ty(sx, sy) > 0)
				return shape.v1;
			else
				return shape.v2;
		}
				
		return shape.v0;
	}
	
	inline function _supportBSP(s:Vec2):Vertex
	{
		var node = _shape.BSPNode;
		var dx = s.x;
		var dy = s.y;
		while (node.R != null)
		{
			var t = node.N;
			node = Vec2Util.perpDot4(t.x, t.y, dx, dy) <= 0 ? node.R : node.L;
		}
		return node.V;
	}
	
	function _setupShapeRenderer(s:ShapeFeatureRenderer):Void
	{
		s.colorFirstVertex = 0xffC99C01.toARGB();
		s.colorOtherVertex = 0xffC99C01.toARGB();
		s.colorNormalChain = 0x2000ffff.toARGB();
		s.vertexChainPointSize = 2;
		s.normalChainArrowLength = 200;
	}
}