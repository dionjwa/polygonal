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
import de.polygonal.gl.text.fonts.coreweb.Arial;
import de.polygonal.gl.VectorRenderer;
import de.polygonal.gl.Window;

class VectorFontHelloWorld
{
	static function main()
	{
		de.polygonal.core.Root.init(onInit, true);
	}
	
	static function onInit()
	{
		//create a font object
		var font = new Arial();
		
		//curve smoothness, the smaller, the better (0=use 2 segments per curve)
		font.bezierThreshold = 0.001;
		
		//set the font size: 100 equals 72pt or one inch.
		font.size = 100;
		
		//create a vector renderer and assign a line style
		var vr = new VectorRenderer(1024);
		vr.setLineStyle(0, 1, 0);
		//the font sends the drawing commands to the specified renderer
		font.setRenderer(vr);
		
		//draw the given string at x=0, y=100
		//if last parameter is true, the text will be centered around x,y
		font.write("Hello World!", 0, 100, false);
		
		//flush the buffer which draws everything on screen
		vr.flush(Window.surface.graphics);
	}
}