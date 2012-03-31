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

import de.polygonal.core.fmt.Sprintf;
import de.polygonal.core.math.Mathematics;
import de.polygonal.core.math.Vec2Util;
import de.polygonal.gl.VectorRenderer;
import de.polygonal.motor.collision.pairwise.Collider;
import de.polygonal.motor.collision.pairwise.vrm.VRM;
import de.polygonal.motor.collision.pairwise.vrm.VRMFeature;
import de.polygonal.motor.collision.pairwise.vrm.VRMFeaturePair;
import de.polygonal.motor.collision.pairwise.vrm.VRMState;
import de.polygonal.motor.collision.shape.feature.Edge;
import de.polygonal.motor.collision.shape.feature.Vertex;
import de.polygonal.motor.collision.shape.AbstractShape;
import de.polygonal.motor.data.PolyData;
import de.polygonal.motor.data.ShapeData;
import de.polygonal.motor.dynamics.contact.Contact;
import de.polygonal.motor.dynamics.contact.generator.ConvexContact;
import de.polygonal.motor.dynamics.contact.Manifold;
import de.polygonal.motor.geom.closest.ClosestPointSegment;
import de.polygonal.motor.geom.distance.DistancePointSegment;
import de.polygonal.motor.geom.distance.DistanceSegmentSegment;
import de.polygonal.motor.geom.inside.PointInsidePoly;
import de.polygonal.core.math.Vec2;
import de.polygonal.core.math.Vec2;
import de.polygonal.motor.Settings;
import testbed.display.Camera;
import testbed.test.manifold.TestManifold;

class TestManifoldVRM extends TestManifold
{
	override public function getName():String 
	{
		return "voronoi region method";
	}
	
	override function _createShape1():ShapeData
	{
		var density = 0;
		var data = new PolyData(density);
		data.setCircle(6, 2);
		return data;
	}
	
	override function _createShape2():ShapeData
	{
		var density = 0;
		var data = new PolyData(density);
		data.setCircle(6, 1.5);
		return data;
	}
	
	override function _createContact(shape1:AbstractShape, shape2:AbstractShape):Contact
	{
		var c = new VRMContact(shape1, shape2, _vr, _camera); 
		c.init(shape1, shape2);
		return c;
	}
	
	override function _draw(alpha:Float):Void
	{
		_vr.setLineStyle(0xFFFF00, 1, 0);
		
		var c:VRMCollider = cast _contact.collider;
		
		var fp = c.vrm.featurePair;
		if (c.vrmState == VRMState.DONE)
		{
			_drawFeaturePair(fp);
			_drawVoronoiRegionPair(fp);
			_drawMinimumDistance(fp);
		}
		else
		if (c.vrmState == VRMState.PENETRATION || c.vrmState == VRMState.TRAP)
		{
			_drawIntersection(fp);
		}
		
		//_vr.line2(_camera.toScreen(MinDistanceBruteForce.emin1.a, new Vec2()), _camera.toScreen(MinDistanceBruteForce.emin1.b, new Vec2()));
		//_vr.line2(_camera.toScreen(MinDistanceBruteForce.emin2.a, new Vec2()), _camera.toScreen(MinDistanceBruteForce.emin2.b, new Vec2()));
	}
	
	function _drawFeaturePair(fp:VRMFeaturePair):Void
	{
		var clr = 0xFFFF00;
		
		var f1 = fp.f1;
		var f2 = fp.f2;
		
		var t1 = new Vec2();
		var t2 = new Vec2();
		
		switch (f1.type)
		{
			case VRMFeature.TYPE_VERT:
				_highlightVertex(f1.v, clr);
			
			case VRMFeature.TYPE_EDGE:
				_highlightEdge(f1.v.edge, clr);
		}
		
		switch (f2.type)
		{
			case VRMFeature.TYPE_VERT:
				_highlightVertex(f2.v, clr);
			
			case VRMFeature.TYPE_EDGE:
				_highlightEdge(f2.v.edge, clr);
		}
	}
	
	function _drawMinimumDistance(fp:VRMFeaturePair):Void
	{
		var clr = 0x00FF00;
		
		_vr.setLineStyle(clr, 1, 2);
		
		var f1 = fp.f1;
		var f2 = fp.f2;
		
		if (f1.type == VRMFeature.TYPE_VERT && f2.type == VRMFeature.TYPE_VERT)
		{
			var dx = f1.v.x - f2.v.x;
			var dy = f1.v.y - f2.v.y;
			var distance = Math.sqrt(dx * dx + dy * dy);
			
			_camera.toScreen(f1.v, _vTmp);
			_vr.moveTo(_vTmp);
			_camera.toScreen(f2.v, _vTmp);
			_vr.lineTo(_vTmp);
			
			Vec2Util.mid2(f1.v, f2.v, _vTmp);
			_camera.toScreen(_vTmp, _vTmp);
			_annotate(_vTmp, Sprintf.format("%.3f", [distance]));
		}
		else
		if (f1.type == VRMFeature.TYPE_VERT)
		{
			ClosestPointSegment.find3(f1.v, f2.v, f2.w, _vTmp);
			
			var dx = _vTmp.x - f1.v.x;
			var dy = _vTmp.y - f1.v.y;
			var distance = Math.sqrt(dx * dx + dy * dy);
			
			_camera.toScreen(_vTmp, _vTmp);
			_vr.moveTo(_vTmp);
			_camera.toScreen(f1.v, _vTmp);
			_vr.lineTo(_vTmp);
			
			ClosestPointSegment.find3(f1.v, f2.v, f2.w, _vTmp);
			Vec2Util.mid2(f1.v, _vTmp, _vTmp);
			_camera.toScreen(_vTmp, _vTmp);
			_annotate(_vTmp, Sprintf.format("%.3f", [distance]));
		}
		else
		if (f2.type == VRMFeature.TYPE_VERT)
		{
			ClosestPointSegment.find3(f2.v, f1.v, f1.w, _vTmp);
			
			var dx = _vTmp.x - f2.v.x;
			var dy = _vTmp.y - f2.v.y;
			var distance = Math.sqrt(dx * dx + dy * dy);
			
			_camera.toScreen(_vTmp, _vTmp);
			_vr.moveTo(_vTmp);
			_camera.toScreen(f2.v, _vTmp);
			_vr.lineTo(_vTmp);
			
			ClosestPointSegment.find3(f2.v, f1.v, f1.w, _vTmp);
			Vec2Util.mid2(f2.v, _vTmp, _vTmp);
			
			_camera.toScreen(_vTmp, _vTmp);
			_annotate(_vTmp, Sprintf.format("%.3f", [distance]));
		}
	}
	
	function _drawVoronoiRegionPair(fp:VRMFeaturePair):Void
	{
		var f1 = fp.f1;
		var f2 = fp.f2;
		
		var s1 = f1.shape;
		var s2 = f2.shape;
		
		var dx = s1.x - s2.x;
		var dy = s1.y - s2.y;
		var dist = Math.sqrt(dx * dx + dy * dy);
		
		_drawVoronoiRegion(f1, dist);
		_drawVoronoiRegion(f2, dist);
	}
	
	function _drawVoronoiRegion(f:VRMFeature, size:Float):Void
	{
		var vertexList = new Array<Vec2>();
		
		var clr = 0xffffff;
		var alpha = .1;
		
		switch (f.type)
		{
			case VRMFeature.TYPE_VERT:
				vertexList.push(new Vec2(f.v.x, f.v.y));
				vertexList.push(new Vec2(f.v.x + f.n.prev.x * size, f.v.y + f.n.prev.y * size));
				vertexList.push(new Vec2(f.v.x + f.n.x      * size, f.v.y + f.n.y      * size));
				vertexList.push(new Vec2(f.v.x, f.v.y));
			
			case VRMFeature.TYPE_EDGE:
				vertexList.push(new Vec2(f.v.x, f.v.y));
				vertexList.push(new Vec2(f.v.x + f.n.x * size, f.v.y + f.n.y * size));
				vertexList.push(new Vec2(f.w.x + f.n.x * size, f.w.y + f.n.y * size));
				vertexList.push(new Vec2(f.w.x, f.w.y));
				vertexList.push(new Vec2(f.v.x, f.v.y));
		}
		
		for (i in 0...vertexList.length)
			_camera.toScreen(vertexList[i], vertexList[i]);
		
		_vr.clearStroke();
		_vr.setFillColor(clr, alpha);
		_vr.fillStart();
		_vr.polyLineVector(vertexList, true);
		_vr.fillEnd();
	}
	
	function _drawIntersection(fp:VRMFeaturePair):Void
	{
		var clr = 0xff0000;
		
		var f1 = fp.f1;
		var f2 = fp.f2;
		
		_vr.setLineStyle(clr, 1, 0);
		
		if (f1.type == VRMFeature.TYPE_EDGE && f2.type == VRMFeature.TYPE_EDGE)
		{
			_camera.toScreen(f1.v, _vTmp);
			_vr.moveTo(_vTmp);
			_camera.toScreen(f1.w, _vTmp);
			_vr.lineTo(_vTmp);
			
			_camera.toScreen(f2.v, _vTmp);
			_vr.moveTo(_vTmp);
			_camera.toScreen(f2.w, _vTmp);
			_vr.lineTo(_vTmp);
		}
		else
		if (f1.type == VRMFeature.TYPE_EDGE && f2.type == VRMFeature.TYPE_VERT)
		{
			_camera.toScreen(f1.v, _vTmp);
			_vr.moveTo(_vTmp);
			_camera.toScreen(f1.w, _vTmp);
			_vr.lineTo(_vTmp);
			
			_vr.clearStroke();
			_vr.setFillColor(clr, 1);
			_vr.fillStart();
			_vr.box2(_camera.toScreen(f2.v, _vTmp), 4);
			_vr.fillEnd();
		}
		else
		if (f1.type == VRMFeature.TYPE_VERT && f2.type == VRMFeature.TYPE_EDGE)
		{
			_camera.toScreen(f2.v, _vTmp);
			_vr.moveTo(_vTmp);
			_camera.toScreen(f2.w, _vTmp);
			_vr.lineTo(_vTmp);
			
			_vr.clearStroke();
			_vr.setFillColor(clr, 1);
			_vr.fillStart();
			_vr.box2(_camera.toScreen(f1.v, _vTmp), 4);
			_vr.fillEnd();
		}
	}
	
	function _highlightVertex(x:Vec2, clr:Int):Void
	{
		_vr.clearStroke();
		_vr.setFillColor(clr, 1);
		_vr.fillStart();
		_vr.box2(_camera.toScreen(x, _vTmp), 4);
		_vr.fillEnd();
	}
	
	function _highlightEdge(e:Edge, clr:Int):Void
	{
		_vr.setLineStyle(clr, 1, 2);
		_camera.toScreen(e.a, _vTmp);
		var tx = _vTmp.x;
		var ty = _vTmp.y;
		_camera.toScreen(e.b, _vTmp);
		_vr.line4(tx, ty, _vTmp.x, _vTmp.y);
	}
	
	function _minDistanceBruteForce(manifold:Manifold, shape1:AbstractShape, shape2:AbstractShape):Float
	{
		var e10, e20;
		var e1:Edge = null, e2:Edge = null;
		
		e10 = shape1.worldVertexChain.edge;
		e1 = e10;
		
		var emin1 = null;
		var emin2 = null;
		var dmin = Mathematics.POSITIVE_INFINITY;
		
		do
		{
			e20 = shape2.worldVertexChain.edge;
			e2 = e20;
			do
			{
				var d = DistanceSegmentSegment.find4(e1.a, e1.b, e2.a, e2.b);
				if (d * .95 < dmin)
				{
					dmin = d;
					emin1 = e1;
					emin2 = e2;
				}
				
				e2 = e2.next;
			}
			while (e2 != e20);
			
			e1 = e1.next;
		}
		while (e1 != e10);
		
		var intersect = false;
		var v0 = shape1.worldVertexChain;
		var v = v0;
		do
		{
			if (shape2.containsPoint(v))
			{
				intersect = true;
				break;
			}
			
			v = v.next;
		}
		while (v != v0);
		
		if (!intersect)
		{
			var v0 = shape2.worldVertexChain;
			var v = v0;
			do
			{
				if (shape1.containsPoint(v))
				{
					intersect = true;
					break;
				}
				
				v = v.next;
			}
			while (v != v0);
		}
		
		if (intersect) dmin = 0;
		
		return dmin;
	}
}

class VRMContact extends ConvexContact
{
	var _vr:VectorRenderer;
	var _camera:Camera;
	
	public function new(shape1:AbstractShape, shape2:AbstractShape, vr:VectorRenderer, camera:Camera)
	{
		super(new Settings());
		_vr = vr;
		_camera = camera;
	}

	override function _getCollider():Collider
	{
		return new VRMCollider(shape1, shape2, _vr, _camera);
	}
}

class VRMCollider implements Collider
{
	public var vrm(default, null):VRM;
	public var vrmState:Int;
	
	var _vr:VectorRenderer;
	var _camera:Camera;
	
	public function new(shape1:AbstractShape, shape2:AbstractShape, vr:VectorRenderer, camera:Camera)
	{
		_vr = vr;
		_camera = camera;
		
		vrm = new VRM(shape1, shape2);
	}
	
	public function collide(manifold:Manifold, shape1:AbstractShape, shape2:AbstractShape):Void
	{
		vrmState = vrm.evaluate();
	}
	
	public function init(shape1:AbstractShape, shape2:AbstractShape):Void {}
	
	public function free():Void {}
}