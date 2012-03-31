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
import de.polygonal.core.io.Base64;
import de.polygonal.gl.color.ARGB;
import de.polygonal.gl.VectorRenderer;
import de.polygonal.gl.Window;
import de.polygonal.motor.geom.gpc.GPC;
import de.polygonal.motor.geom.gpc.GPCPolygon;
import flash.utils.ByteArray;

class BritainArrowsExample
{
	static var _app:BritainArrowsExample;
	public static function main()
	{
		Window.initBackgroundColor = 0xffffff;
		de.polygonal.core.Root.init(onInit, true);
	}
	
	static function onInit()
	{
		var britain = "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";
		var arrows = "eNpjYGFgd2ZgYHDaw8DgrAqlJYD0IiBtBKS7oHwDIM0D5YPUJwAJiM5rUJ3XoCrfQXQ6s0D4zjIQnWA+UL2zAEin0wuIXWAaaJbTOYjZTlsgdjk1IfGBbnGaA1EP1DkHYhdYJ5QGmQkyAWQHSAfITpAJMD7ITQBKLCct";
		
		var a = _decode(britain);
		var b = _decode(arrows);
		var c = new GPCPolygon();
		
		var vr = new VectorRenderer();
		
		c.clear();
		
		var c = GPC.clip(a, b, c, ClipOperation.Difference);
		_drawPolygon(vr, c, 0, 0xffafc8ff, 1.5, 110, 45);
		_drawPolygon(vr, a, 0x40000000, 0, 1.5, 110, 45);
		_drawPolygon(vr, b, 0x40000000, 0, 1.5, 110, 45);
		
		c.clear();
		
		var c = GPC.clip(a, b, c, ClipOperation.Intersection);
		_drawPolygon(vr, c, 0, 0xffaff0a0, 1.5, 370, 45);
		_drawPolygon(vr, a, 0x40000000, 0, 1.5, 370, 45);
		_drawPolygon(vr, b, 0x40000000, 0, 1.5, 370, 45);
		
		c.clear();
		
		var c = GPC.clip(a, b, c, ClipOperation.XOr);
		_drawPolygon(vr, c, 0, 0xfff0f0a0, 1.5, 110, 305);
		_drawPolygon(vr, a, 0x40000000, 0, 1.5, 110, 305);
		_drawPolygon(vr, b, 0x40000000, 0, 1.5, 110, 305);
		
		c.clear();
		
		var c = GPC.clip(a, b, c, ClipOperation.Union);
		_drawPolygon(vr, c, 0, 0xffffd2d2, 1.5, 370, 305);
		_drawPolygon(vr, a, 0x40000000, 0, 1.5, 370, 305);
		_drawPolygon(vr, b, 0x40000000, 0, 1.5, 370, 305);
		
		vr.flush(Window.surface.graphics);
		
		GPC.free();
		vr.free();
	}
	
	static function _decode(s:String):GPCPolygon
	{
		var bytes = Base64.decode(s, new ByteArray(), false);
		bytes.uncompress();
		bytes.position = 0;
		
		var poly = new GPCPolygon();
		
		var numContours = bytes.readShort();
		for (i in 0...numContours)
		{
			var contour = new Array<Float>();
			var numPoints = bytes.readShort();
			for (j in 0...numPoints)
			{
				var x = bytes.readFloat();
				var y = bytes.readFloat();
				contour.push(x);
				contour.push(y);
			}
			poly.addContour(contour, numPoints << 1, false);
		}
		
		return poly;
	}
	
	static function _drawPolygon(vr:VectorRenderer, p:GPCPolygon, lineColor:Int, fillColor:Int, scale:Float, dx:Float, dy:Float)
	{
		if (lineColor != 0)
			vr.setLineStyle(ARGB.getRGB(lineColor), ARGB.getAf(lineColor), .5);
		else
			vr.clearStroke();
		
		if (fillColor != 0) vr.setFillColor(ARGB.getRGB(fillColor), ARGB.getAf(fillColor));
		
		for (i in 0...p.numContours)
		{
			var vertexList = p.getContourAt(i);
			
			if (p.isHoleAt(i)) continue;
			
			var tmp = new Array<Float>();
			
			var j = 0;
			var k = vertexList.size();
			while (j < k)
			{
				tmp[j + 0] = vertexList.get(j + 0) * scale + dx;
				tmp[j + 1] = vertexList.get(j + 1) * scale + dy;
				j += 2;
			}
			
			if (fillColor != 0) vr.fillStart();
			vr.polyLineScalar(tmp, true);
			if (fillColor != 0) vr.fillEnd();
		}
		
		for (i in 0...p.numContours)
		{
			var vertexList = p.getContourAt(i);
			
			if (!p.isHoleAt(i)) continue;
			
			vr.setFillColor(0xffffff, 1);
			
			var tmp = new Array<Float>();
			
			var j = 0;
			var k = vertexList.size();
			while (j < k)
			{
				tmp[j + 0] = vertexList.get(j + 0) * scale + dx;
				tmp[j + 1] = vertexList.get(j + 1) * scale + dy;
				j += 2;
			}
			
			vr.fillStart();
			vr.polyLineScalar(tmp, true);
			vr.fillEnd();
		}
	}
}