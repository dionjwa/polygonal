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
import de.polygonal.gl.Window;
import testbed.test.TestRunner;

class TestbedGeometry
{
	public static function main():Void
	{
		Window.initBackgroundColor = 0x222222;
		Root.init(onInit);
	}
	
	static var _app:TestbedGeometry;
	static function onInit():Void 
	{
		_app = new TestbedGeometry();
	}
	
	var _testRunner:TestRunner;
	
	public function new()
	{
		_testRunner = new TestRunner();
		
		Window.surface.addChild(_testRunner);
		
		_testRunner.add(testbed.test.geom.TestGeomPointInsideAABB);
		_testRunner.add(testbed.test.geom.TestGeomPointInsideOBB);
		_testRunner.add(testbed.test.geom.TestGeomPointInsidePlane);
		_testRunner.add(testbed.test.geom.TestGeomPointInsidePoly);
		_testRunner.add(testbed.test.geom.TestGeomPointInsideSphere);
		_testRunner.add(testbed.test.geom.TestGeomPointInsideTriangle);
		
		_testRunner.add(testbed.test.geom.TestGeomClosestPointAABB);
		_testRunner.add(testbed.test.geom.TestGeomClosestPointLine);
		_testRunner.add(testbed.test.geom.TestGeomClosestPointOBB);
		_testRunner.add(testbed.test.geom.TestGeomClosestPointPlane);
		_testRunner.add(testbed.test.geom.TestGeomClosestPointPoly);
		_testRunner.add(testbed.test.geom.TestGeomClosestPointRay);
		_testRunner.add(testbed.test.geom.TestGeomClosestPointSegment);
		_testRunner.add(testbed.test.geom.TestGeomClosestPointSegmentSegment);
		_testRunner.add(testbed.test.geom.TestGeomClosestPointSphere);
		
		_testRunner.add(testbed.test.geom.TestGeomDistancePoint);
		_testRunner.add(testbed.test.geom.TestGeomDistancePointLine);
		_testRunner.add(testbed.test.geom.TestGeomDistancePointPlane);
		_testRunner.add(testbed.test.geom.TestGeomDistancePointSegment);
		_testRunner.add(testbed.test.geom.TestGeomDistancePointSphere);
		_testRunner.add(testbed.test.geom.TestGeomDistanceSegmentSegment);
		
		_testRunner.add(testbed.test.geom.TestGeomIntersectRayAABB);
		_testRunner.add(testbed.test.geom.TestGeomIntersectRayPlane);
		_testRunner.add(testbed.test.geom.TestGeomIntersectRayPoly);
		_testRunner.add(testbed.test.geom.TestGeomIntersectRaySphere);
		_testRunner.add(testbed.test.geom.TestGeomIntersectSegment);
		_testRunner.add(testbed.test.geom.TestGeomIntersectAABB);
		_testRunner.add(testbed.test.geom.TestGeomIntersectSphere);
		_testRunner.add(testbed.test.geom.TestGeomIntersectSegmentAABB);
		_testRunner.add(testbed.test.geom.TestGeomIntersectSegmentPlane);
		_testRunner.add(testbed.test.geom.TestGeomIntersectSegmentSphere);
		_testRunner.add(testbed.test.geom.TestGeomIntersectSphereAABB);
		_testRunner.add(testbed.test.geom.TestGeomIntersectSpherePlane);
		
		_testRunner.add(testbed.test.geom.TestGeomIntersectMovingSphereAABB);
		_testRunner.add(testbed.test.geom.TestGeomIntersectMovingSpherePlane);
		_testRunner.add(testbed.test.geom.TestGeomIntersectMovingSpherePoly);
		_testRunner.add(testbed.test.geom.TestGeomIntersectMovingSphereSphere);
		_testRunner.add(testbed.test.geom.TestGeomIntersectMovingSphereSegment);
		
		_testRunner.add(testbed.test.geom.TestGeomMinimumAreaRectangle);
		_testRunner.add(testbed.test.geom.TestGeomMinimumAreaCircle);
		_testRunner.add(testbed.test.geom.TestGeomConvexHull);
		
		_testRunner.add(testbed.test.geom.TestGeomDDAASegment);
		_testRunner.add(testbed.test.geom.TestGeomDDAARay);
		
		_testRunner.add(testbed.test.geom.TestGeomGPC);
		
		_testRunner.run();
	}
}