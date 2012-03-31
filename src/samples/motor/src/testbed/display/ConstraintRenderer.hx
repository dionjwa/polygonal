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
import de.polygonal.core.time.Timebase;
import de.polygonal.ds.HashTable;
import de.polygonal.ds.Map;
import de.polygonal.gl.color.ARGB;
import de.polygonal.gl.VectorRenderer;
import de.polygonal.motor.dynamics.contact.Contact;
import de.polygonal.motor.dynamics.contact.ManifoldPoint;
import de.polygonal.motor.dynamics.joint.JointType;
import de.polygonal.motor.dynamics.joint.MouseJoint;
import de.polygonal.motor.dynamics.joint.PulleyJoint;
import de.polygonal.core.math.Vec2;
import de.polygonal.motor.World;

class ConstraintRenderer
{
	public var colorContactPointCold:ARGB;
	public var colorContactPointWarm:ARGB;
	public var colorContactGraph:ARGB;
	public var colorImpulse:ARGB;
	public var contactPointSize:Float;
	public var colorJoints:ARGB;
	
	var _world:World;
	var _renderList:ShapeRendererList<ShapeFeatureRenderer>;
	var _camera:Camera;
	var _vr:VectorRenderer;
	var _matchTimer:Map<ManifoldPoint, Int>;
	var _tmpColor:ARGB;
	var _tmpVec:Vec2;
	
	public function new(world:World, renderList:ShapeRendererList<ShapeFeatureRenderer>, camera:Camera, vr:VectorRenderer)
	{
		_world      = world;
		_renderList = renderList;
		_camera     = camera;
		_vr         = vr;
		_matchTimer = new HashTable<ManifoldPoint, Int>(256, World.settings.maxPairs);
		_tmpColor   = new ARGB();
		_tmpVec     = new Vec2();
	}
	
	public function free():Void
	{
		_matchTimer.free();
		
		_world      = null;
		_renderList = null;
		_camera     = null;
		_vr         = null;
		_matchTimer = null;
		_tmpColor   = null;
		_tmpVec     = null;
	}
	
	public function drawContactPoints():Void
	{
		_vr.clearStroke();
		
		var colorBlendDur = Mathematics.round(.5 / Timebase.instance().getTickRate());
		for (contact in _world.contactList)
		{
			if (isSleeping(contact)) continue;
			
			var manifold = contact.manifold;
			for (i in 0...contact.manifoldCount)
			{
				for (mp in manifold)
				{
					var renderer = _renderList.getRenderer(contact.body1.shape);
					if (renderer == null) continue;
					
					//blend between "cold" and "warm" color depending on how long the manifold point is matched
					var time = 0;
					if (_matchTimer.hasKey(mp))
					{
						time = _matchTimer.get(mp);
						if (mp.matched)
						{
							if (time < colorBlendDur)
								time++;
						}
						else
							time = 0;
							
						_matchTimer.remap(mp, time);
					}
					else
						_matchTimer.set(mp, time);
					
					colorContactPointCold.lerp(colorContactPointWarm, time / colorBlendDur, _tmpColor);
					
					_vr.style.setFillColorARGB(_tmpColor);
					_vr.fillStart();
					_vr.box3(_camera.toScreenX(mp.x), _camera.toScreenY(mp.y), contactPointSize);
					_vr.fillEnd();
				}
			}
		}
	}
	
	public function drawContactGraph():Void
	{
		_vr.style.setLineColorARGB(colorContactGraph);
		_vr.applyLineStyle();
		
		for (c in _world.contactList)
		{
			if (isSleeping(c)) continue;
			
			var body1 = c.body1;
			var body2 = c.body2;
			
			var m = c.manifold;
			for (i in 0...c.manifoldCount)
			{
				var mp = m.mp1;
				for (j in 0...m.pointCount)
				{
					var r = _renderList.getRenderer(body1.shape);
					if (r != null)
					{
						_vr.line4
						(
							_camera.toScreenX(body1.worldCenter.x),
							_camera.toScreenY(body1.worldCenter.y),
							_camera.toScreenX(mp.x),
							_camera.toScreenY(mp.y)
						);
					}
					
					r = _renderList.getRenderer(body2.shape);
					if (r != null)
					{
						_vr.line4
						(
							_camera.toScreenX(body2.worldCenter.x),
							_camera.toScreenY(body2.worldCenter.y),
							_camera.toScreenX(mp.x),
							_camera.toScreenY(mp.y)
						);
					}
					
					mp = mp.next;
				}
				
				m = m.next;
			}
		}
	}
	
	public function drawJoints():Void
	{
		//TODO draw joint angles and axes?
		_vr.style.setLineColorARGB(colorJoints);
		_vr.style.lineThickness = 0;
		_vr.applyLineStyle();
		
		for (j in _world.jointList)
		{	
			switch (j.type)
			{
				case JointType.DISTANCE:
					var a1 = j.getAnchor1();
					var a2 = j.getAnchor2();
					
					var a1x = _camera.toScreenX(a1.x);
					var a1y = _camera.toScreenY(a1.y);
					var a2x = _camera.toScreenX(a2.x);
					var a2y = _camera.toScreenY(a2.y);
					
					_vr.line4(a1x, a1y, a2x, a2y);
					
				case JointType.MOUSE:
					var j:MouseJoint = cast j;
					var a1 = j.getTarget();
					var a2 = j.getAnchor2();
					
					var a1x = _camera.toScreenX(a1.x);
					var a1y = _camera.toScreenY(a1.y);
					var a2x = _camera.toScreenX(a2.x);
					var a2y = _camera.toScreenY(a2.y);
					
					_vr.line4(a1x, a1y, a2x, a2y);
					
				case JointType.REVOLUTE:
					var a1 = j.getAnchor1();
					
					var a1x = _camera.toScreenX(a1.x);
					var a1y = _camera.toScreenY(a1.y);
					
					var c1 = j.body1.origin;
					var c2 = j.body2.origin;
					
					var c1x = _camera.toScreenX(c1.x);
					var c1y = _camera.toScreenY(c1.y);
					
					var c2x = _camera.toScreenX(c2.x);
					var c2y = _camera.toScreenY(c2.y);
					
					_vr.line4(c1x, c1y, a1x, a1y);
					_vr.line4(a1x, a1y, c2x, c2y);
					
				case JointType.PULLEY:
					var j:PulleyJoint = cast j;
					var a1 = j.getAnchor1();
					var a2 = j.getGroundAnchor1();
					
					var a1x = _camera.toScreenX(a1.x);
					var a1y = _camera.toScreenY(a1.y);
					
					var a2x = _camera.toScreenX(a2.x);
					var a2y = _camera.toScreenY(a2.y);
					
					_vr.line4(a1x, a1y, a2x, a2y);
					
					a1 = j.getAnchor2();
					a2 = j.getGroundAnchor2();
					
					a1x = _camera.toScreenX(a1.x);
					a1y = _camera.toScreenY(a1.y);
					
					a2x = _camera.toScreenX(a2.x);
					a2y = _camera.toScreenY(a2.y);
					
					_vr.line4(a1x, a1y, a2x, a2y);
					
					a1 = j.getGroundAnchor1();
					
					a1x = _camera.toScreenX(a1.x);
					a1y = _camera.toScreenY(a1.y);
					
					_vr.line4(a1x, a1y, a2x, a2y);
					
				case JointType.GEAR:
					var c1 = j.body1.origin;
					var c2 = j.body2.origin;
					
					var c1x = _camera.toScreenX(c1.x);
					var c1y = _camera.toScreenY(c1.y);
					
					var c2x = _camera.toScreenX(c2.x);
					var c2y = _camera.toScreenY(c2.y);
					
					_vr.line4(c1x, c1y, c2x, c2y);
					
				case JointType.PRISMATIC:
					var a1 = j.getAnchor1();
					
					var a1x = _camera.toScreenX(a1.x);
					var a1y = _camera.toScreenY(a1.y);
					
					var c1 = j.body1.origin;
					var c2 = j.body2.origin;
					
					var c1x = _camera.toScreenX(c1.x);
					var c1y = _camera.toScreenY(c1.y);
					
					var c2x = _camera.toScreenX(c2.x);
					var c2y = _camera.toScreenY(c2.y);
					
					_vr.line4(c2x, c2y, a1x, a1y);
					_vr.line4(a1x, a1y, c1x, c1y);
					
				case JointType.LINE:
					var a1 = j.getAnchor1();
					
					var a1x = _camera.toScreenX(a1.x);
					var a1y = _camera.toScreenY(a1.y);
					
					var c1 = j.body1.origin;
					var c2 = j.body2.origin;
					
					var c1x = _camera.toScreenX(c1.x);
					var c1y = _camera.toScreenY(c1.y);
					
					var c2x = _camera.toScreenX(c2.x);
					var c2y = _camera.toScreenY(c2.y);
					
					_vr.line4(c2x, c2y, a1x, a1y);
					_vr.line4(a1x, a1y, c1x, c1y);
			}
		}
	}
	
	inline function isSleeping(c:Contact):Bool
	{
		return c.body1 != null && c.body2 != null && c.body1.isSleeping || c.body2.isSleeping;
	}
}