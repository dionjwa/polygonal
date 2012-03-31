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
import de.polygonal.core.math.Mathematics;
import de.polygonal.core.math.Vec2Util;
import de.polygonal.ds.Bits;
import de.polygonal.gl.Window;
import de.polygonal.motor.collision.shape.AbstractShape;
import de.polygonal.motor.data.PolyData;
import de.polygonal.motor.data.RigidBodyData;
import de.polygonal.motor.geom.primitive.AABB2;
import de.polygonal.motor.Settings;
import de.polygonal.motor.World;
import de.polygonal.ui.Key;
import de.polygonal.ui.UI;
import testbed.display.ManifoldRenderer;
import testbed.display.ShapeFeatureRenderer;
import testbed.test.TestCase;

using de.polygonal.gl.color.ARGB;
using de.polygonal.ds.Bits;
using de.polygonal.ds.BitFlags;

class TestClip extends TestCase
{
	inline static var FREEZE_ACTIVE = Bits.BIT_01;
	inline static var DRAW_MANIFOLD = Bits.BIT_02;
	
	var _nullWorld:World;
	var _shape1:AbstractShape;
	var _shape2:AbstractShape;
	
	var _contact:CustomPolyContact;
	var _shapeRenderer1:ShapeFeatureRenderer;
	var _shapeRenderer2:ShapeFeatureRenderer;
	var _manifoldRenderer:ManifoldRenderer;
	
	override public function getName():String
	{
		return "contact point clipping";
	}
	
	override function _tickInternal(tick:Int):Void
	{
		if (!hasf(FREEZE_ACTIVE))
		{
			var p = _getWorldMouse();
			_shape2.body.transform(p.x, p.y, _shape2.body.angle);
		}
		
		_shapeRenderer1.update();
		_shapeRenderer2.update();
	}
	
	override function _drawInternal(alpha:Float):Void
	{
		_drawGrid();
		_drawViewCenter();
		
		_vr.setLineStyle(0xffffff, 1, 0);
		_shapeRenderer1.render(1);
		_shapeRenderer2.render(1);
		
		_shapeRenderer1.drawVertexChain(1);
		_shapeRenderer2.drawVertexChain(1);
		
		_shapeRenderer1.drawVertexIds(1);
		_shapeRenderer2.drawVertexIds(1);
		
		if (hasf(DRAW_MANIFOLD))
		{
			_manifoldRenderer.drawReferenceEdge();
			_manifoldRenderer.drawIncidentEdge();
			_manifoldRenderer.drawContactPoints();
			_manifoldRenderer.drawContactIds();
		}
		
		_contact.evaluate();
	}
	
	override function _onMouseWheel(delta:Int):Void
	{
		var angle = UI.get.isShiftDown ? 1 : 5;
		var p = _shape2.body.origin;
		var a = _shape2.body.angle + ((angle * Mathematics.DEG_RAD) * Mathematics.sgn(delta));
		_shape2.body.transform(p.x, p.y, a);
	}
	
	override function _onKeyDown(keyCode:Int):Void
	{
		switch (keyCode)
		{
			case Key.F1: _menu.toggleMenu();
			case Key.F2: invf(DRAW_MANIFOLD);
			case Key.F : _menu.toggleMenuEntry(2); invf(FREEZE_ACTIVE);
		}
	}
	
	override function _init():Void
	{
		var s = new Settings();
		s.worldBound = new AABB2(-1000, -1000, 1000, 1000);
		_nullWorld = new World(s);
		
		var bd = new RigidBodyData(0, 0);
		var sd = new PolyData(0);
		sd.setCircle(6, 2);
		//sd.setBox(10, .5);
		//sd.setCapsule(1 * 3, .25 * 3, .25 * 3, 3, 3);
		bd.addShapeData(sd);
		
		var body = _nullWorld.createBody(bd);
		_shape1 = body.shape;
		
		var bd = new RigidBodyData(0, 0);
		var sd = new PolyData(0);
		//sd.setCustom([0.863,-1.804,1.548,-1.266,1.753,-0.962,1.969,0.349,-0.560,1.920]);
		//sd.setRandomConvex(6, 2);
		//sd.setCustom([0.47047280309068207,-0.1692788869055923,0.49511333875133123,-0.06973364891147954,0.41231915921633566,0.2828301803965306,0.2058012278694522,0.4556817470641389,-0.08742527528045954,0.49229749262223127,-0.27078281861501247,0.42032923422349444]);
		//sd.setCustom([0.863,-1.804,1.548,-1.266,1.573,-1.236,1.753,-0.962,1.969,0.349,-0.560,1.920]);
		//sd.setCustom([0.983,-1.742, 1.477,-1.348, 1.955,-0.424, 1.986,-0.239, -1.016,+1.723, -1.613,+1.182]);
		//sd.setCustom([-1.743,-0.980, 0.961,-1.754, 1.799,-0.875, 1.816,-0.838, 1.467,1.360, -1.645,1.138]);
		
		var sd = new PolyData(0);
		sd.setCircle(6, 1.38495249049738045);
		//sd.setCapsule(1 * 3, .25 * 3, .25 * 3, 3, 3);
		//sd.r = Math.PI/5;
		bd.addShapeData(sd);
		
		var body = _nullWorld.createBody(bd);
		_shape2 = body.shape;
		
		_shapeRenderer1 = new ShapeFeatureRenderer(_shape1, _camera, _vr);
		_setupShapeRenderer(_shapeRenderer1);
		_shapeRenderer2 = new ShapeFeatureRenderer(_shape2, _camera, _vr);
		_setupShapeRenderer(_shapeRenderer2);
		
		_contact = new CustomPolyContact(_camera, _vr);
		_contact.init(_shape2, _shape1);
		
		_manifoldRenderer = new ManifoldRenderer(_contact, _camera, _vr);
		_setupManifoldRenderer(_manifoldRenderer);
		
		var menuEntries = new Array<String>();
		menuEntries.push("F1\tmenu");
		menuEntries.push("F2\tdraw manifolds");
		menuEntries.push("");
		menuEntries.push("left/right: prev/next test");
		_initMenu(menuEntries, _bits);
	}
	
	override function _free():Void
	{
		_nullWorld.free();
		_contact.free();
		super._free();
	}
	
	function _setupShapeRenderer(s:ShapeFeatureRenderer):Void
	{
		s.colorFirstVertex       = 0xfffeb301.toARGB();
		s.colorOtherVertex       = 0xffffff00.toARGB();
		s.colorNormalChain       = 0xff00ffff.toARGB();
		s.colorAxis_x            = 0xffff0000.toARGB();
		s.colorAxis_y            = 0xff00ff00.toARGB();
		s.colorVertexId          = 0xffffffff.toARGB();
		s.colorCenterA           = 0xffffffff.toARGB();
		s.colorCenterB           = 0xff000000.toARGB();
		s.colorWinding           = 0x80ffffff.toARGB();
		s.colorLabel             = 0xffffffff.toARGB();
		s.colorBoundingBox       = 0xff00ff00.toARGB();
		s.colorBoundingSphere    = 0xff00ff00.toARGB();
		s.colorOBB               = 0xff80ff00.toARGB();
		s.vertexChainPointSize   = 2;
		s.normalChainArrowLength = 12;
		s.centerRadius           = 3.5;
		s.vertexIdFontSize       = 8;
		s.labelFontSize          = 8;
		s.font                   = TestCase.getFont();
	}
	
	function _setupManifoldRenderer(m:ManifoldRenderer):Void
	{
		_manifoldRenderer.colorRefEdge          = 0xffff00ff.toARGB();
		_manifoldRenderer.colorIncEdge          = 0xff00ff00.toARGB();
		_manifoldRenderer.colorIncVert          = 0xfff44900.toARGB();
		_manifoldRenderer.colorContactId        = 0xffffffff.toARGB();
		_manifoldRenderer.colorContactPointFill = 0xff00ffff.toARGB();
		_manifoldRenderer.colorContactSep       = 0x8000ffff.toARGB();
		_manifoldRenderer.colorContactNormal    = 0xffffff00.toARGB();
		_manifoldRenderer.colorContactVector    = 0xffffff00.toARGB();
		_manifoldRenderer.incVertsSize          = 2;
		_manifoldRenderer.contactPointSize      = 2;
		_manifoldRenderer.contactIdFontSize     = 8;
		_manifoldRenderer.font                  = TestCase.getFont();
	}
}

import de.polygonal.motor.dynamics.contact.generator.ConvexContact;
import de.polygonal.gl.VectorRenderer;
import testbed.display.Camera;
import de.polygonal.motor.collision.pairwise.Collider;
import de.polygonal.motor.dynamics.contact.Manifold;
import de.polygonal.motor.collision.shape.feature.Vertex;
import de.polygonal.core.math.Vec2;
import de.polygonal.motor.Settings;
import de.polygonal.core.Root;
import de.polygonal.motor.dynamics.contact.ContactID;

class CustomPolyContact extends ConvexContact
{
	var _vr:VectorRenderer;
	var _camera:Camera;
	
	public function new(camera:Camera, vr:VectorRenderer)
	{
		_camera = camera;
		_vr = vr;
		super(new Settings());
	}

	override function _getCollider():Collider
	{
		return new CollideConvex(_settings, shape1, shape2, _camera, _vr);
	}
}

class CollideConvex implements Collider
{
	var _vr:VectorRenderer;
	var _camera:Camera;
	var _settings:Settings;
	
	public function new(settings:Settings, shape1:AbstractShape, shape2:AbstractShape, camera:Camera, vr:VectorRenderer)
	{
		_settings = settings;
		_camera = camera;
		_vr = vr;
	}
	
	public function free():Void {}
	
	public function init(shape1:AbstractShape, shape:AbstractShape):Void {}
	
	public function collide(manifold:Manifold, s1:AbstractShape, s2:AbstractShape):Void
	{
		s1.syncFeatures();
		s2.syncFeatures();
		
		var sep1 = Mathematics.NEGATIVE_INFINITY;
		var refEdgeNormal1 = null;
		var refEdgeVertex1 = null;
		var supportVertex1 = null;
		
		var sep2 = Mathematics.NEGATIVE_INFINITY;
		var refEdgeNormal2 = null;
		var refEdgeVertex2 = null;
		var supportVertex2 = null;
		
		var flip = 0;
		manifold.pointCount = 0;
		
		var p = s1.worldVertexChain;
		var d = s1.worldNormalChain;
		while (true)
		{
			var dx = d.x;
			var dy = d.y;
			var s = supportBSPQuery(s2, dx, dy);
			var depth = separation(p, dx, dy, s);
			if (depth > 0) return;
			if (depth > sep1)
			{
				sep1 = depth;
				refEdgeNormal1 = d;
				refEdgeVertex1 = p;
				supportVertex1 = s;
			}
			if (p.tail) break;
			p = p.next;
			d = d.next;
		}
		
		p = s2.worldVertexChain;
		d = s2.worldNormalChain;
		while (true)
		{
			var dx = d.x;
			var dy = d.y;
			var s = supportBSPQuery(s1, dx, dy);
			var depth = separation(p, dx, dy, s);
			if (depth > 0) return;
			if (depth > sep2)
			{
				sep2 = depth;
				refEdgeNormal2 = d;
				refEdgeVertex2 = p;
				supportVertex2 = s;
			}
			
			if (p.tail) break;
			p = p.next;
			d = d.next;
		}
		
		if (sep2 > (_settings.relTolerance * sep1) + _settings.absTolerance)
			CustomClipContactPoints.clip(manifold, s1, s2, 1, refEdgeVertex2, supportVertex2, refEdgeNormal2, _camera, _vr);
		else
			CustomClipContactPoints.clip(manifold, s1, s2, 0, refEdgeVertex1, supportVertex1, refEdgeNormal1, _camera, _vr);
	}
	
	static function supportBSPQuery(shape:AbstractShape, dx:Float, dy:Float):Vertex
	{
		var node = shape.BSPNode;
		while (node.R != null) node = Vec2Util.perpDot4(node.N.x, node.N.y, dx, dy) <= 0 ? node.R : node.L;
		return node.V;
	}
	
	static function separation(p:Vertex, dx:Float, dy:Float, s:Vertex):Float
	{
		return dx * (s.x - p.x) + dy * (s.y - p.y);
	}
}

class CustomClipContactPoints
{
	public static function clip(manifold:Manifold, s1:AbstractShape, s2:AbstractShape, flip:Int, refEdgeVert:Vertex, supportVert:Vertex, refEdgeNormal:Vertex, camera:Camera, vr:VectorRenderer):Void
	{
		var refShape = flip == 1 ? s2 : s1;
		var x = refShape.x;
		var y = refShape.y;
		var nx = refEdgeNormal.x;
		var ny = refEdgeNormal.y;
		var incEdgeVert;
		var incEdgeIndex;
		var incEdgeNormal = supportVert.edge.normal;
		
		//{<-- draw support vertex & normal
		vr.setFillColor(0xFFFF00, 1);
		vr.fillStart();
		vr.box2(camera.toScreen(supportVert, new Vec2()), 2);
		vr.fillEnd();
		vr.setLineStyle(0xFFFF00, 1, 0);
		vr.arrowRay4(camera.toScreen(supportVert, new Vec2()), incEdgeNormal, 20, 4);
		//}-->
		
		//{<-- draw previous/next normal
		vr.setLineStyle(0xFF8080, 1, 0);
		vr.arrowRay4(camera.toScreen(supportVert.prev, new Vec2()), incEdgeNormal.prev, 20, 4);
		vr.setLineStyle(0xFF8080, 1, 0);
		vr.arrowRay4(camera.toScreen(supportVert.next, new Vec2()), incEdgeNormal.next, 20, 4);
		//}-->
		
		//{<-- find best incident edge
		var matchPrev = Vec2Util.dot4(incEdgeNormal.prev.x, incEdgeNormal.prev.y, nx, ny);
		var matchCurr = Vec2Util.dot4(incEdgeNormal.x, incEdgeNormal.y, nx, ny);
		
		//right/acute angle or previous vertex normal is more parallel to reference edge?
		if (matchCurr >= 0 || matchPrev < matchCurr)
		{
			//pick previous vertex
			incEdgeVert = supportVert.prev;
			incEdgeIndex = incEdgeNormal.prev.i;
		}
		else
		{
			//stick with current vertex
			incEdgeVert = supportVert;
			incEdgeIndex = incEdgeNormal.i;
		}
		
		var incVertIndex1 = incEdgeVert.i;
		var incVertIndex2 = incVertIndex1;
		//}-->
		
		//{<-- draw incident edge
		vr.setLineStyle(0xFFFF00, 1, 0);
		vr.arrowLine3(camera.toScreen(incEdgeVert, new Vec2()), camera.toScreen(incEdgeVert.next, new Vec2()), 4);
		//}-->
		
		//{<-- setup front&side clipping planes
		//front
		#if debug
		var height = refEdgeVert.edge.height;
		var t = ((refEdgeVert.x - x) * nx + (refEdgeVert.y - y) * ny);
		de.polygonal.core.macro.Assert.assert(Math.abs(height - t) < .001, "Math.abs(height - t) < .001");
		#end
		var front = Vec2Util.dot4(x, y, nx, ny) + ((refEdgeVert.x - x) * nx + (refEdgeVert.y - y) * ny);
		//var front = Vec2Util.dot4(x, y, nx, ny) + refEdgeVert.edge.height;
		
		//side
		var edgeExt = refEdgeVert.edge.extent;
		var offs = refEdgeVert.edge.offset;
		offs = new Vec2();
		var M = refShape.TBody;
		var side = Vec2Util.perpDot4
		(
			nx, ny,
			x + M.mul22x(offs.x, offs.y),
			y + M.mul22y(offs.x, offs.y)
		);
		
		//var cx = refEdgeVert.x + (refEdgeVert.next.x - refEdgeVert.x) / 2;
		//var cy = refEdgeVert.y + (refEdgeVert.next.y - refEdgeVert.y) / 2;
		//var h = (cx - x) * nx + (cy - y) * ny;
		//var offset = new Vec2((cx - x) - (nx * h), (cy - y) - (ny * h));
		//var side = Vec2Util.perpDot4(nx, ny, x, y);
		//if (!refShape.hasf(AbstractShape.SYMMETRIC))
		//{
			//side += Vec2Util.perpDot4(nx, ny, M.mul22x(offs.x, offs.y), M.mul22y(offs.x, offs.y));
		//}
		//}-->
		
		//{<-- draw front clipping plane
		var pointOnPlane = new Vec2(refEdgeNormal.x * front, refEdgeNormal.y * front);
		var pointOnPlaneScreen = camera.toScreen(pointOnPlane, new Vec2());
		vr.setLineStyle(0x0080FF, .6, 0);
		vr.planeThroughPoint5(pointOnPlaneScreen, refEdgeNormal, Window.bound(), 20, 4);
		//}-->
		
		//{<-- draw left/right side clipping planes
		var sideNormal = refEdgeNormal.clone();
		sideNormal.perp();
		sideNormal.x = -sideNormal.x;
		sideNormal.y = -sideNormal.y;
		
		pointOnPlane.x = sideNormal.x * (-side + edgeExt);
		pointOnPlane.y = sideNormal.y * (-side + edgeExt);
		var pointOnPlaneScreen = camera.toScreen(pointOnPlane, new Vec2());
		vr.planeThroughPoint5(pointOnPlaneScreen, sideNormal, Window.bound(), 20, 4);
		
		var sideNormal = refEdgeNormal.clone();
		sideNormal.perp();
		
		pointOnPlane.x = sideNormal.x * (side + edgeExt);
		pointOnPlane.y = sideNormal.y * (side + edgeExt);
		
		var pointOnPlaneScreen = camera.toScreen(pointOnPlane, new Vec2());
		vr.planeThroughPoint5(pointOnPlaneScreen, sideNormal, Window.bound(), 20, 4);
		//}-->
		
		//{clip edge against reference face side planes
		
		//vertices of incident edge
		var x1 = incEdgeVert.x, x2 = incEdgeVert.next.x;
		var y1 = incEdgeVert.y, y2 = incEdgeVert.next.y;
		
		//clip points of incident edge
		var cv1x = x1, cv2x = x2;
		var cv1y = y1, cv2y = y2;
		
		//distance of both points to left side plane
		var dist1 = Vec2Util.perpDot4(x1, y1, nx, ny) + side - edgeExt;
		var dist2 = Vec2Util.perpDot4(x2, y2, nx, ny) + side - edgeExt;
		
		//points on different side of left side plane ?
		//due to clockwise ordering, support vertex x1,y1 is always closer to the right side plane
		if (dist1 * dist2 < 0)
		{
			//which one is in the negative half-space?
			var interp = dist1 / (dist1 - dist2);
			
			#if debug
			de.polygonal.core.macro.Assert.assert(dist1 < 0, "dist1 < 0");
			#end
			
			//clip second point against left side plane
			cv2x = x1 + interp * (x2 - x1);
			cv2y = y1 + interp * (y2 - y1);
			
			incVertIndex2 = incEdgeVert.next.i;
			
			//first point in positive half-space of right side plane?
			dist1 = Vec2Util.perpDot4(x1, y1, -nx, -ny) - side - edgeExt;
			
			if (dist1 > 0)
			{
				//clip first point against right side plane
				dist2 = Vec2Util.perpDot4(x2, y2, -nx, -ny) - side - edgeExt;
				
				interp = dist1 / (dist1 - dist2);
				cv1x = x1 + interp * (x2 - x1);
				cv1y = y1 + interp * (y2 - y1);
				
				incVertIndex1 = incEdgeVert.prev.i;
			}
		}
		else
		{
			//both points in negative half-space of left side plane
			if (dist1 < 0)
			{
				#if debug
				de.polygonal.core.macro.Assert.assert(dist1 < dist2, "dist1 < dist2");
				#end
				
				//on different sides of right side plane?
				var t = -side - edgeExt;
				dist1 = Vec2Util.perpDot4(x1, y1, -nx, -ny) + t;
				dist2 = Vec2Util.perpDot4(x2, y2, -nx, -ny) + t;
				
				if (dist1 * dist2 < 0)
				{
					//clip first point against right side plane
					var interp = dist1 / (dist1 - dist2);
					cv1x = cv1x + interp * (cv2x - cv1x);
					cv1y = cv1y + interp * (cv2y - cv1y);
					
					incVertIndex1 = incEdgeVert.prev.i;
				}
			}
			else
			{
				//both points in positive half-space of left side plane
				return;
			}
		}
		//}
		
		vr.clearStroke();
		
		//{output contact points
		//check if first clip point lies behind reference edge
		//two potential contact points
		var sep = Vec2Util.dot4(nx, ny, cv1x, cv1y) - front;
		if (sep <= 0)
		{
			if (flip == 1)
			{
				manifold.ncoll.x =-nx;
				manifold.ncoll.y =-ny;
			}
			else
			{
				manifold.ncoll.x = nx;
				manifold.ncoll.y = ny;
			}
			
			var contactId = ContactID.bake(refEdgeVert.i, incEdgeIndex, 0, flip);
			
			//output first contact point
			var cp = manifold.mp1;
			cp.sep = sep;
			cp.x   = cv1x;
			cp.y   = cv1y;
			cp.id  = ContactID.setIncVert(contactId, incVertIndex1);
			s1.TBody.mulT(cp, cp.lp1);
			s2.TBody.mulT(cp, cp.lp2);
			
			//{<-- draw contact point
			vr.setFillColor(0x00FF00, 1);
			vr.fillStart();
			vr.box2(camera.toScreen(new Vec2(cv1x, cv1y), new Vec2()), 2);
			vr.fillEnd();
			//}-->
			
			//second clip point behind reference edge?
			sep = Vec2Util.dot4(nx, ny, cv2x, cv2y) - front;
			if (sep <= 0)
			{
				//output second contact point
				cp     = manifold.mp2;
				cp.sep = sep;
				cp.x   = cv2x;
				cp.y   = cv2y;
				cp.id  = ContactID.setIncVert(contactId, incVertIndex2);
				s1.TBody.mulT(cp, cp.lp1);
				s2.TBody.mulT(cp, cp.lp2);
				
				//{<-- draw contact point
				vr.setFillColor(0x00FF00, 1);
				vr.fillStart();
				vr.box2(camera.toScreen(new Vec2(cv2x, cv2y), new Vec2()), 2);
				vr.fillEnd();
				//}-->
				
				manifold.pointCount = 2;
			}
			else
				manifold.pointCount = 1;
		}
		else
		{
			//check if second clip point lies behind reference edge
			//(one potential contact point only)
			sep = Vec2Util.dot4(nx, ny, cv2x, cv2y) - front;
			if (sep <= 0)
			{
				if (flip == 1)
				{
					manifold.ncoll.x =-nx;
					manifold.ncoll.y =-ny;
				}
				else
				{
					manifold.ncoll.x = nx;
					manifold.ncoll.y = ny;
				}
				
				//output contact manifold
				var cp = manifold.mp1;
				cp.sep = sep;
				cp.x   = cv2x;
				cp.y   = cv2y;
				cp.id  = ContactID.bake(refEdgeVert.i, incEdgeIndex, incVertIndex1, flip);
				s1.TBody.mulT(cp, cp.lp1);
				s2.TBody.mulT(cp, cp.lp2);
				
				//{<-- draw contact point
				vr.setFillColor(0x00FF00, 1);
				vr.fillStart();
				vr.box2(camera.toScreen(new Vec2(cv2x, cv2y), new Vec2()), 2);
				vr.fillEnd();
				//}-->
				
				manifold.pointCount = 1;
			}
			else
				manifold.pointCount = 0;
		}
		//}
	}
}