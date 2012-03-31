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

import de.polygonal.motor.dynamics.joint.data.MouseJointData;
import de.polygonal.motor.dynamics.joint.MouseJoint;
import de.polygonal.core.math.Vec2;
import testbed.test.world.TestWorld;

class TestJointMouse extends TestWorld
{
	override public function getName():String 
	{
		return "mouse joint";
	}
	
	var _mouseJoint:MouseJoint;
	
	override function _initWorld():Void
	{
		var box = _createBox(1, 0, 0, 1, 1);
		var data = new MouseJointData(box, new Vec2());
		
		data.dampingRatio = .5;
		data.frequencyHz = 1;
		
		data.target = new Vec2(.5, -.5);
		data.maxForce = 100 * box.mass * 50;
		
		_mouseJoint = cast _world.createJoint(data);
	}
	
	override function _tick(tick):Void
	{
		var pos = _getWorldMouse();
		_mouseJoint.setTarget(pos.x,pos.y);
	}
	
	override function _free():Void
	{
		super._free();
	}
}