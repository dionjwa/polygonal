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

import de.polygonal.motor.dynamics.joint.data.LineJointData;
import de.polygonal.motor.dynamics.joint.LineJoint;
import de.polygonal.core.math.Vec2;
import testbed.test.world.TestWorld;

class TestJointLine extends TestWorld
{
	override public function getName():String 
	{
		return "line joint";
	}
	
	var _joint:LineJoint;

	override function _initWorld():Void
	{
		var box = _createBox(1, 0, 0, 2, 0.5);
		var ground = _createBox(0, 0, 4, 8, 1);
		
		//test rotation
		_createBox(2, 1, -1, 1, 1);
		
		//normalized axis
		var axis = new Vec2(2, 1);
		var norm = Math.sqrt(axis.x * axis.x + axis.y * axis.y );
		axis.x /= norm;
		axis.y /= norm;
		//var axis = new Vec2(0, 1);
		
		//first body should be ground as the axis is taken in reference to it
		//joint tries to move center of mass to allowed line
		var jd = new LineJointData(ground, box, new Vec2(box.x, box.y), axis);
		jd.motorSpeed = -1;
		jd.maxMotorForce = 1;
		jd.enableMotor = true;
		jd.lowerTrans = -2;
		jd.upperTrans = 2;
		jd.enableLimit = true;
		
		_joint = cast _world.createJoint(jd);
	}
	
	override function _draw(alpha:Float):Void
	{
		var a = _joint.getAnchor1();
		
		var lower = new Vec2(a.x + _joint.lowerTrans * _joint.getJointAxis().x, a.y + _joint.lowerTrans * _joint.getJointAxis().y);
		var upper = new Vec2(a.x + _joint.upperTrans * _joint.getJointAxis().x, a.y + _joint.upperTrans * _joint.getJointAxis().y);
	}
	
	override function _free():Void
	{
		super._free();
	}
}