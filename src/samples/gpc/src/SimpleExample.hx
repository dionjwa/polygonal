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
import de.polygonal.gl.VectorRenderer;
import de.polygonal.gl.Window;
import de.polygonal.motor.geom.gpc.GPC;
import de.polygonal.motor.geom.gpc.GPCPolygon;
import de.polygonal.motor.geom.primitive.AABB2;
	
class SimpleExample
{
	public static function main()
	{
		Window.initBackgroundColor = 0xffffff;
		de.polygonal.core.Root.init(onInit, true);
	}
	
	static function onInit()
	{
		var box1 = new AABB2(100, 100, 200, 200);
		var box2 = new AABB2(150, 150, 250, 250);
		
		//define first input polygon
		var input1 = new GPCPolygon();
		input1.addContour(box1.getVertexListScalar(new Array<Float>()), 8);
		
		//define second input polygon
		var input2 = new GPCPolygon();
		input2.addContour(box2.getVertexListScalar(new Array<Float>()), 8);
		
		//define output polygon
		var output = new GPCPolygon();
		
		//compute union of input1 and input
		GPC.clip(input1, input2, output, ClipOperation.Union);
		
		var vr = new VectorRenderer();
		
		//draw input
		vr.setLineStyle();
		vr.aabb(box1);
		vr.aabb(box2);
		
		//draw output
		vr.setLineStyle(0xff0000, .5, 4);
		for (contour in output) vr.polyLineScalar(contour.getArray(), true, contour.size());
		
		vr.flush(Window.surface.graphics);
		
		//release memory used by GPC class (if never used again)
		GPC.free();
	}
}