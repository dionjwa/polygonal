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
import de.polygonal.gl.color.ARGB;
import de.polygonal.gl.text.VectorFont;
import de.polygonal.gl.VectorRenderer;
import de.polygonal.motor.collision.shape.AbstractShape;
import de.polygonal.motor.collision.shape.feature.Vertex;
import de.polygonal.motor.collision.shape.PolyShape;
import de.polygonal.motor.collision.shape.ShapeType;
import de.polygonal.core.math.Vec2;
import de.polygonal.core.math.Vec2;
import de.polygonal.motor.geom.primitive.OBB2;

/**
 * Additional methods for drawing various shape properties for debug/demo purposes.
 */
class ShapeFeatureRenderer extends ShapeRenderer
{
	public var colorFirstVertex:ARGB;
	public var colorOtherVertex:ARGB;
	public var colorNormalChain:ARGB;
	public var colorAxis_x:ARGB;
	public var colorAxis_y:ARGB;
	public var colorVertexId:ARGB;
	public var colorCenterA:ARGB;
	public var colorCenterB:ARGB;
	public var colorWinding:ARGB;
	public var colorBoundingBox:ARGB;
	public var colorBoundingSphere:ARGB;
	public var colorLabel:ARGB;
	public var colorOBB:ARGB;
	
	public var solidProxy:Bool;
	public var vertexChainPointSize:Float;
	public var normalChainArrowLength:Float;
	public var centerRadius:Float;
	public var vertexIdFontSize:Int;
	public var labelFontSize:Int;
	
	public var font:VectorFont;
	
	var _tmpVec:Vec2;
	var _tmpVertices:Array<Vec2>;
	
	public function new(shape:AbstractShape, screenSpace:Camera, vr:VectorRenderer)
	{
		super(shape, screenSpace, vr);
		
		_tmpVec = new Vec2();
		if (shape.type == ShapeType.POLY)
		{
			_tmpVertices = new Array<Vec2>();
			for (i in 0...4) _tmpVertices[i] = new Vec2();
		}
	}
	
	public function drawVertexChain(alpha:Float):Void
	{
		if (shape.type == ShapeType.CIRCLE) return;
		
		_interpolate(alpha);
		
		if (alpha == 1)
		{
			shape.syncFeatures();
			
			var v = shape.worldVertexChain, v0 = v;
			var xs = _camera.toScreenX(v.x);
			var ys = _camera.toScreenY(v.y);
			
			_vr.clearStroke();
			_vr.style.setFillColorARGB(colorFirstVertex);
			_vr.fillStart();
			_vr.box3(xs, ys, vertexChainPointSize);
			_vr.fillEnd();
			_vr.style.setFillColorARGB(colorOtherVertex);
			_vr.fillStart();
			
			v = v.next;
			do
			{
				_vr.box3
				(
					_camera.toScreenX(v.x),
					_camera.toScreenY(v.y),
					vertexChainPointSize
				);
				
				v = v.next;
			}
			while (v != v0);
			
			_vr.fillEnd();
		}
		else
		{
			var v = shape.localVertexChain, v0 = v;
			var xs = _camera.toScreenX(_TLerp.mulx(v.x, v.y));
			var ys = _camera.toScreenY(_TLerp.muly(v.x, v.y));
			
			_vr.clearStroke();
			
			_vr.style.setFillColorARGB(colorFirstVertex);
			_vr.fillStart();
			_vr.box3(xs, ys, vertexChainPointSize);
			_vr.fillEnd();
			
			_vr.style.setFillColorARGB(colorOtherVertex);
			_vr.fillStart();
			
			_vr.moveTo2(xs, ys);
			v = v.next;
			
			do
			{
				_vr.box3
				(
					_camera.toScreenX(_TLerp.mulx(v.x, v.y)),
					_camera.toScreenY(_TLerp.muly(v.x, v.y)),
					vertexChainPointSize
				);
				
				v = v.next;
			}
			while (v != v0);
			
			_vr.fillEnd();
		}
	}
	
	public function drawNormalChain(alpha:Float):Void
	{
		if (shape.type == ShapeType.CIRCLE) return;
		
		_interpolate(alpha);
		
		if (alpha == 1)
		{
			shape.syncFeatures();
			
			var v = shape.worldVertexChain, v0 = v;
			var n = shape.worldNormalChain;
			
			_vr.style.setLineColorARGB(colorNormalChain, 0);
			_vr.applyLineStyle();
			
			do
			{
				var xs = _camera.toScreenX(v.x + (v.next.x - v.x) * .5);
				var ys = _camera.toScreenY(v.y + (v.next.y - v.y) * .5);
				_vr.arrowRay6(xs, ys, n.x, n.y, normalChainArrowLength, 0);
				v = v.next;
				n = n.next;
			}
			while (v != v0);
		}
		else
		{
			var v = shape.localVertexChain, v0 = v;
			var n = shape.localNormalChain;
			
			_vr.style.setLineColorARGB(colorNormalChain, 0);
			_vr.applyLineStyle();
			
			do
			{
				var cx = v.x + (v.next.x - v.x) * .5;
				var cy = v.y + (v.next.y - v.y) * .5;
				
				var xs = _camera.toScreenX(_TLerp.mulx(cx, cy));
				var ys = _camera.toScreenY(_TLerp.muly(cx, cy));
				
				var nx = _TLerp.mul22x(n.x, n.y);
				var ny = _TLerp.mul22y(n.x, n.y);
				
				_vr.arrowRay6(xs, ys, nx, ny, normalChainArrowLength, 0);
				
				v = v.next;
				n = n.next;
			}
			while (v != v0);
		}
	}
	
	public function drawVertexIds(alpha:Float):Void
	{
		if (shape.type == ShapeType.CIRCLE) return;
		
		_interpolate(alpha);
		
		_vr.clearStroke();
		_vr.style.setFillColorARGB(colorVertexId);
		_vr.fillStart();
		
		var inset = shape.radius * .1;
		
		var fontSize = font.size;
		
		if (alpha == 1)
		{
			shape.syncFeatures();
			
			var v = shape.worldVertexChain, v0 = v;
			do
			{
				_bisector(v, inset, _tmpVec);
				_camera.toScreen(_tmpVec, _tmpVec);
				font.size = vertexIdFontSize;
				font.write(Std.string(v.i), _tmpVec.x, _tmpVec.y, true);
				v = v.next;
			}
			while (v != v0);
			
			_vr.fillEnd();
		}
		else
		{
			var v = shape.localVertexChain, v0 = v;
			do
			{
				_bisector(v, inset, _tmpVec);
				_TLerp.mul(_tmpVec, _tmpVec);
				_camera.toScreen(_tmpVec, _tmpVec);
				font.size = vertexIdFontSize;
				font.write(Std.string(v.i), _tmpVec.x, _tmpVec.y, true);
				v = v.next;
			}
			while (v != v0);
			
			_vr.fillEnd();
		}
		
		font.size = fontSize;
	}
	
	public function drawAxis(alpha:Float):Void
	{
		_interpolate(alpha);
		
		var exs = _camera.scale(shape.ex * .5);
		var eys = _camera.scale(shape.ey * .5);
		
		var pxs = _camera.toScreenX(_xLerp);
		var pys = _camera.toScreenY(_yLerp);
		
		var xAxis_x = _TLerp.mul22x(exs, 0);
		var xAxis_y = _TLerp.mul22y(exs, 0);
		var yAxis_x = _TLerp.mul22x(0, eys);
		var yAxis_y = _TLerp.mul22y(0, eys);
		
		_vr.style.setLineColorARGB(colorAxis_x, 0);
		_vr.applyLineStyle();
		_vr.line4(pxs, pys, pxs + xAxis_x, pys + xAxis_y);
		
		_vr.style.setLineColorARGB(colorAxis_y, 0);
		_vr.applyLineStyle();
		_vr.line4(pxs, pys, pxs + yAxis_x, pys + yAxis_y);
	}
	
	public function drawWinding(alpha:Float):Void
	{
		if (shape.type == ShapeType.CIRCLE) return;
		
		_interpolate(alpha);
		
		var xs = _camera.toScreenX(alpha == 1 ? _x : _xLerp);
		var ys = _camera.toScreenY(alpha == 1 ? _y : _yLerp);
		
		var radius = shape.radius / 2;
		
		_vr.style.setLineColorARGB(colorWinding);
		_vr.style.lineThickness = 0;
		_vr.applyLineStyle();
		_vr.arc5(xs, ys, 0, Mathematics.PI * 1.5, _camera.scale(radius));
		
		ys = _camera.toScreenY((alpha == 1 ? _y : _yLerp) - radius);
		_vr.line4(xs, ys, xs - 4, ys - 4);
		_vr.line4(xs, ys, xs - 4, ys + 4);
	}
	
	public function drawBoundingBox(alpha:Float):Void
	{
		_interpolate(alpha);
		
		if (solidProxy)
		{
			_vr.clearStroke();
			_vr.style.setFillColorARGB(colorBoundingBox);
			_vr.fillStart();
		}
		else
		{
			_vr.style.setLineColorARGB(colorBoundingBox, 0);
			_vr.applyLineStyle();
		}
		
		var bound = shape.aabb;
		
		_vr.aabbMinMax4
		(
			_camera.toScreenX(bound.minX),
			_camera.toScreenY(bound.minY),
			_camera.toScreenX(bound.maxX),
			_camera.toScreenY(bound.maxY)
		);
		
		if (solidProxy) _vr.fillEnd();
		
		//draw OBB for polygons
		if (shape.type != ShapeType.POLY) return;
		
		shape.syncFeatures();
		
		var poly:PolyShape = cast shape;
		var f:{	private var _obb:OBB2; private var _bits:Int; } = poly;
		
		if ((f._bits & AbstractShape.AABB_FIT_OBB) == 0) return;
		
		var obb = f._obb;
		
		var a = obb.getVertexList(_tmpVertices);
		if (alpha == 1)
		{
			for (i in 0...a.length)
				shape.TBody.mul(a[i], a[i]);
		}
		else
		{
			//reverse baked down obb local transform
			for (i in 0...a.length)
			{
				var v = a[i];
				shape.TLocal.mulT(a[i], v);
			}
			
			//then apply world transform
			for (i in 0...a.length)
			{
				var v = a[i];
				_TLerp.mul(a[i], v);
			}
		}
		
		var v = a[0];
		
		var x0 = _camera.toScreenX(v.x);
		var y0 = _camera.toScreenY(v.y);
		_vr.moveTo2(x0, y0);
		
		_vr.style.setLineColorARGB(colorOBB);
		_vr.style.lineThickness = 0;
		_vr.applyLineStyle();
		
		for (i in 1...a.length)
		{
			var v = a[i];
			var x = _camera.toScreenX(v.x);
			var y = _camera.toScreenY(v.y);
			
			//connect remaining vertices
			_vr.lineTo2(x, y);
		}
		_vr.lineTo2(x0, y0);
		
		var cc = obb.c;
		
		var t = shape.TBody.mul(cc, new Vec2());
		var t = _camera.toScreen(t, new Vec2());
		_vr.crossHair2(t, 10);
	}
	
	public function drawBoundingSphere(alpha:Float):Void
	{
		_interpolate(alpha);
		
		if (solidProxy)
		{
			_vr.clearStroke();
			_vr.style.setFillColorARGB(colorBoundingSphere);
			_vr.fillStart();
		}
		else
		{
			_vr.style.setLineColorARGB(colorBoundingSphere);
			_vr.applyLineStyle();
		}
		
		var xs = _camera.toScreenX(alpha == 1 ? _x : _xLerp);
		var ys = _camera.toScreenY(alpha == 1 ? _y : _yLerp);
		
		_vr.circle3(xs, ys, _camera.scale(shape.radius));
		
		if (solidProxy) _vr.fillEnd();
		
		//draw sweep radius around body center
		_vr.setLineStyle(colorBoundingSphere.get24(), 1, 0);
		_vr.applyLineStyle();
		
		var p = body.worldCenter;
		
		var dx = shape.x - p.x;
		var dy = shape.y - p.y;
		
		xs -= dx;
		ys -= dy;
		
		_vr.circle3(xs, ys,_camera.scale(shape.sweepRadius));
		
		//draw core vertices
		if (shape.type != ShapeType.POLY) return;
		
		var cx = _xLerp;
		var cy = _yLerp;
		
		var T = alpha == 1 ? shape.TWorld : _TLerp;
		var friend: { private var _coreVertexChain:Vertex; } = cast(shape, PolyShape);
		var v = friend._coreVertexChain;
		var x = _camera.toScreenX(T.mulx(v.x, v.y));
		var y = _camera.toScreenY(T.muly(v.x, v.y));
		_vr.moveTo2(x, y);
		v = v.next;
		
		var v0 = v;
		do
		{
			_vr.lineTo2
			(
				_camera.toScreenX(T.mulx(v.x, v.y)),
				_camera.toScreenY(T.muly(v.x, v.y))
			);
			v = v.next;
		}
		while (v != v0);
	}
	
	public function drawLabel(text:String, alpha:Float):Void
	{
		_interpolate(alpha);
		
		var x = _camera.toScreenX(alpha == 1 ? _x : _xLerp);
		var y = _camera.toScreenY(alpha == 1 ? _y : _yLerp);
		
		x = Std.int(x);
		y = Std.int(y);
		
		_vr.style.setFillColorARGB(colorLabel);
		_vr.clearStroke();
		_vr.fillStart();
		var fontSize = font.size;
		font.size = labelFontSize;
		font.write(Std.string(text), x, y, true);
		_vr.fillEnd();
		font.size = fontSize;
	}
	
	public function drawCenter(alpha:Float):Void
	{
		_interpolate(alpha);
		
		var xs = _camera.toScreenX(_xLerp);
		var ys = _camera.toScreenY(_yLerp);
		var rs = _rLerp;
		_marker(xs, ys, rs, centerRadius, colorCenterA, colorCenterB);
		
		//TODO draw body center - move to RigidBodyRenderer?
		var x = _camera.toScreenX(body.x);
		var y = _camera.toScreenY(body.y);
		_vr.setLineStyle(0xFFFFFF, 1, 0);
		_vr.crossHair3(x, y, 8);
	}
	
	function _bisector(v:Vertex, insetAmount:Float, out:Vec2)
	{
		var v0 = v.prev;
		var v1 = v;
		var v2 = v.next;
		
		var dx1 = v0.x - v1.x;
		var dy1 = v0.y - v1.y;
		var len1 = Math.sqrt(dx1 * dx1 + dy1 * dy1);
		dx1 /= len1;
		dy1 /= len1;
		
		var dx2 = v2.x - v1.x;
		var dy2 = v2.y - v1.y;
		var len2 = Math.sqrt(dx2 * dx2 + dy2 * dy2);
		dx2 /= len2;
		dy2 /= len2;
		
		out.x = v1.x + (dx1 + dx2) * insetAmount;
		out.y = v1.y + (dy1 + dy2) * insetAmount;
	}
	
	function _marker(x:Float, y:Float, r:Float, radius:Float, color1:ARGB, color2:ARGB)
	{
		#if debug
		de.polygonal.core.macro.Assert.assert(radius > 0, "radius > 0");
		#end
		
		_vr.clearStroke();
		_vr.style.setFillColorARGB(color1);
		
		_vr.fillStart();
		_vr.wedge5(x, y, r, r - Mathematics.PIHALF, radius);
		_vr.wedge5(x, y, r + Mathematics.PIHALF, r + Mathematics.PI, radius);
		_vr.fillEnd();
		
		_vr.style.setFillColorARGB(color2);
		
		_vr.fillStart();
		_vr.wedge5(x, y, r, r + Mathematics.PIHALF, radius);
		_vr.wedge5(x, y, r - Mathematics.PIHALF, r - Mathematics.PI, radius);
		_vr.fillEnd();
	}
}