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

class TestbedManifold
{
	public static function main():Void
	{
		MemoryManager.BLOCK_SIZE_BYTES = 128 << 10;
		MemoryManager.RESERVE_BYTES = 10 << 20;
		
		Window.initBackgroundColor = 0x222222;
		Root.init(onInit);
	}
	
	static var _app:TestbedManifold;
	static function onInit():Void 
	{
		_app = new TestbedManifold();
	}
	
	var _testRunner:TestRunner;
	
	public function new()
	{
		_testRunner = new TestRunner();
		Window.surface.addChild(_testRunner);
		
		_testRunner.add(testbed.test.manifold.TestManifoldSingleInfEdgeCircle);
		_testRunner.add(testbed.test.manifold.TestManifoldDoubleInfEdgeCircle);
		_testRunner.add(testbed.test.manifold.TestManifoldSingleEdgeCircle);
		_testRunner.add(testbed.test.manifold.TestManifoldDoubleEdgeCircle);
		
		_testRunner.add(testbed.test.manifold.TestManifoldSingleInfEdgeAABB);
		_testRunner.add(testbed.test.manifold.TestManifoldDoubleInfEdgeAABB);
		_testRunner.add(testbed.test.manifold.TestManifoldSingleEdgeAABB);
		_testRunner.add(testbed.test.manifold.TestManifoldDoubleEdgeAABB);
		
		_testRunner.add(testbed.test.manifold.TestManifoldSingleInfEdgeOBB);
		_testRunner.add(testbed.test.manifold.TestManifoldDoubleInfEdgeOBB);
		_testRunner.add(testbed.test.manifold.TestManifoldSingleEdgeOBB);
		_testRunner.add(testbed.test.manifold.TestManifoldDoubleEdgeOBB);
		
		_testRunner.add(testbed.test.manifold.TestManifoldSingleInfEdgePoly);
		_testRunner.add(testbed.test.manifold.TestManifoldDoubleInfEdgePoly);
		_testRunner.add(testbed.test.manifold.TestManifoldSingleEdgePoly);
		_testRunner.add(testbed.test.manifold.TestManifoldDoubleEdgePoly);
		
		_testRunner.add(testbed.test.manifold.TestManifoldCircle);
		_testRunner.add(testbed.test.manifold.TestManifoldAABB);
		_testRunner.add(testbed.test.manifold.TestManifoldAABBCircle);
		_testRunner.add(testbed.test.manifold.TestManifoldAABBOBB);
		_testRunner.add(testbed.test.manifold.TestManifoldAABBPoly);
		_testRunner.add(testbed.test.manifold.TestManifoldAABBTriangle);
		_testRunner.add(testbed.test.manifold.TestManifoldOBB);
		_testRunner.add(testbed.test.manifold.TestManifoldOBBCircle);
		_testRunner.add(testbed.test.manifold.TestManifoldOBBPoly);
		_testRunner.add(testbed.test.manifold.TestManifoldPoly);
		_testRunner.add(testbed.test.manifold.TestManifoldPolyCircle);
		_testRunner.add(testbed.test.manifold.TestManifoldTriangle);
		
		_testRunner.add(testbed.test.manifold.misc.TestManifoldPolyMPR);
		_testRunner.add(testbed.test.manifold.misc.TestManifoldVRM);
		_testRunner.add(testbed.test.manifold.misc.TestSupportMapping);
		_testRunner.add(testbed.test.manifold.misc.TestClip);
		
		_testRunner.run();
	}
}