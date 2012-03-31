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
package testbed.test.manifold;

import de.polygonal.core.fmt.Sprintf;
import de.polygonal.core.math.Mathematics;
import de.polygonal.core.math.Mean;
import de.polygonal.ds.Bits;
import de.polygonal.gl.Window;
import de.polygonal.motor.collision.shape.AbstractShape;
import de.polygonal.motor.data.RigidBodyData;
import de.polygonal.motor.data.ShapeData;
import de.polygonal.motor.dynamics.contact.Contact;
import de.polygonal.motor.dynamics.RigidBody;
import de.polygonal.core.math.Vec2;
import de.polygonal.motor.Settings;
import de.polygonal.motor.World;
import de.polygonal.ui.Key;
import de.polygonal.ui.UI;
import flash.Lib;
import flash.ui.Mouse;
import testbed.display.ConstraintRenderer;
import testbed.display.ManifoldRenderer;
import testbed.display.ShapeFeatureRenderer;
import testbed.display.ShapeRendererList;
import testbed.test.TestCase;

using de.polygonal.ds.Bits;
using de.polygonal.gl.color.ARGB;
using de.polygonal.ds.BitFlags;

class TestManifold extends TestCase
{
	inline static var DRAW_MANIFOLD          = Bits.BIT_01;
	inline static var DRAW_IDS               = Bits.BIT_02;
	inline static var DRAW_NORMALS           = Bits.BIT_03;
	inline static var DRAW_ORIGIN_CENTER     = Bits.BIT_04;
	inline static var DRAW_SHAPE_AXIS        = Bits.BIT_05;
	inline static var DRAW_SHAPE_WINDING     = Bits.BIT_06;
	inline static var DRAW_BOUNDING_BOX      = Bits.BIT_07;
	inline static var DRAW_BOUNDING_SPHERE   = Bits.BIT_08;
	inline static var DRAW_CONTACT_VECTORS   = Bits.BIT_09;
	inline static var DRAW_USER_DATA         = Bits.BIT_10;
	inline static var DRAW_GRID	             = Bits.BIT_11;
	inline static var DO_BENCHMARK           = Bits.BIT_12;
	inline static var DO_LOCK_CENTER         = Bits.BIT_13;
	inline static var DO_PAUSE               = Bits.BIT_14;
	inline static var DO_SNAP                = Bits.BIT_15;
	inline static var DO_TRANSLATE_OTHER     = Bits.BIT_16;
	inline static var DO_ROTATE_OTHER        = Bits.BIT_17;
	inline static var DO_PHYSICS             = Bits.BIT_18;
	inline static var DO_GRAVITY             = Bits.BIT_19;
	inline static var DO_CLOSEST_CONTAINMENT = Bits.BIT_20;
	inline static var DO_HIDE_MOUSE          = Bits.BIT_21;
	
	public static var ACTIVE_FLAGS = DRAW_MANIFOLD | DRAW_ORIGIN_CENTER | DO_GRAVITY;
	
	var _world:World;
	
	var _shape1:AbstractShape;
	var _shape2:AbstractShape;
	
	var _body1:RigidBody;
	var _body2:RigidBody;
	
	var _contact:Contact;
	
	var _shapeRenderer1:ShapeFeatureRenderer;
	var _shapeRenderer2:ShapeFeatureRenderer;
	var _manifoldRenderer:ManifoldRenderer;
	var _constraintRenderer:ConstraintRenderer;
	var _displayList:ShapeRendererList<ShapeFeatureRenderer>;
	
	var _mean:Mean;
	var _angleBeforeSimulation:Float;
	
	var _vTmp:Vec2;
	
	override function _init():Void
	{
		_bits = ACTIVE_FLAGS;
		
		var settings = new Settings();
		settings.worldBound = _getWorldBound();
		settings.maxProxies = 16;
		settings.maxPairs = 32;
		
		_world = new World(settings);
		
		//init first shape
		var bd = new RigidBodyData(0, 0, 0);
		var sd = _createShape1();
		sd.density = .1;
		bd.addShapeData(sd);
		
		_body1 = _world.createBody(bd);
		_shape1 = _body1.shape;
		_shape1.userData = "shape1";
		
		//init second shape
		bd.clearShapeDataList();
		bd.addShapeData(_createShape2());
		_body2 = _world.createBody(bd);
		_shape2 = _body2.shape;
		_shape2.userData = "shape2";
		
		_vTmp = new Vec2();
		
		//init contact
		_contact = _createContact(_shape1, _shape2);
		
		//init rendering
		_shapeRenderer1 = new ShapeFeatureRenderer(_shape1, _camera, _vr);
		_shapeRenderer2 = new ShapeFeatureRenderer(_shape2, _camera, _vr);
		_setupShapeRenderer(_shapeRenderer1);
		_setupShapeRenderer(_shapeRenderer2);
		_manifoldRenderer = new ManifoldRenderer(_contact, _camera, _vr);
		_setupManifoldRenderer(_manifoldRenderer);
		
		_displayList = new ShapeRendererList<ShapeFeatureRenderer>();
		_displayList.addRenderer(ShapeFeatureRenderer, _body1, _camera, _vr);
		_displayList.addRenderer(ShapeFeatureRenderer, _body2, _camera, _vr);
		
		_constraintRenderer = new ConstraintRenderer(_world, _displayList, _camera, _vr);
		_constraintRenderer.colorContactPointCold = 0xFF00FFFF.toARGB();
		_constraintRenderer.colorContactPointWarm = 0xFFFF8000.toARGB();
		_constraintRenderer.colorContactGraph     = 0x80FFFFFF.toARGB();
		_constraintRenderer.colorImpulse          = 0xFFFFFFFF.toARGB();
		_constraintRenderer.colorJoints           = 0xFFFF0011.toARGB();
		_constraintRenderer.contactPointSize      = 2;
		
		_mean = new Mean(30);
		
		//init menu
		var menuEntries = new Array<String>();
		menuEntries.push("F1\tmenu");
		menuEntries.push("F2\tdraw manifolds");
		menuEntries.push("F3\tdraw vertex/contact ids");
		menuEntries.push("F4\tdraw shape/contact normals");
		menuEntries.push("F5\tdraw shape/body origin/center");
		menuEntries.push("F6\tdraw shape axis");
		menuEntries.push("F7\tdraw shape winding");
		menuEntries.push("F8\tdraw bounding box");
		menuEntries.push("F9\tdraw bounding/sweep sphere");
		menuEntries.push("F11\tdraw contact vectors");
		menuEntries.push("F12\tdraw user data");
		menuEntries.push("g\tdraw grid");
		menuEntries.push("b\tbenchmark");
		menuEntries.push("l\tdo lock to center");
		menuEntries.push("f\tdo freeze");
		menuEntries.push("n\tdo snap to grid");
		menuEntries.push("t\tdo translate other shape");
		menuEntries.push("r\tdo rotate other shape");
		menuEntries.push("s\tdo simulation");
		menuEntries.push("y\tdo gravity");
		menuEntries.push("p\tdo closest point/inside test");
		menuEntries.push("h\tdo hide mouse");
		menuEntries.push("");
		menuEntries.push("mouse wheel (+shift): rotate shape fast (slow)");
		menuEntries.push("<- -> prev/next test");
		_initMenu(menuEntries, _bits);
		
		//custom init
		_initPairwise();
		
		//run initial update to prevent flickering from interpolation
		_tickInternal(0);
	}
	
	override function _free():Void
	{
		ACTIVE_FLAGS = _bits & (Bits.mask(10));
		
		_world.free();
		_constraintRenderer.free();
		_displayList.free();
		_mean.free();
		super._free();
	}
	
	override function _tickInternal(tick:Int):Void
	{
		if (hasf(DO_PAUSE | DO_BENCHMARK)) return;
		
		if (hasf(DO_PHYSICS))
		{
			//run physics
			_world.solve();
			_shapeRenderer1.update();
			_shapeRenderer2.update();
			return;
		}
		
		if (hasf(DO_LOCK_CENTER))
		{
			//check degenerate case
			var s = hasf(DO_TRANSLATE_OTHER) ? _shape2 : _shape1;
			s.body.transform(0., 0., s.body.angle);
		}
		else
		{
			if (!UI.get.isShiftDown && !hasf(DO_CLOSEST_CONTAINMENT))
			{
				//compute closest point & point containment
				_snap = hasf(DO_SNAP) ? .5 : 0.;
				var s = hasf(DO_TRANSLATE_OTHER) ? _shape2 : _shape1;
				var p = _getWorldMouse();
				s.body.transform(p.x, p.y, s.body.angle);
			}
		}
		
		//update shape position for rendering
		_shapeRenderer1.update();
		_shapeRenderer2.update();
		
		//compute contact manifold
		_contact.evaluate();
		
		//run custom tick hook
		_tick(tick);
	}
	
	override function _drawInternal(alpha:Float):Void
	{
		//run benchmark and skip rendering
		if (hasf(DO_BENCHMARK))
		{
			var now = flash.Lib.getTimer();
			for (j in 0...1000000)
			{
				_contact.evaluate();
			}
			_mean.add(flash.Lib.getTimer() - now);
			
			_vr.clearStroke();
			_vr.setFillColor(0xffffff, 1);
			_vr.fillStart();
			var s = Sprintf.format("%.1f ms (x1.000.000)", [_mean.val]);
			TestCase.getFont().getBound(s, 0, 0, false, true, _tmpAABB);
			TestCase.getFont().write(s, Window.bound().maxX - _tmpAABB.intervalX - 10, 22);
			_vr.fillEnd();
			return;
		}
		
		var isColliding = _contact.manifold.pointCount > 0;
		
		//render scene
		if (hasf(DRAW_GRID))
		{
			_drawGrid();
			_drawViewCenter();
		}
		
		_vr.setLineStyle(0xffffff, isColliding ? 1 : .5, 0);
		
		//don"t interpolate between frames if contact is drawn
		if (hasf(DRAW_MANIFOLD | DRAW_IDS | DRAW_CONTACT_VECTORS)) alpha = 1;
		
		_shapeRenderer1.render(alpha);
		_shapeRenderer2.render(alpha);
		
		if (hasf(DRAW_BOUNDING_SPHERE))
		{
			_shapeRenderer1.drawBoundingSphere(alpha);
			_shapeRenderer2.drawBoundingSphere(alpha);
		}
		if (hasf(DRAW_BOUNDING_BOX))
		{
			_shapeRenderer1.drawBoundingBox(alpha);
			_shapeRenderer2.drawBoundingBox(alpha);
		}
		if (hasf(DO_PHYSICS)) _constraintRenderer.drawContactPoints();
		if (hasf(DRAW_SHAPE_AXIS))
		{
			_shapeRenderer1.drawAxis(alpha);
			_shapeRenderer2.drawAxis(alpha);
		}
		if (hasf(DRAW_SHAPE_WINDING))
		{
			_shapeRenderer1.drawWinding(alpha);
			_shapeRenderer2.drawWinding(alpha);
		}
		if (hasf(DRAW_NORMALS))
		{
			_shapeRenderer1.drawNormalChain(alpha);
			_shapeRenderer2.drawNormalChain(alpha);
		}
		if (hasf(DRAW_MANIFOLD))
		{
			_manifoldRenderer.drawReferenceEdge();
			_manifoldRenderer.drawIncidentEdge();
		}
		if (!hasf(DO_PHYSICS))
		{
			_shapeRenderer1.drawVertexChain(alpha);
			_shapeRenderer2.drawVertexChain(alpha);
			
			if (hasf(DRAW_MANIFOLD))
				_manifoldRenderer.drawContactPoints();
		}
		if (hasf(DRAW_IDS))
		{
			_shapeRenderer1.drawVertexIds(alpha);
			_shapeRenderer2.drawVertexIds(alpha);
			_manifoldRenderer.drawContactIds();
		}
		if (hasf(DRAW_CONTACT_VECTORS))
		{
			_manifoldRenderer.drawContactVector();
		}
		if (hasf(DRAW_MANIFOLD) && !hasf(DO_PHYSICS))
		{
			_manifoldRenderer.drawContactNormals();
			_manifoldRenderer.drawIncidentVertex();
		}
		if (hasf(DRAW_ORIGIN_CENTER))
		{
			_shapeRenderer1.drawCenter(alpha);
			_shapeRenderer2.drawCenter(alpha);
		}
		if (hasf(DRAW_USER_DATA))
		{
			_shapeRenderer1.drawLabel(_shapeRenderer1.shape.userData, alpha);
			_shapeRenderer2.drawLabel(_shapeRenderer2.shape.userData, alpha);
		}
		if (hasf(DO_CLOSEST_CONTAINMENT))
		{
			var wm = _getWorldMouse();
			var isInside = _shape1.containsPoint(wm) || _shape2.containsPoint(wm);
			_vr.setLineStyle(isInside ? 0x00FF00 : 0xFFFF00, 1, 0);
			
			var wm = _getWorldMouse();
			var closestPoint = _shape1.closestPoint(wm, wm);
			_vr.crossSkewed2(_camera.toScreen(closestPoint, closestPoint), 10);
			
			var wm = _getWorldMouse();
			var closestPoint = _shape2.closestPoint(wm, wm);
			_vr.crossSkewed2(_camera.toScreen(closestPoint, closestPoint), 10);
		}
		
		//run custom rendering hook
		_draw(alpha);
	}
	
	override function _onKeyDown(keyCode:Int):Void
	{
		if (hasf(DO_BENCHMARK) && keyCode != Key.B) return;
		
		switch (keyCode)
		{
			case Key.F1 : _menu.toggleMenu();
			case Key.F2 : _menu.toggleMenuEntry( 1); invf(DRAW_MANIFOLD);
			case Key.F3 : _menu.toggleMenuEntry( 2); invf(DRAW_IDS);
			case Key.F4 : _menu.toggleMenuEntry( 3); invf(DRAW_NORMALS);
			case Key.F5 : _menu.toggleMenuEntry( 4); invf(DRAW_ORIGIN_CENTER);
			case Key.F6 : _menu.toggleMenuEntry( 5); invf(DRAW_SHAPE_AXIS);
			case Key.F7 : _menu.toggleMenuEntry( 6); invf(DRAW_SHAPE_WINDING);
			case Key.F8 : _menu.toggleMenuEntry( 7); invf(DRAW_BOUNDING_BOX);
			case Key.F9 : _menu.toggleMenuEntry( 8); invf(DRAW_BOUNDING_SPHERE);
			case Key.F11 : _menu.toggleMenuEntry( 9); invf(DRAW_CONTACT_VECTORS);
			case Key.F12 : _menu.toggleMenuEntry(10); invf(DRAW_USER_DATA);
			case Key.G : _menu.toggleMenuEntry(11); invf(DRAW_GRID);
			case Key.B : _menu.toggleMenuEntry(12); invf(DO_BENCHMARK); _mean = new Mean(100);
			case Key.L : _menu.toggleMenuEntry(13); invf(DO_LOCK_CENTER);
			case Key.F : _menu.toggleMenuEntry(14); invf(DO_PAUSE);
			case Key.N : _menu.toggleMenuEntry(15); invf(DO_SNAP);
			case Key.T : _menu.toggleMenuEntry(16); invf(DO_TRANSLATE_OTHER);
			case Key.R : _menu.toggleMenuEntry(17); invf(DO_ROTATE_OTHER);
			case Key.S : _menu.toggleMenuEntry(18); invf(DO_PHYSICS); _toggleSimulation();
			case Key.Y : _menu.toggleMenuEntry(19); invf(DO_GRAVITY); World.settings.gravity.y = hasf(DO_GRAVITY) ? 9.81 : 0;
			case Key.P : _menu.toggleMenuEntry(20); invf(DO_CLOSEST_CONTAINMENT);
			case Key.H : _menu.toggleMenuEntry(21); invf(DO_HIDE_MOUSE); hasf(DO_HIDE_MOUSE) ? Mouse.hide() : Mouse.show();
		}
	}
	
	override function _onMouseWheel(delta:Int):Void
	{
		if (hasf(DO_PHYSICS)) return;
		
		var s = hasf(DO_ROTATE_OTHER) ? _shape2 : _shape1;
		
		if (s.hasf(AbstractShape.AXIS_ALIGNED)) return;
		
		var angle = UI.instance().isShiftDown ? 1. : 5.;
		var p = s.body.origin;
		var a = Mathematics.wrapToPI(s.body.angle + ((angle * Mathematics.DEG_RAD) * Mathematics.sgn(delta)));
		s.body.transform(p.x, p.y, a);
	}
	
	function _toggleSimulation():Void
	{
		if (hasf(DO_PHYSICS))
			_angleBeforeSimulation = _body1.angle;
		else
		{
			_body1.clearForce();
			_body1.clearImpulse();
			
			_body2.clearForce();
			_body2.clearImpulse();
		}
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
	
	function _createShape1():ShapeData
	{
		throw "override for implementation";
		return null;
	}
	
	function _createShape2():ShapeData
	{
		throw "override for implementation";
		return null;
	}
	
	function _createContact(shape1:AbstractShape, shape2:AbstractShape):Contact
	{
		throw "override for implementation";
		return null;
	}
	
	function _initPairwise():Void {}
	
	function _tick(tick:Int):Void {}
	
	function _draw(alpha:Float):Void {}
}