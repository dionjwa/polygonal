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
package testbed.test.world;

import de.polygonal.core.event.IObservable;
import de.polygonal.core.fmt.Sprintf;
import de.polygonal.core.math.Mathematics;
import de.polygonal.core.time.StopWatch;
import de.polygonal.core.time.TimebaseEvent;
import de.polygonal.ds.Bits;
import de.polygonal.gl.color.ColorConversion;
import de.polygonal.gl.color.HSV;
import de.polygonal.gl.color.RGB;
import de.polygonal.motor.collision.nbody.SAP;
import de.polygonal.motor.data.BoxData;
import de.polygonal.motor.data.CircleData;
import de.polygonal.motor.data.EdgeData;
import de.polygonal.motor.data.PolyData;
import de.polygonal.motor.data.RigidBodyData;
import de.polygonal.motor.data.ShapeData;
import de.polygonal.motor.dynamics.RigidBody;
import de.polygonal.core.math.Vec2;
import de.polygonal.motor.Settings;
import de.polygonal.motor.World;
import de.polygonal.motor.WorldEvent;
import de.polygonal.ui.Key;
import testbed.display.ConstraintRenderer;
import testbed.display.ShapeFeatureRenderer;
import testbed.display.ShapeRenderer;
import testbed.display.ShapeRendererList;
import testbed.test.TestCase;

using de.polygonal.gl.color.ARGB;
using de.polygonal.ds.BitFlags;

class TestWorld extends TestCase
{
	inline public static var DRAW_BOUNDING_BOX    = Bits.BIT_01;
	inline public static var DRAW_BOUNDING_SPHERE = Bits.BIT_02;
	inline public static var DRAW_CONTACT_POINTS  = Bits.BIT_03;
	inline public static var DRAW_CONTACT_GRAPH   = Bits.BIT_04;
	inline public static var DRAW_JOINTS          = Bits.BIT_05;
	inline public static var DRAW_USER_DATA       = Bits.BIT_06;
	inline public static var DRAW_STACK_ANALYSIS  = Bits.BIT_07;
	inline public static var DRAW_GRID            = Bits.BIT_08;
	inline public static var DO_PAUSE             = Bits.BIT_09;
	inline public static var DO_SLEEP             = Bits.BIT_10;
	inline public static var DO_WARM_START        = Bits.BIT_11;
	inline public static var DO_RENDER            = Bits.BIT_12;
	inline public static var DO_PROFILE           = Bits.BIT_13;
	
	public static var ACTIVE_FLAGS = DO_RENDER | DO_WARM_START | DO_SLEEP;
	
	public static var VELOCITY_ITERATIONS = 15;
	public static var POSITION_ITERATIONS = 10;
	
	var _world:World;
	var _displayList:ShapeRendererList<ShapeFeatureRenderer>;
	var _constraintRenderer:ConstraintRenderer;
	
	public function new()
	{
		super();
	}
	
	override public function update(type:Int, source:IObservable, userData:Dynamic):Void
	{
		if (hasf(DO_PAUSE))
		{
			if (type == TimebaseEvent.TICK || type == TimebaseEvent.RENDER)
				return;
		}
		
		super.update(type, source, userData);
		
		switch (type)
		{
			case WorldEvent.BODY_DESTROYED:
				trace(Sprintf.format("body '%s' destroyed", [userData.userData]));
			
			case WorldEvent.BODY_ESCAPED:
				trace(Sprintf.format("body '%s' escaped", [userData.userData]));
			
			case WorldEvent.SHAPE_DESTROYED:
				trace(Sprintf.format("shape '%s' destroyed", [userData.userData]));
		}
	}
	
	function _initWorld():Void
	{
	}
	
	function _tick(tick:Int):Void
	{
	}
	
	function _draw(alpha:Float):Void
	{
	}
	
	override function _init():Void
	{
		_bits = ACTIVE_FLAGS; //restore flags from previous test
		setf(TestCase.DO_PAN | TestCase.DO_ZOOM);
		
		var settings                = new Settings();
		settings.maxProxies         = 512;
		settings.maxPairs           = 512 << 2;
		settings.worldBound        = _getWorldBound();
		settings.worldBound        = _getWorldBound();
		settings.doWarmStart        = hasf(DO_WARM_START);
		settings.doSleep            = hasf(DO_SLEEP);
		settings.velocityIterations = VELOCITY_ITERATIONS;
		settings.positionIterations = POSITION_ITERATIONS;
		settings.doProfile          = hasf(DO_PROFILE);
		
		_world = new World(settings);
		_world.setBroadPhase(SAP);
		_world.attach(this);
		
		_displayList = new ShapeRendererList();
		
		_constraintRenderer                       = new ConstraintRenderer(_world, _displayList, _camera, _vr);
		_constraintRenderer.colorContactPointCold = 0xff00FFFF.toARGB();
		_constraintRenderer.colorContactPointWarm = 0xffFF0000.toARGB();
		_constraintRenderer.colorContactGraph     = 0x80FFFFFF.toARGB();
		_constraintRenderer.colorImpulse          = 0xFFFFFFFF.toARGB();
		_constraintRenderer.colorJoints           = 0xFFFF0011.toARGB();
		_constraintRenderer.contactPointSize      = 2;
		
		var menuEntries = new Array<String>();
		menuEntries.push("F1\tmenu");
		menuEntries.push("F2\tdraw bounding box");
		menuEntries.push("F3\tdraw bounding sphere (sweep)");
		menuEntries.push("F4\tdraw contact points");
		menuEntries.push("F5\tdraw contact graph");
		menuEntries.push("F6\tdraw joints");
		menuEntries.push("F7\tdraw user data");
		menuEntries.push("F8\tdraw stack analysis");
		menuEntries.push("g\tdraw grid");
		menuEntries.push("p\tpause simulation");
		menuEntries.push("s\tdo sleep");
		menuEntries.push("w\tdo warm starting");
		menuEntries.push("r\tdo rendering");
		menuEntries.push("f\tdo profiling");
		menuEntries.push("x\tdo simulation step");
		menuEntries.push("u\tdo wake up islands");
		menuEntries.push("d\tdestroy shape under mouse");
		menuEntries.push("b\tdestroy body under mouse");
		menuEntries.push("");
		menuEntries.push("mouse(wheel)+space: pan(zoom) viewport");
		menuEntries.push("<- -> prev/next test");
		
		_initMenu(menuEntries, _bits);
		_initWorld();
	}
	
	override function _free():Void
	{
		ACTIVE_FLAGS = _bits; //remember active flags
		
		_displayList.free();
		_world.free();
		_constraintRenderer.free();
		super._free();
	}
	
	override function _onKeyDown(keyCode:Int):Void
	{
		switch (keyCode)
		{
			case Key.F1: _menu.toggleMenu();
			case Key.F2: _menu.toggleMenuEntry( 1); invf(DRAW_BOUNDING_BOX);
			case Key.F3: _menu.toggleMenuEntry( 2); invf(DRAW_BOUNDING_SPHERE);
			case Key.F4: _menu.toggleMenuEntry( 3); invf(DRAW_CONTACT_POINTS);
			case Key.F5: _menu.toggleMenuEntry( 4); invf(DRAW_CONTACT_GRAPH);
			case Key.F6: _menu.toggleMenuEntry( 5); invf(DRAW_JOINTS);
			case Key.F7: _menu.toggleMenuEntry( 6); invf(DRAW_USER_DATA);
			case Key.F8: _menu.toggleMenuEntry( 7); invf(DRAW_STACK_ANALYSIS); World.settings.computeStackLayer = hasf(DRAW_STACK_ANALYSIS);
			case Key.G : _menu.toggleMenuEntry( 8); invf(DRAW_GRID);
			case Key.P : _menu.toggleMenuEntry( 9); invf(DO_PAUSE);
			case Key.S : _menu.toggleMenuEntry(10); invf(DO_SLEEP); World.settings.doSleep = hasf(DO_SLEEP);
			case Key.W : _menu.toggleMenuEntry(11); invf(DO_WARM_START); World.settings.doWarmStart = hasf(DO_WARM_START);
			case Key.R : _menu.toggleMenuEntry(12); invf(DO_RENDER);
			case Key.F : _menu.toggleMenuEntry(13); invf(DO_PROFILE); World.settings.doProfile = !World.settings.doProfile;
			case Key.X : if (!hasf(DO_PAUSE)) { _onKeyDown(Key.P); } _singleStep();
			case Key.U : for (b in _world.bodyList) b.wakeUp();
			case Key.D : _destroyShape(); 
			case Key.B : _destroyBody();
		}
	}
	
	override function _tickInternal(tick:Int):Void
	{
		_world.solve();
		
		//run custom update hook
		_tick(tick);
		
		for (r in _displayList) r.update();
	}
	
	override function _drawInternal(alpha:Float):Void
	{
		if (hasf(DO_PROFILE))
		{
			var settings = World.settings;
			var shapeCount = 0;
			for (b in _world.bodyList) shapeCount += b.shapeList.size();
			
			var formatStr = "";
			formatStr += "shapes\t%d\n";
			formatStr += "bodies\t%d\n";
			formatStr += "joints\t%d\n";
			formatStr += "contacts\t%d\n";
			formatStr += "islands\t%d\n";
			formatStr += "vel-iter\t%d\n";
			formatStr += "pos-iter\t%d\n\n";
			formatStr += "timings (ms)\n";
			
			var formatArg = new Array<Dynamic>();
			formatArg[0] = shapeCount;
			formatArg[1] = _world.bodyList.size();
			formatArg[2] = _world.jointList.size();
			formatArg[3] = _world.contactList.size();
			formatArg[4] = _world.numSolvedIsland;
			formatArg[5] = settings.velocityIterations;
			formatArg[6] = settings.positionIterations;
			
			var tabSize = TestCase.getFont().tabSize;
			TestCase.getFont().tabSize = 15;
			
			_vr.setFillColor(0xFFFFFF, 1);
			_vr.fillStart();
			TestCase.getFont().write(Sprintf.format(formatStr, formatArg), 1, 400, false, _tmpAABB, true);
			_vr.fillEnd();
			
			var colors = [0xFFFF00, 0x00FFFF, 0xFF00FF];
			
			formatStr = "broad\t%.2f\n";
			formatArg[0] = StopWatch.query(settings.profileIdBroadPhase);
			
			_vr.setFillColor(colors[0], 1);
			_vr.fillStart();
			TestCase.getFont().write(Sprintf.format(formatStr, formatArg), 1, _tmpAABB.maxY, false, _tmpAABB, true);
			_vr.fillEnd();
			
			formatStr = "narrow\t%.2f\n";
			formatArg[0] = StopWatch.query(settings.profileIdNarrowPhase);
			_vr.setFillColor(colors[1], 1);
			_vr.fillStart();
			TestCase.getFont().write(Sprintf.format(formatStr, formatArg), 1, _tmpAABB.maxY, false, _tmpAABB, true);
			_vr.fillEnd();
			
			formatStr = "solver\t%.2f\n";
			formatArg[0] = StopWatch.query(settings.profileIdSolver);
			_vr.setFillColor(colors[2], 1);
			_vr.fillStart();
			TestCase.getFont().write(Sprintf.format(formatStr, formatArg), 1, _tmpAABB.maxY, false, _tmpAABB, true);
			_vr.fillEnd();
			
			TestCase.getFont().tabSize = tabSize;
			
			_drawTimings(1, 550, 100, 2, colors);
		}
		
		if (!hasf(DO_RENDER)) return;
		
		var dynamicAndAwakeBodiesColor = 0xffffff;
		var dynamicAndAwakeBodiesAlpha = 1;
		var dynamicAndAwakeBodiesThick = 0;
		
		var staticBodiesColor = 0x8ef0b5;
		var staticBodiesAlpha = .9;
		var staticBodiesThick = 1;
		
		var dynamicAndSleepingBodiesColor = 0x5172bc;
		var dynamicAndSleepingBodiesAlpha = .5;
		
		if (hasf(DRAW_GRID))
		{
			_drawViewCenter();
			_drawGrid();
		}
		
		//render dynamic & awake bodies
		if (hasf(DRAW_STACK_ANALYSIS))
		{
			//draw body stack heights from stack analysis
			var hmax = World.settings.maxStackLayerCount;
			var colors = new Array<Int>();
			var rgb = new RGB();
			var hsv = new HSV(0, 1, 1);
			for (hue in 0...hmax)
			{
				hsv.h = hue * (360 / hmax);
				colors[hue] = ColorConversion.HSVtoRGB(hsv, rgb).get24();
			}
			
			var tmp = new Array<Array<ShapeRenderer>>();
			for (r in _displayList)
			{
				if (r.body.isSleeping || r.body.isStatic) continue;
				
				if (tmp[r.body.stackHeight] == null)
					tmp[r.body.stackHeight] = new Array();
				tmp[r.body.stackHeight].push(r);
			}
			for (i in 0...tmp.length)
			{
				if (tmp[i] == null) continue;
				if (tmp[i].length == 0) continue;
				
				_vr.style.setFillColor(colors[i], 1);
				_vr.fillStart();
				for (r in tmp[i]) r.render(alpha);
				_vr.fillEnd();
			}
			for (r in _displayList)
			{
				if (r.body.isSleeping) continue;
				r.drawLabel(Std.string(r.body.stackHeight), alpha);
			}
		}
		else
		{
			_vr.setLineStyle(dynamicAndAwakeBodiesColor, dynamicAndAwakeBodiesAlpha, dynamicAndAwakeBodiesThick);
			for (r in _displayList)
				if (!r.body.isSleeping && !r.body.isStatic)
					r.render(alpha);
		}
		
		//render static bodies
		_vr.setLineStyle(staticBodiesColor, staticBodiesAlpha, staticBodiesThick);
		for (r in _displayList)
			if (r.body.isStatic)
				r.render(alpha);
		
		//render sleeping bodies (excluding static bodies)
		_vr.setFillColor(dynamicAndSleepingBodiesColor, dynamicAndSleepingBodiesAlpha);
		_vr.fillStart();
		for (r in _displayList)
			if (r.body.isSleeping && !r.body.isStatic)
				r.render(alpha);
		_vr.fillEnd();
		
		if (hasf(DRAW_BOUNDING_BOX))
			for (r in _displayList)
				r.drawBoundingBox(alpha);
		
		if (hasf(DRAW_BOUNDING_SPHERE))
		{
			for (r in _displayList)
			{
				if (!r.body.isSleeping)
				{
					r.drawBoundingSphere(alpha);
					r.drawCenter(alpha);
				}
			}
		}
		
		if (hasf(DRAW_USER_DATA))
		{
			for (r in _displayList)
			{
				var data = r.shape.userData;
				if (data == null) data = r.body.userData;
				r.drawLabel(data, alpha);
			}
		}
		
		if (hasf(DRAW_CONTACT_POINTS))
			_constraintRenderer.drawContactPoints();
		
		if (hasf(DRAW_CONTACT_GRAPH))
			_constraintRenderer.drawContactGraph();
		
		if (hasf(DRAW_JOINTS))
			_constraintRenderer.drawJoints();
		
		//run custom render hook
		_draw(alpha);
	}
	
	function _drawTimings(x:Float, y:Float, w:Float, h:Float, colors:Array<Int>)
	{
		_vr.clearStroke();
		
		var total = StopWatch.total();
		var r = total > .001 ? (w / total) : 0;
		var j = 0;
		for (i in 0...3)
		{
			var v = StopWatch.query(i);
			if (v > 0)
			{
				var p = r * v;
				if (p != 0)
				{
					_vr.setFillColor(colors[j], 1);
					_vr.fillStart();
					_vr.aabbMinMax4(x, y, x + p, y + h);
					_vr.fillEnd();
					x += p;
				}
			}
			j++;
		}
	}
	
	function _singleStep():Void
	{
		clrf(DO_PAUSE);
		_tickInternal(0);
		_drawInternal(1);
		setf(DO_PAUSE);
		
		_vr.flush(_canvas.graphics);
	}
	
	function _destroyBody():Void
	{
		for (body in _world.bodyList)
		{
			var destroy = false;
			for (shape in body.shapeList)
			{
				if (shape.containsPoint(_getWorldMouse()))
				{
					destroy = true;
					break;
				}
			}
			
			if (destroy)
			{
				for (shape in body.shapeList)
					_displayList.removeRenderer(shape);
				body.free();
				break;
			}
		}
	}
	
	function _destroyShape():Void
	{
		for (body in _world.bodyList)
		{
			for (shape in body.shapeList)
			{
				if (shape.containsPoint(_getWorldMouse()))
				{
					_displayList.removeRenderer(shape);
					shape.free();
					body.setMassFromShapes();
					break;
				}
			}
		}
	}
	
	function _addShapeRenderer(body:RigidBody):Void
	{
		_displayList.addRenderer(ShapeFeatureRenderer, body, _camera, _vr);
		for (s in body.shapeList) _setupShapeRenderer(cast _displayList.getRenderer(s));
	}
	
	function _setupShapeRenderer(s:ShapeFeatureRenderer):Void
	{
		s.colorFirstVertex     = 0xffffff00.toARGB();
		s.colorOtherVertex     = 0xffffff00.toARGB();
		s.colorBoundingBox     = 0xffffff00.toARGB();
		s.colorOBB             = 0xff80ff00.toARGB();
		s.colorBoundingSphere  = 0x50ffffff.toARGB();
		s.colorLabel           = 0xffff8000.toARGB();
		s.solidProxy           = false;
		s.vertexChainPointSize = 2;
		s.labelFontSize        = 8;
		s.colorCenterA         = 0xff000000.toARGB();
		s.colorCenterB         = 0xffff0000.toARGB();
		s.centerRadius         = 4;
		s.font                 = TestCase.getFont();
	}
	
	function _createFloor(level:Float, width:Float, thickness:Float):RigidBody
	{
		if (thickness <= Mathematics.EPS)
		{
			var bd = new RigidBodyData(0, y, 0);
			var sd = new EdgeData(new Vec2( -1, 0), new Vec2(1, 0), true, false, "floor");
			bd.addShapeData(sd);
			return _dataToBody(bd);
		}
		else
		{
			var bd = new RigidBodyData(0, level, 0);
			var sd = new BoxData(0, width, thickness, false, "floor");
			bd.addShapeData(sd);
			return _dataToBody(bd);
		}
	}
	
	function _createContainer(thickness:Float, cx:Float, cy:Float, ex:Float, ey:Float, ?usePoly = false, ?axisAligned = false):Void
	{
		if (thickness <= Mathematics.EPS)
		{
			var infinite = true;
			var doubleSided = false;
			
			var bd1 = new RigidBodyData(0, cy + (ey / 2), 0);
			var bd2 = new RigidBodyData(-ex / 2, 0, 0);
			var bd3 = new RigidBodyData( ex / 2, 0, 0);
			
			bd1.addShapeData(new EdgeData(new Vec2(-ex / 2, 0), new Vec2(ex / 2, 0), infinite, doubleSided, "U_floor"));
			bd2.addShapeData(new EdgeData(new Vec2(0, -ey / 2), new Vec2(0, ey / 2), infinite, doubleSided, "U_left"));
			bd3.addShapeData(new EdgeData(new Vec2(0, ey / 2), new Vec2(0, -ey / 2), infinite, doubleSided, "U_right"));
			
			_dataToBody(bd1);
			_dataToBody(bd2);
			_dataToBody(bd3);
		}
		else
		{
			var bd1 = new RigidBodyData(cx, cy + (ey / 2), 0);
			var bd2 = new RigidBodyData(cx - (ex / 2) - (thickness / 2), cy + (thickness / 2), 0);
			var bd3 = new RigidBodyData(cx + (ex / 2) + (thickness / 2), cy + (thickness / 2), 0);
			
			var sd1:ShapeData, sd2:ShapeData, sd3:ShapeData;
			
			if (usePoly)
			{
				sd1 = new PolyData(0, "U_floor");
				cast(sd1, PolyData).setBox(ex, thickness);
				
				sd2 = new PolyData(0, "U_left");
				cast(sd2, PolyData).setBox(thickness, ey);
				
				sd3 = new PolyData(0, "U_right");
				cast(sd3, PolyData).setBox(thickness, ey);
			}
			else
			{
				sd1 = new BoxData(0, ex, thickness, axisAligned, "U_floor");
				sd2 = new BoxData(0, thickness, ey, axisAligned, "U_left");
				sd3 = new BoxData(0, thickness, ey, axisAligned, "U_right");
			}
			
			bd1.addShapeData(sd1);
			_dataToBody(bd1);
			
			bd2.addShapeData(sd2);
			_dataToBody(bd2);
			
			bd3.addShapeData(sd3);
			_dataToBody(bd3);
		}
	}
	
	function _createBox(density:Float, x:Float, y:Float, w:Float, h:Float, ?r = .0, ?axisAligned = false, ?userData:Dynamic):RigidBody
	{
		var sd = new BoxData(density, w, h, axisAligned, userData);
		var bd = new RigidBodyData(x, y, r);
		bd.addShapeData(sd);
		return _dataToBody(bd);
	}
	
	function _createCircle(density:Float, x:Float, y:Float, radius:Float, ?userData = null):RigidBody
	{
		var sd = new CircleData(density, radius, userData);
		var bd = new RigidBodyData(x, y);
		bd.addShapeData(sd);
		return _dataToBody(bd);
	}
	
	function _createPoly(x:Float, y:Float, r:Float, data:PolyData):RigidBody
	{
		var bd = new RigidBodyData(x, y, r);
		bd.addShapeData(data);
		return _dataToBody(bd);
	}
	
	function _dataToBody(bd:RigidBodyData):RigidBody
	{
		var body = _world.createBody(bd);
		_addShapeRenderer(body);
		return body;
	}
	
	function _getRandomPolyCollection():Array<Array<Float>>
	{
		return
		[
			[-0.457,-0.513,-0.207,-0.628,0.616,-0.360,0.343,0.579,-0.320,0.589,-0.649,0.310,-0.688,0.235,-0.725,0.119],
			[-0.714,-0.196,0.666,-0.309,0.738,-0.085,-0.424,0.570],
			[0.265,0.726,-0.097,0.786,-0.451,0.570,-0.518,0.477,-0.550,0.420],
			[0.352,-0.538,0.498,-0.427,0.647,0.193,0.495,0.430,-0.189,0.604,-0.671,0.101],
			[0.591,-0.283,0.464,0.483,-0.168,0.669,-0.341,0.589,-0.501,0.438,-0.605,0.247],
			[-0.592,-0.305,-0.394,-0.560,-0.250,-0.647,0.255,-0.645,0.644,0.143,0.603,0.281,0.291,0.628,-0.338,0.600],
			[-0.613,-0.063,-0.353,-0.555,0.614,0.039,0.613,0.063,-0.434,0.481],
			[-0.555,-0.436,-0.526,-0.464,-0.206,-0.636,-0.052,-0.661,0.010,-0.662,0.273,-0.615,0.658,-0.300,0.735,0.055,0.709,0.182,0.201,0.637],
			[-0.610,-0.350,-0.111,-0.733,-0.009,-0.743,-0.003,-0.743,0.653,-0.245,0.329,0.654,-0.013,0.743,-0.459,0.555,-0.689,0.058],
			[0.735,-0.154,0.699,0.281,0.385,0.665,-0.384,0.665]
		];
	}
	
	function _gridLayout(radius:Float, x:Float, y:Float, w:Float, h:Float, countX:Int, countY:Int, process:Float->Float->Void):Void
	{
		w -= radius * 2;
		h -= radius * 2;
		
		var spaceX = (w - radius * 2) / (countX - 1);
		var spaceY = (h - radius * 2) / (countY - 1);
		
		x = x - w / 2 + radius;
		y = y - h / 2 + radius;
		
		for (i in 0...countY)
		{
			for (j in 0...countX)
			{
				var shapeX = x + j * spaceX;
				var shapeY = y + i * spaceY;
				
				if (Mathematics.isEven(i))
					shapeX += radius;
				else
					shapeX -= radius;
				
				process(shapeX, shapeY);
			}
		}
	}
	
	function _listLayout(radius:Float, x:Float, y:Float, lenght:Float, count:Int, process:Float->Float->Void):Void
	{
		lenght -= radius * 2;
		var spacing = (lenght - radius * 2) / (count - 1);
		var offset = x + -lenght / 2 + radius;
		for (i in 0...count) process(offset + i * spacing, y);
	}
	
	function _getCompoundBox()
	{
		var bd = new RigidBodyData(0, 0);
		
		var sd = new PolyData(.1);
		sd.setBox(.5, .5);
		
		var r = .6;
		
		sd.x = r;
		sd.y = 0;
		bd.addShapeData(sd);
		
		sd.x =-r;
		sd.y = 0;
		bd.addShapeData(sd);
		
		sd.x = 0;
		sd.y = r;
		bd.addShapeData(sd);
		
		sd.x = 0;
		sd.y =-r;
		bd.addShapeData(sd);
		
		bd.r = .3;
		
		_dataToBody(bd);
	}
	
	function _getCompoundPoly(density:Float, x:Float, y:Float, radius1:Float, radius2:Float):RigidBodyData
	{
		var bd = new RigidBodyData(x, y);
		
		var tmp = new PolyData(0);
		tmp.setCircle(6, radius1);
		var vertexList = tmp.getVertexList();
		
		tmp.density = density;
		tmp.setCircle(6, radius2);
		
		for (v in vertexList)
		{
			tmp.x = v.x;
			tmp.y = v.y;
			tmp.r = Math.PI / 6;
			bd.addShapeData(tmp);
		}
		
		return bd;
	}
	
	function _getCompoundCircle(density:Float, x:Float, y:Float, radius1:Float, radius2:Float):RigidBodyData
	{
		var poly = new PolyData(0);
		poly.setCircle(6, radius1);
		var bd = new RigidBodyData(x, y, 0);
		for (v in poly.getVertexList())
		{
			var sd = new CircleData(density, radius2);
			sd.x = v.x;
			sd.y = v.y;
			sd.r = Math.atan2(sd.y, sd.x);
			bd.addShapeData(sd);
		}
		return bd;
	}
}