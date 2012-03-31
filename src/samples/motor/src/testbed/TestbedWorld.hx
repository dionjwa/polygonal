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
package testbed;

import de.polygonal.core.Root;
import de.polygonal.ds.mem.MemoryManager;
import de.polygonal.gl.Window;
import testbed.test.TestRunner;

class TestbedWorld
{
	public static function main():Void
	{
		MemoryManager.BLOCK_SIZE_BYTES = 128 << 10;
		MemoryManager.RESERVE_BYTES    = 10 << 20;
		
		Window.initBackgroundColor = 0x222222;
		Root.init(onInit);
	}
	
	static var _app:TestbedWorld;
	static function onInit():Void 
	{
		_app = new TestbedWorld();
	}
	
	var _testRunner:TestRunner;
	
	public function new()
	{
		_testRunner = new TestRunner();
		
		Window.surface.addChild(_testRunner);
		
		_testRunner.add(testbed.test.world.contact.TestContactAABB1);
		_testRunner.add(testbed.test.world.contact.TestContactAABB2);
		_testRunner.add(testbed.test.world.contact.TestContactAABB3);
		_testRunner.add(testbed.test.world.contact.TestContactAABBCircle);
		_testRunner.add(testbed.test.world.contact.TestContactCircle);
		_testRunner.add(testbed.test.world.contact.TestContactOBB1); 
		_testRunner.add(testbed.test.world.contact.TestContactOBB2);
		_testRunner.add(testbed.test.world.contact.TestContactOBB3);
		_testRunner.add(testbed.test.world.contact.TestContactOBB4);
		_testRunner.add(testbed.test.world.contact.TestContactOBBCircle);
		_testRunner.add(testbed.test.world.contact.TestContactPoly);
		_testRunner.add(testbed.test.world.contact.TestContactCompound);
		_testRunner.add(testbed.test.world.contact.TestContactPolyCircle); 
		_testRunner.add(testbed.test.world.contact.TestContactTriangle);
		
		//_testRunner.add(testbed.test.world.contact.TestContactEdgePoly);
		//_testRunner.add(testbed.test.world.contact.TestContactFilter);
		
		_testRunner.add(testbed.test.world.joint.TestJointGear);
		_testRunner.add(testbed.test.world.joint.TestJointMouse);
		_testRunner.add(testbed.test.world.joint.TestJointLine);
		_testRunner.add(testbed.test.world.joint.TestJointPrismatic);
		_testRunner.add(testbed.test.world.joint.TestJointRevolute);
		_testRunner.add(testbed.test.world.joint.TestJointPulley);
		_testRunner.add(testbed.test.world.joint.TestJointDistance);
		
		_testRunner.run();
	}
}