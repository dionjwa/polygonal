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
import de.polygonal.core.event.IObservable;
import de.polygonal.core.event.IObserver;
import de.polygonal.core.time.Timebase;
import de.polygonal.core.time.TimebaseEvent;
import de.polygonal.motor.collision.shape.AbstractShape;
import de.polygonal.motor.data.BoxData;
import de.polygonal.motor.data.RigidBodyData;
import de.polygonal.core.math.Vec2;
import de.polygonal.motor.geom.primitive.AABB2;
import de.polygonal.motor.Settings;
import de.polygonal.motor.World;
import flash.display.Graphics;
import flash.Lib;
import testbed.display.Camera;

class HelloWorld implements IObserver
{
	public static function main()
	{
		new HelloWorld();
	}
	
	var _world:World;
	
	var _camera:Camera;
	
	public function new()
	{
		//we have to define a world boundary, otherwise use default settings
		var worldSettings = new Settings();
		worldSettings.worldBound = new AABB2(-10, -10, 10, 10);
		
		_world = new World(worldSettings);
		
		var boxDensity = .1;
		var boxWidth = 1;
		var boxHeight = 1;
		var boxAxisAligned = false;
		var boxUserData = null;
		var boxData = new BoxData(boxDensity, boxWidth, boxHeight, boxAxisAligned, boxUserData);
		
		var bodyX = 0;
		var bodyY = 0;
		var bodyRotation = .2; //radians
		var rigidBodyData = new RigidBodyData(bodyX, bodyY, bodyRotation);
		
		//create box
		rigidBodyData.addShapeData(boxData);
		_world.createBody(rigidBodyData);
		
		//create ground; we can reuse our boxData and rigidBodyData object
		boxData.width = 5;
		boxData.height = .5;
		boxData.density = 0;
		rigidBodyData.y = 5;
		rigidBodyData.r = -.1;
		_world.createBody(rigidBodyData);
		
		//setup view
		_camera = new Camera(800/2, 600/2, 50); //1 meter equals 50 pixels
		
		Timebase.sAttach(this);
	}
	
	public function update(type:Int, source:IObservable, userData:Dynamic):Void 
	{
		if (type == TimebaseEvent.TICK)
		{
			//update world
			_world.solve();
			
			//update shapes (for rendering only)
			for (body in _world.bodyList)
				for (shape in body.shapeList)
					shape.syncFeatures();
		}
		
		if (type == TimebaseEvent.RENDER)
		{
			//render shapes
			var g = Lib.current.graphics;
			g.clear();
			g.lineStyle(0, 0, 1);
			
			for (body in _world.bodyList)
				for (shape in body.shapeList)
					_renderShape(shape, g);
		}
	}
	
	function _renderShape(shape:AbstractShape, g:Graphics)
	{
		var tmp = new Vec2();
		
		_camera.toScreen(shape.v0, tmp);
		g.moveTo(tmp.x, tmp.y);
		_camera.toScreen(shape.v1, tmp);
		g.lineTo(tmp.x, tmp.y);
		_camera.toScreen(shape.v2, tmp);
		g.lineTo(tmp.x, tmp.y);
		_camera.toScreen(shape.v3, tmp);
		g.lineTo(tmp.x, tmp.y);
		_camera.toScreen(shape.v0, tmp);
		g.lineTo(tmp.x, tmp.y);
	}
}