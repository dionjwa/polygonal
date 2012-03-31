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
import de.polygonal.core.Root;
import de.polygonal.gl.text.VectorFont;
import de.polygonal.gl.VectorRenderer;
import de.polygonal.gl.Window;
import de.polygonal.motor.geom.primitive.AABB2;

class TestCoreWebFonts
{
	static function main():Void
	{
		Window.initBackgroundColor = 0xffffff;
		Root.init(onInit, true);
	}
	
	static function onInit():Void 
	{
		var fontList = new Array<Class<VectorFont>>();
		fontList.push(de.polygonal.gl.text.fonts.coreweb.AndaleMono);
		fontList.push(de.polygonal.gl.text.fonts.coreweb.Arial);
		fontList.push(de.polygonal.gl.text.fonts.coreweb.ArialBlack);
		fontList.push(de.polygonal.gl.text.fonts.coreweb.ArialBold);
		fontList.push(de.polygonal.gl.text.fonts.coreweb.ArialBoldItalic);
		fontList.push(de.polygonal.gl.text.fonts.coreweb.ArialItalic);
		fontList.push(de.polygonal.gl.text.fonts.coreweb.ComicSansMS);
		fontList.push(de.polygonal.gl.text.fonts.coreweb.ComicSansMSBold);
		fontList.push(de.polygonal.gl.text.fonts.coreweb.CourierNew);
		fontList.push(de.polygonal.gl.text.fonts.coreweb.CourierNewBold);
		fontList.push(de.polygonal.gl.text.fonts.coreweb.CourierNewBoldItalic);
		fontList.push(de.polygonal.gl.text.fonts.coreweb.CourierNewItalic);
		fontList.push(de.polygonal.gl.text.fonts.coreweb.Georgia);
		fontList.push(de.polygonal.gl.text.fonts.coreweb.GeorgiaBold);
		fontList.push(de.polygonal.gl.text.fonts.coreweb.GeorgiaBoldItalic);
		fontList.push(de.polygonal.gl.text.fonts.coreweb.GeorgiaItalic);
		fontList.push(de.polygonal.gl.text.fonts.coreweb.Impact);
		fontList.push(de.polygonal.gl.text.fonts.coreweb.TimesNewRoman);
		fontList.push(de.polygonal.gl.text.fonts.coreweb.TimesNewRomanBold);
		fontList.push(de.polygonal.gl.text.fonts.coreweb.TimesNewRomanBoldItalic);
		fontList.push(de.polygonal.gl.text.fonts.coreweb.TimesNewRomanItalic);
		fontList.push(de.polygonal.gl.text.fonts.coreweb.TrebuchetMS);
		fontList.push(de.polygonal.gl.text.fonts.coreweb.TrebuchetMSBold);
		fontList.push(de.polygonal.gl.text.fonts.coreweb.TrebuchetMSBoldItalic);
		fontList.push(de.polygonal.gl.text.fonts.coreweb.TrebuchetMSItalic);
		fontList.push(de.polygonal.gl.text.fonts.coreweb.Verdana);
		fontList.push(de.polygonal.gl.text.fonts.coreweb.VerdanaBold);
		fontList.push(de.polygonal.gl.text.fonts.coreweb.VerdanaBoldItalic);
		fontList.push(de.polygonal.gl.text.fonts.coreweb.VerdanaItalic);
		
		var bound = new AABB2(20, 10, 20, 10);
		
		var vr = new VectorRenderer(1024, 1024);
		
		for (fontClass in fontList)
		{
			var f:VectorFont = Type.createInstance(fontClass, []);
			f.setRenderer(vr);
			f.size = 12;
			
			vr.clearStroke();
			vr.setFillColor();
			vr.fillStart();
			
			var x = bound.minX;
			var y = bound.maxY + f.size + 4;
			
			bound = f.writeCharSet(x, y, 1024);
			
			vr.fillEnd();
			
			vr.setLineStyle(0x00FF00, .5, 0);
			vr.aabb(bound);
		}
		
		vr.flush(Window.surface.graphics);
	}
}