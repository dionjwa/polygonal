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

import de.polygonal.motor.dynamics.joint.data.DistanceJointData;
import de.polygonal.core.math.Vec2;
import testbed.test.world.TestWorld;

class TestJointDistance extends TestWorld
{
	override public function getName():String 
	{
		return "distance joint";
	}
	
	override function _initWorld():Void
	{
		var box0 = _createBox(0, 0, -4, 1, 1);
		var box1 = _createBox(1, 0, -1, 1, 1);
		var box2 = _createBox(1, 0, 2, 1, 1);
		
		var c0 = box0.TWorld.getTranslation(new Vec2());
		var c1 = box1.TWorld.getTranslation(new Vec2());
		var c2 = box2.TWorld.getTranslation(new Vec2());
		
		var jd = new DistanceJointData(box0, box1, new Vec2(c0.x, c0.y), new Vec2(c1.x + 0.5, c1.y - 0.5));
		_world.createJoint(jd);
		
		var jd = new DistanceJointData(box1, box2, new Vec2(c1.x - 0.5, c1.y + 0.5), new Vec2(c2.x - 0.5, c2.y - 0.5));
		_world.createJoint(jd);
	}
}