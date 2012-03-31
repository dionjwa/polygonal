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
import de.polygonal.core.Root;
import de.polygonal.ds.Bits;
import de.polygonal.gl.VectorRenderer;
import de.polygonal.gl.Window;
import de.polygonal.motor.collision.pairwise.Collider;
import de.polygonal.motor.collision.pairwise.mpr.MPRDistance;
import de.polygonal.motor.collision.shape.AbstractShape;
import de.polygonal.motor.collision.shape.feature.Edge;
import de.polygonal.motor.collision.shape.feature.Vertex;
import de.polygonal.motor.data.PolyData;
import de.polygonal.motor.data.ShapeData;
import de.polygonal.motor.dynamics.contact.Contact;
import de.polygonal.motor.dynamics.contact.ContactID;
import de.polygonal.motor.dynamics.contact.generator.ConvexContact;
import de.polygonal.motor.dynamics.contact.Manifold;
import de.polygonal.motor.geom.bv.ChainHull;
import de.polygonal.motor.geom.closest.ClosestPointSegment;
import de.polygonal.motor.geom.distance.DistancePointSegment;
import de.polygonal.motor.geom.distance.DistanceSegmentSegment;
import de.polygonal.core.math.Vec2;
import de.polygonal.core.math.Vec2;
import de.polygonal.motor.Settings;
import de.polygonal.ui.Key;
import testbed.display.Camera;
import testbed.test.manifold.TestManifold;

using de.polygonal.ds.BitFlags;

class TestManifoldPolyMPR extends TestManifold
{
	inline static var DRAW_INTERNALS = Bits.BIT_21;
	
	override public function getName():String 
	{
		return "minkowski portal refinement algorithm";
	}
	
	override function _createShape1():ShapeData
	{
		var data = new PolyData(0);
		data.setCircle(7, 2);
		return data;
	}
	
	override function _createShape2():ShapeData
	{
		var data = new PolyData(0);
		data.setCircle(5, 2);
		return data;
	}
	
	override function _createContact(shape1:AbstractShape, shape2:AbstractShape):Contact
	{
		var c = new MPRContact(shape1, shape2, _vr, _camera);
		c.init(shape1, shape2);
		return c;
	}
	
	override function _draw(alpha:Float):Void
	{
		_drawClosestFeaturesAndDistance();
		
		if (!hasf(DRAW_INTERNALS)) return;
		_drawMinkowskiDifference();
		_drawPortals();
	}
	
	function _drawMinkowskiDifference():Void
	{
		var minkSum = new Array<Vec2>();
		var v1 = _shape1.worldVertexChain, v = v1;
		do
		{
			var v2 = _shape2.worldVertexChain, w = v2;
			do
			{
				minkSum.push(new Vec2(v1.x - v2.x, v1.y - v2.y));
				v2 = v2.next;
			}
			while (v2 != w);
			
			v1 = v1.next;
		}
		while (v1 != v);
		
		var hull = new Array<Vec2>();
		ChainHull.find(minkSum, hull);
		
		_vr.setFillColor(0xffffff, 0.1);
		_vr.fillStart();
		var hullScreen = new Array<Vec2>();
		for (i in 0...hull.length)
			_camera.toScreen(hull[i], hullScreen[i] = new Vec2());
		_vr.polyLineVector(hullScreen, true);
		_vr.fillEnd();
		
		_vr.setLineStyle(0xffffff, 1, 0);
		_vr.crossHair3(_camera.x, _camera.y, Mathematics.fmax(Window.bound().centerX, Window.bound().centerY));
	}
	
	function _drawPortals()
	{
		var mpr:MPRCollider = cast _contact.collider;
		if (mpr.wedges == null) return;
		for (i in 0...mpr.wedges.length)
		{
			var v0 = _camera.toScreen(mpr.wedges[i][0], new Vec2());
			var v1 = _camera.toScreen(mpr.wedges[i][1], new Vec2());
			var v2 = _camera.toScreen(mpr.wedges[i][2], new Vec2());
			
			_vr.setLineStyle(0xffffff, .1, 0);
			_vr.moveTo(v0);
			_vr.lineTo(v1);
			_vr.moveTo(v0);
			_vr.lineTo(v2);
			_vr.setLineStyle(0x00ffff, 1, 0);
			_vr.moveTo(v1);
			_vr.lineTo(v2);
		}
	}
	
	function _drawClosestFeaturesAndDistance()
	{
		var mpr:MPRCollider = cast _contact.collider;
		
		var clr = 0xFFFF00;
		
		if (mpr.s1a == null) return;
		
		var c:Vec2 = null, d:Vec2 = null, e:Vec2 = null;
		
		var a = mpr.s1a;
		var b = mpr.s2a;
		if (a == b)
		{
			_vr.clearStroke();
			_vr.setFillColor(clr, 1);
			_vr.fillStart();
			_vr.box2(_camera.toScreen(a, _vTmp), 4);
			_vr.fillEnd();
			
			c = a;
		}
		else
		{
			_vr.setLineStyle(clr, 1, 0);
			_vr.moveTo(_camera.toScreen(a, _vTmp));
			_vr.lineTo(_camera.toScreen(b, _vTmp));
			
			d = a;
			e = b;
		}
		
		var a = mpr.s1b;
		var b = mpr.s2b;
		if (a == b)
		{
			_vr.clearStroke();
			_vr.setFillColor(clr, 1);
			_vr.fillStart();
			_vr.box2(_camera.toScreen(a, new Vec2()), 4);
			_vr.fillEnd();
			
			c = a;
		}
		else
		{
			_vr.setLineStyle(clr, 1, 0);
			_vr.moveTo(_camera.toScreen(a, _vTmp));
			_vr.lineTo(_camera.toScreen(b, _vTmp));
			
			d = a;
			e = b;
		}
		
		var c1 = new Vec2();
		ClosestPointSegment.find3(c, d, e, c1);
		_camera.toScreen(c1, c1);
		
		 var c2 = new Vec2();
		_camera.toScreen(c, c2);
		_vr.setLineStyle(0x00FF00, 1, 0);
		_vr.line2(c1, c2);
		
		var mpr:MPRCollider = cast _contact.collider;
		var d1 = Math.sqrt(mpr.minDistance);
		//var d2 = Math.sqrt(new MPRDistance().distance(_shape1, _shape2));
		
		Vec2Util.mid2(c1, c2, _vTmp);
		_annotate(_vTmp, Sprintf.format("%.3f", [d1]));
		//annotate(_vTmp, Sprintf.format("%.3f %.3f", [d1, d2]));
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
	
	override function _onKeyDown(keyCode:Int):Void
	{
		switch (keyCode)
		{
			case Key.X:
				_menu.toggleMenuEntry(25);
				invf(DRAW_INTERNALS);
		}
		
		super._onKeyDown(keyCode);
	}
	
	override function _initMenu(menuEntries:Array<String>, ?activeEntries = 0):Void
	{
		menuEntries.push("");
		menuEntries.push("x\tdraw internals");
		super._initMenu(menuEntries, activeEntries);
	}
}

private class MPRContact extends ConvexContact
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
		return new MPRCollider(_vr, _camera);
	}
}

private class MPRCollider implements Collider
{
	inline static var CW  = 1;
	inline static var CCW =-1;
	
	var _winding:Int;
	
	//{<-- debug
	public var v0:Vec2;
	public var v1:Vec2;
	public var v2:Vec2;
	public var v3:Vec2;
	public var iterations:Int;
	public var wedges:Array<Array<Vec2>>;
	//}-->
	
	var _vr:VectorRenderer;
	var _camera:Camera;
	
	var _warmStart:Bool;
	
	public var s1a:Vertex;
	public var s1b:Vertex;
	public var s2a:Vertex;
	public var s2b:Vertex;
	public var s3a:Vertex;
	public var s3b:Vertex;
	
	var _vTmp:Vec2;
	
	public var minDistance:Float;
	
	public function new(vr:VectorRenderer, camera:Camera)
	{
		_vr = vr;
		_camera = camera;
		
		_vTmp = new Vec2();
		
		//{<-- debug
		v0 = new Vec2();
		v1 = new Vec2();
		v2 = new Vec2();
		v3 = new Vec2();
		//}-->
	}
	
	public function init(shape1:AbstractShape, shape2:AbstractShape):Void {}
	
	public function free():Void {}
	
	public function collide(manifold:Manifold, shape1:AbstractShape, shape2:AbstractShape):Void
	{
		minDistance = 0;
		
		//{<-- debug
		iterations = 0;
		wedges = new Array<Array<Vec2>>();
		//}-->
		
		/*///////////////////////////////////////////////////////
		// PORTAL DISCOVERY
		///////////////////////////////////////////////////////*/
		
		//obtain a point that we know lies somewhere deep within B–A. we can obtain such a point by
		//subtracting any point deep within A from any point deep within B. the geometric centers of
		//A and B are excellent choices.
		
		//deep point inside B–A.
		var v0x = shape1.x - shape2.x;
		var v0y = shape1.y - shape2.y;
		if (Vec2Util.dot4(v0x, v0y, v0x, v0y) < Mathematics.EPS) v0x = Mathematics.EPS;
		
		_warmStart = false;
		if (_warmStart)
		{
			//recompute v1 and v2
			var v1x = s1a.x - s1b.x;
			var v1y = s1a.y - s1b.y;
			
			var v2x = s2a.x - s2b.x;
			var v2y = s2a.y - s2b.y;
			
			//{<-- debug
			wedges.push([new Vec2(v0x, v0y), new Vec2(v1x, v1y), new Vec2(v2x, v2y)]);
			//}-->
			
			//ray interior -> origin still passes through the portal?
			if (_winding == CW)
			{
				var nlx = v1x - v0x;
				var nly = v1y - v0x;
				var t = nly; nly = -nlx; nlx = t;
				nlx = -nlx;
				nly = -nly;
				
				var nrx = v2x - v0x;
				var nry = v2y - v0x;
				var t = nry; nry = -nrx; nrx = t;
				
				if (_winding == CW)
				{
					if (Vec2Util.dot4(nlx, nly, v1x, v1y) <= .0 && Vec2Util.dot4(nrx, nry, v2x, v2y) <= .0)
					{
						var nx = v1y - v0y;
						var ny =-v1x + v0x;
						if (Vec2Util.dot4(v0x, v0y, nx, ny) <= .0)
							_winding = CCW;
						else
						{
							_winding = CW;
							nx = -nx;
							ny = -ny;
						}
						if (Vec2Util.dot4(v1x, v1y, nx, ny) >= .0) return;
					}
					_warmStart = false;
				}
				else
				{
					if (Vec2Util.dot4(nlx, nly, v2x, v2y) <= .0 && Vec2Util.dot4(nrx, nry, v1x, v1y) <= .0)
					{
						var nx = v1y - v0y;
						var ny =-v1x + v0x;
						if (Vec2Util.dot4(v0x, v0y, nx, ny) <= .0)
							_winding = CCW;
						else
						{
							_winding = CW;
							nx = -nx;
							ny = -ny;
						}
						if (Vec2Util.dot4(v1x, v1y, nx, ny) >= .0) return;
					}
					_warmStart = false;
				}
			}
		}
		
		//we construct a normal that originates at the interior point and points towards the origin (-v0x, -v0y).
		//find the support point in the direction of this ray; we get the first support point.
		
		//find support with respect to direction (-v0x, -v0y)
		var node1 = shape1.BSPNode; while (node1.R != null) node1 = Vec2Util.perpDot4(node1.N.x, node1.N.y, v0x, v0y) <= 0. ? node1.R : node1.L;
		var node2 = shape2.BSPNode; while (node2.R != null) node2 = Vec2Util.perpDot4(node2.N.x, node2.N.y, v0x, v0y) >= 0. ? node2.R : node2.L;
		s1a = node1.V;
		s1b = node2.V;
		var v1x = node1.V.x - node2.V.x;
		var v1y = node1.V.y - node2.V.y;
		
		//{<-- debug
		v1.x = v1x;
		v1.y = v1y;
		//}-->
		
		//we construct a ray that is perpendicular to the line between the support just discovered (v1x, v1y)
		//and the interior point (v0x, v0y). there are two choices for this ray, one for each side of the line
		//segment. we choose the ray that lies on the same side of the segment as the origin.
		
		//perp(v1 - v0)
		var nx = v1y - v0y;
		var ny =-v1x + v0x;
		if (Vec2Util.dot4(v0x, v0y, nx, ny) <= .0)
			_winding = CCW;
		else
		{
			_winding = CW;
			nx = -nx;
			ny = -ny;
		}
		
		//we use this ray to find a second support point on the surface of B–A.
		//we get the second support point.
		//find support with respect to direction (nx, ny)
		node1 = shape1.BSPNode; while (node1.R != null) node1 = Vec2Util.perpDot4(node1.N.x, node1.N.y, nx, ny) >= 0. ? node1.R : node1.L;
		node2 = shape2.BSPNode; while (node2.R != null) node2 = Vec2Util.perpDot4(node2.N.x, node2.N.y, nx, ny) <= 0. ? node2.R : node2.L;
		s2a = node1.V;
		s2b = node2.V;
		var v2x = node1.V.x - node2.V.x;
		var v2y = node1.V.y - node2.V.y;
		
		//we now have three points (v0, v1, v2), which form an angle.
		//the origin lies somewhere within this angle. next we create a line segment between the two
		//support points. this line segment is called a portal, because the origin ray must pass
		//through the line segment on its way to the origin.
		
		//build outward pointing normal of the portal (v1-v2).
		if (_winding == CW)
		{
			//perp(v2 - v1)
			nx = v2y - v1y;
			ny =-v2x + v1x;
		}
		else
		{
			//-perp(v2 - v1)
			nx =-v2y + v1y;
			ny = v2x - v1x;
		}
		
		/*///////////////////////////////////////////////////////
		// PORTAL REFINEMENT
		///////////////////////////////////////////////////////*/
		
		var hit = false;
		
		while (true)
		{
			//{<-- debug
			wedges.push([new Vec2(v0x, v0y), new Vec2(v1x, v1y), new Vec2(v2x, v2y)]);
			de.polygonal.core.macro.Assert.assert(iterations++ < 100, "iterations++ < 100");
			//}-->
			
			//if the origin lies on the same side of the portal as the interior point, then it lies
			//within the triangle (v0, v1, v2), and must therefore lie within B–A.
			if (Vec2Util.dot4(v1x, v1y, nx, ny) >= .0)
			{
				//mark as hit
				manifold.pointCount = 1;
				hit = true;
			}
			
			//the point lies on the outside of the portal, so the algorithm continues...
			//we construct a normal perpendicular to the portal, pointing away from the interior.
			//we use this normal to obtain a third support point on the surface of B–A.
			node1 = shape1.BSPNode; while (node1.R != null) node1 = Vec2Util.perpDot4(node1.N.x, node1.N.y, nx, ny) >= 0. ? node1.R : node1.L;
			node2 = shape2.BSPNode; while (node2.R != null) node2 = Vec2Util.perpDot4(node2.N.x, node2.N.y, nx, ny) <= 0. ? node2.R : node2.L;
			s3a = node1.V;
			s3b = node2.V;
			var v3x = node1.V.x - node2.V.x;
			var v3y = node1.V.y - node2.V.y;
			
			//if the origin lies outside of the support line formed by the point and the normal,
			//we know that the origin lies outside of B–A.
			if (Vec2Util.dot4(v3x, v3y, nx, ny) < 0.)
			{
				//terminate with a miss if we don"t need the minimum distance, otherwise continue refinement
				manifold.pointCount = 0;
				hit = false;
			}
			
			//v3 is on or very close to the portal (v1, v2); terminate algorithm
			if (Mathematics.fabs(Vec2Util.dot4(v3x - v1x, v3y - v1y, nx, ny)) < Mathematics.EPS)
			{
				//{<-- 
				v0.x = v0x;
				v0.y = v0y;
				
				v1.x = v1x;
				v1.y = v1y;
				
				v2.x = v2x;
				v2.y = v2y;
				//}-->
				
				if (hit)
				{
					_warmStart = false;
					
					//compute collision normal and MTD vector
					if (true)
					{
						var len = Math.sqrt(nx * nx + ny * ny);
						nx /= len;
						ny /= len;
						var sep = Vec2Util.dot4(v1x, v1y, nx, ny);
						
						manifold.pointCount = 1;
						manifold.mp1.id = ContactID.NULL_VALUE;
						return;
					}
					else
					{
						//warmStart = false;
						manifold.pointCount = 1;
						manifold.mp1.id = ContactID.NULL_VALUE;
						return;
					}
				}
				else
				{
					minDistance = DistancePointSegment.find6(0, 0, v1x, v1y, v2x, v2y);
					//minDistance = ClosestPointSegment.find6(0, 0, v1x, v1y, v2x, v2y, _vTmp);
					//minDistance = Vec2.dot2(_vTmp, _vTmp);
					manifold.pointCount = 0;
					return;
				}
			}
			
			//the three support points form a triangle. we know the origin ray passes through the
			//interior edge of this triangle, because it is a portal. it therefore must exit through
			//one of the outer edges. to determine which edge it passes through, we construct a segment
			//between the new support point and the interior point. if the origin lies on one side of
			//the segment, the origin ray must pass through the outer edge that lies on the same side
			//of the segment. if the origin lies on the other side, the origin ray must pass through
			//the other outer edge.
			
			//true if origin left of ray v0->v3
			var isLeft = Vec2Util.perpDot4(v0x, v0y, v3x - v0x, v3y - v0y) < .0;
			
			//the outer edge that passes the test becomes the new portal, and we discard the unused support point.
			//current direction is CW
			if (_winding == CW)
			{
				if (isLeft)
				{
					//flip direction
					_winding = CCW;
					
					v2x = v1x;
					v2y = v1y;
					
					s2a = s1a;
					s2b = s1b;
					
					v1x = v3x;
					v1y = v3y;
					
					s1a = s3a;
					s1b = s3b;
					
					//new portal normal -perp(v2 - v1)
					nx =-v2y + v1y;
					ny = v2x - v1x;
				}
				else
				{
					//no change in winding
					v1x = v3x;
					v1y = v3y;
					
					s1a = s3a;
					s1b = s3b;
					
					//new portal normal perp(v2 - v1)
					nx = v2y - v1y;
					ny =-v2x + v1x;
				}
			}
			//current direction is CCW
			else
			{
				if (isLeft)
				{
					//no change in winding
					v1x = v3x;
					v1y = v3y;
					
					s1a = s3a;
					s1b = s3b;
					
					//new portal normal -perp(v2 - v1)
					nx =-v2y + v1y;
					ny = v2x - v1x;
				}
				else
				{
					//flip direction
					_winding = CW;
					
					v2x = v1x;
					v2y = v1y;
					
					s2a = s1a;
					s2b = s1b;
					
					v1x = v3x;
					v1y = v3y;
					
					s1a = s3a;
					s1b = s3b;
					
					//new portal normal perp(v2 - v1)
					nx = v2y - v1y;
					ny =-v2x + v1x;
				}
			}
		}
	}
}