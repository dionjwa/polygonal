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
package testbed.display;

import de.polygonal.core.math.Mathematics;
import de.polygonal.gl.VectorRenderer;
import de.polygonal.gl.Window;
import de.polygonal.motor.collision.shape.AbstractShape;
import de.polygonal.motor.collision.shape.ShapeType;
import de.polygonal.motor.dynamics.RigidBody;
import de.polygonal.core.math.Mat32;

using de.polygonal.ds.BitFlags;

/**
 * A basic shape renderer using a vector drawing api.
 */
class ShapeRenderer
{
	public var shape(default, null):AbstractShape;
	
	public var body(_bodyGetter, never):RigidBody;
	inline function _bodyGetter():RigidBody { return shape.body; }
	
	//interpolated position, previous position, current position
	var _xLerp:Float; var _x0:Float; var _x:Float;
	var _yLerp:Float; var _y0:Float; var _y:Float;
	var _rLerp:Float; var _r0:Float; var _r:Float;
	
	//interpolated transformation
	var _TLerp:Mat32;
	
	var _vr:VectorRenderer;
	var _camera:Camera;
	
	public function new(shape:AbstractShape, camera:Camera, vr:VectorRenderer)
	{
		this.shape = shape;
		
		_camera = camera;
		_vr = vr;
		
		_xLerp = _x0 = _x = shape.x;
		_yLerp = _y0 = _y = shape.y;
		_rLerp = _r0 = _r = shape.r;
		
		_TLerp = new Mat32();
		_TLerp.setTranslation(_xLerp, _yLerp);
		_TLerp.setAngle(_rLerp);
	}
	
	/** Synchronize with shape position & angle. */
	inline public function update():Void
	{
		_x0 = _x; _x = shape.x;
		_y0 = _y; _y = shape.y;
		_r0 = _r; _r = shape.r;
	}
	
	/**
	 * Renders the shape to the screen; linearly interpolates between the previous and current state
	 * for smooth rendering using <i>alpha</i> (&#091;0,1&#093;) as the interpolation value.
	 */
	public function render(alpha:Float):Void
	{
		_interpolate(alpha);
		if (alpha == 1)
		{
			switch (shape.type)
			{
				case ShapeType.CIRCLE: _drawCircle();
				case ShapeType.BOX:    _drawBox();
				case ShapeType.POLY:   _drawPoly();
				case ShapeType.EDGE:   _drawEdge();
			}
		}
		else
		{
			switch (shape.type)
			{
				case ShapeType.CIRCLE: _drawSmoothCircle();
				case ShapeType.BOX:    _drawSmoothBox();
				case ShapeType.POLY:   _drawSmoothPoly();
				case ShapeType.EDGE:   _drawSmoothEdge();
			}
		}
	}
	
	function _interpolate(alpha:Float):Void
	{
		_xLerp = Mathematics.lerp(_x0, _x, alpha);
		_yLerp = Mathematics.lerp(_y0, _y, alpha);
		_rLerp = Mathematics.slerp(_r0, _r, alpha);
		
		_TLerp.setTranslation(_xLerp, _yLerp);
		_TLerp.setAngle(_rLerp);
	}
	
	function _drawCircle():Void
	{
		var x = _camera.toScreenX(shape.x);
		var y = _camera.toScreenY(shape.y);
		var r = _camera.scale(shape.radius);
		
		_vr.circle3(x, y, r);
		_vr.moveTo2(x, y);
		
		x += Math.cos(shape.r) * r;
		y += Math.sin(shape.r) * r;
		
		_vr.lineTo2(x, y);
	}
	
	function _drawSmoothCircle():Void
	{
		var x = _camera.toScreenX(_xLerp);
		var y = _camera.toScreenY(_yLerp);
		var r = _camera.scale(shape.radius);
		
		_vr.circle3(x, y, r);
		_vr.moveTo2(x, y);
		
		x += Math.cos(_rLerp) * r;
		y += Math.sin(_rLerp) * r;
		
		_vr.lineTo2(x, y);
	}
	
	function _drawBox():Void
	{
		shape.syncFeatures();
		
		_vr.quad8
		(
			_camera.toScreenX(shape.v0.x),
			_camera.toScreenY(shape.v0.y),
			_camera.toScreenX(shape.v1.x),
			_camera.toScreenY(shape.v1.y),
			_camera.toScreenX(shape.v2.x),
			_camera.toScreenY(shape.v2.y),
			_camera.toScreenX(shape.v3.x),
			_camera.toScreenY(shape.v3.y)
		);
	}
	
	function _drawSmoothBox():Void
	{
		var ex = shape.ex;
		var ey = shape.ey;
		
		//center->[maxX, maxY]
		var rx1 = _TLerp.mul22x(ex, ey);
		var ry1 = _TLerp.mul22y(ex, ey);
		
		//center->[maxX,minY]
		var rx2 = _TLerp.mul22x(ex,-ey);
		var ry2 = _TLerp.mul22y(ex,-ey);
		
		//draw clockwise
		_vr.quad8
		(
			_camera.toScreenX(_xLerp + rx1),
			_camera.toScreenY(_yLerp + ry1),
			_camera.toScreenX(_xLerp - rx2),
			_camera.toScreenY(_yLerp - ry2),
			_camera.toScreenX(_xLerp - rx1),
			_camera.toScreenY(_yLerp - ry1),
			_camera.toScreenX(_xLerp + rx2),
			_camera.toScreenY(_yLerp + ry2)
		);
	}
	
	function _drawPoly():Void
	{
		shape.syncFeatures();
		
		var v = shape.worldVertexChain;
		
		_vr.moveTo2
		(
			_camera.toScreenX(v.x),
			_camera.toScreenY(v.y)
		);
		
		var v0 = v;
		do
		{
			v = v.next;
			
			_vr.lineTo2
			(
				_camera.toScreenX(v.x),
				_camera.toScreenY(v.y)
			);
		}
		while (v != v0);
	}
	
	function _drawSmoothPoly():Void
	{
		var v = shape.localVertexChain;
		
		_vr.moveTo2
		(
			_camera.toScreenX(_TLerp.mulx(v.x, v.y)),
			_camera.toScreenY(_TLerp.muly(v.x, v.y))
		);
		
		var v0 = v;
		do
		{
			v = v.next;
			
			_vr.lineTo2
			(
				_camera.toScreenX(_TLerp.mulx(v.x, v.y)),
				_camera.toScreenY(_TLerp.muly(v.x, v.y))
			);
		}
		while (v != v0);
	}
	
	function _drawEdge():Void
	{
		shape.syncFeatures();
		
		if (shape.hasf(AbstractShape.EDGE_INFINITE))
		{
			var a = Window.bound();
			
			_vr.planeThroughPoint10
			(
				_camera.toScreenX(shape.v0.x),
				_camera.toScreenY(shape.v0.y),
				shape.n0.x,
				shape.n0.y,
				a.minX, a.minY, a.maxX, a.maxY,
				20, 4
			);
		}
		else
		{
			_vr.line4
			(
				_camera.toScreenX(shape.v0.x),
				_camera.toScreenY(shape.v0.y),
				_camera.toScreenX(shape.v1.x),
				_camera.toScreenY(shape.v1.y)
			);
		}
	}
	
	function _drawSmoothEdge():Void
	{
		shape.syncFeatures();
		
		if (shape.hasf(AbstractShape.EDGE_INFINITE))
		{
			var v = shape.localVertexChain;
			var n = shape.n0;
			var a = Window.bound();
			
			_vr.planeThroughPoint10
			(
				_camera.toScreenX(_TLerp.mulx(v.x, v.y)),
				_camera.toScreenY(_TLerp.muly(v.x, v.y)),
				_TLerp.mul22x(n.x, n.y),
				_TLerp.mul22y(n.x, n.y),
				a.minX, a.minY, a.maxX, a.maxY,
				20, 4
			);
		}
		else
		{
			var v0 = shape.localVertexChain;
			var v1 = shape.localVertexChain.next;
			
			_vr.line4
			(
				_camera.toScreenX(_TLerp.mulx(v0.x, v0.y)),
				_camera.toScreenY(_TLerp.muly(v0.x, v0.y)),
				_camera.toScreenX(_TLerp.mulx(v1.x, v1.y)),
				_camera.toScreenY(_TLerp.muly(v1.x, v1.y))
			);
		}
	}
}