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

import de.polygonal.motor.dynamics.joint.data.PrismaticJointData;
import de.polygonal.core.math.Vec2;
import testbed.test.world.TestWorld;

class TestJointPrismatic extends TestWorld
{
	override public function getName():String 
	{
		return "prismatic joint";
	}
	
	override function _initWorld():Void
	{
		var ground = _createBox(0, 0, 4, 8, 1);
		var box = _createBox(1, -1, -2, 3, 0.5, 90, false);
		box.shape.friction = .05;
		
		var pos = new Vec2(-1, -2);
		
		var axis = new Vec2(2, 1);
		var norm = Math.sqrt(axis.x * axis.x + axis.y * axis.y );
		axis.x /= norm;
		axis.y /= norm;
		
		var jd = new PrismaticJointData(ground, box, new Vec2(0,1), axis);
		
		jd.motorSpeed = 2;
		jd.maxMotorForce = 10;
		jd.enableMotor = true;
		jd.lowerTrans = 0;
		jd.upperTrans = 5;
		jd.enableLimit = true;
		
		var joint = cast _world.createJoint(jd);
	}
	
	/*override function clientRender(alpha:Float):Void ???
	{
		var a = pos;
		var lower = new Vec2(a.x + _joint.lowerTrans * _joint.getJointAxis().x, a.y + _joint.lowerTrans * _joint.getJointAxis().y);
		var upper = new Vec2(a.x + _joint.upperTrans * _joint.getJointAxis().x, a.y + _joint.upperTrans * _joint.getJointAxis().y);
		
		//_illustrationRenderer.drawLine(lower.x, lower.y, upper.x, upper.y);
	}*/
}