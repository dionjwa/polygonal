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
package testbed.test.world.joint;

import de.polygonal.motor.dynamics.joint.data.GearJointData;
import de.polygonal.motor.dynamics.joint.data.PrismaticJointData;
import de.polygonal.motor.dynamics.joint.data.RevoluteJointData;
import de.polygonal.core.math.Vec2;
import de.polygonal.motor.World;
import testbed.test.world.TestWorld;

class TestJointGear extends TestWorld
{
	override public function getName():String 
	{
		return "gear joint";
	}
	
	override function _initWorld():Void
	{
		var radius1 = .5;
		var radius2 = .75;
		
		var circle1 = _createCircle(1, -1.25, 0, radius1);
		var circle2 = _createCircle(1, 0, 0, radius2);
		
		var box = _createBox(1, 1, -1, 0.5, 3, 0);
		box.shape.friction = 0.05;
		var ground = _createBox(0, 0, 4, 8, 1);
		
		var r1 = new RevoluteJointData(ground, circle1, new Vec2(circle1.x, circle1.y));
		
		//TODO make this work
		r1.enableMotor = false;
		r1.motorSpeed = 1;
		r1.maxMotorTorque = 1;
		
		var rev1 = _world.createJoint(r1);
		
		var r2 = new RevoluteJointData(ground, circle2, new Vec2(circle2.x, circle2.y));
		var rev2 = _world.createJoint(r2);
		
		var p1 = new PrismaticJointData(ground, box, new Vec2(box.x, box.y), new Vec2(0, 1));
		p1.lowerTrans = -1;
		p1.upperTrans = 2.5;
		p1.enableLimit = true;
		
		var prismJoint = _world.createJoint(p1);
		
		var g2 = new GearJointData(rev2, prismJoint, -1 / radius2);
		var g1 = new GearJointData(rev1, rev2, radius2 / radius1);
		
		_world.createJoint(g1);
		_world.createJoint(g2);
		World.settings.positionIterations = 10;
		World.settings.velocityIterations = 20;
		World.settings.doWarmStart = true;
		
		//TODO Test two prismatic joints
	}
}