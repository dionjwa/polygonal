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
import de.polygonal.core.time.Timebase;
import de.polygonal.gl.Window;
import testbed.test.TestRunner;

class Testbed
{
	public static function main():Void
	{
		Window.initBackgroundColor = 0x333333;
		Root.init(onInit, true);
	}
	
	static var _app:Testbed;
	static function onInit():Void 
	{
		_app = new Testbed();
	}
	
	var _testRunner:TestRunner;
	
	var _bits:Int;
	
	public function new()
	{
		_testRunner = new TestRunner();
		
		Window.surface.addChild(_testRunner);
		
		_testRunner.add(testbed.test.trigger.hierarchy.TestSmallTree);
		_testRunner.add(testbed.test.trigger.hierarchy.TestSmallTreeClipping);
		
		_testRunner.add(testbed.test.trigger.surface.TestBoxSurface);
		_testRunner.add(testbed.test.trigger.surface.TestCircleSurface);
		_testRunner.add(testbed.test.trigger.surface.TestPolySurface);
		_testRunner.add(testbed.test.trigger.surface.TestLineSurface);
		
		_testRunner.add(testbed.test.trigger.hierarchy.TestBigTree);
		_testRunner.add(testbed.test.trigger.hierarchy.TestLayer);
		
		_testRunner.add(testbed.test.trigger.constraint.TestAABBConstraint);
		_testRunner.add(testbed.test.trigger.constraint.TestDistanceConstraint);
		_testRunner.add(testbed.test.trigger.constraint.TestAxisConstraint);
		_testRunner.add(testbed.test.trigger.constraint.TestSnapConstraint);
		
		_testRunner.add(testbed.test.trigger.complex.TestMutablePane);
		_testRunner.add(testbed.test.trigger.complex.TestMutableSegment);
		_testRunner.add(testbed.test.trigger.complex.TestSlider);
		
		_testRunner.run();
	}
}