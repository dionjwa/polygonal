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
import de.polygonal.core.fmt.Sprintf;
import de.polygonal.ds.ArrayUtil;
import de.polygonal.ds.Bits;
import de.polygonal.ds.DA;
import de.polygonal.ds.IntHashSet;
import de.polygonal.gl.VectorRenderer;
import de.polygonal.core.math.Vec2;
import de.polygonal.motor.geom.tri.DelaunayTriangulation;
import de.polygonal.ui.UI;

using de.polygonal.core.math.Mathematics;

class Editor
{
	var _points:DA<Vec2>;
	
	var _nodeData:Array<Float>;
	var _arcData:Array<Int>;
	
	public function new()
	{
		_points = new DA<Vec2>();
		_nodeData = new Array<Float>();
		_arcData = new Array<Int>();
	}
	
	public function getNodeData():Array<Float>
	{
		return _nodeData;
	}
	
	public function getArcData():Array<Int>
	{
		return _arcData;
	}
	
	public static function compare(v1:Vec2, v2:Vec2):Int
	{
		if (v1.x < v2.x)
			return -1;
		else
		if (v1.x > v2.x)
			return 1;
		else
			return 0;
	}
	
	public function update(vr:VectorRenderer):Void
	{
		var mouse = UI.instance().mouse;
		
		//add point
		_points.pushBack(new Vec2(mouse.x, mouse.y));
		_points.sort(compare, true);
		
		//draw points
		vr.setFillColor(0x666666, 1);
		vr.fillStart();
		for (p in _points) vr.box2(p, 2);
		vr.fillEnd();
		
		//compute delaunay triangulation from input points
		var nv = _points.size();
		var vertices = ArrayUtil.alloc(nv * 3 + 9);
		var i = 0;
		for  (p in _points)
		{
			vertices[i++] = p.x;
			vertices[i++] = p.y;
			vertices[i++] = 0;
		}
		
		var tri = ArrayUtil.alloc(nv * 3);
		var ntri = DelaunayTriangulation.triangulate(vertices, tri);
		
		_arcData = new Array<Int>();
		
		var set = new IntHashSet(256);
		
		//build arc list
		for (i in 0...ntri)
		{
			var i0 = tri[i * 3 + 0];
			var i1 = tri[i * 3 + 1];
			var i2 = tri[i * 3 + 2];
			
			var a = new Vec2(vertices[i0 * 3 + 0], vertices[i0 * 3 + 1]);
			var b = new Vec2(vertices[i1 * 3 + 0], vertices[i1 * 3 + 1]);
			var c = new Vec2(vertices[i2 * 3 + 0], vertices[i2 * 3 + 1]);
			
			//draw triangle
			vr.setLineStyle(0x666666, 1);
			vr.tri3(a, b, c);
			
			//we have trilists and not tristrips, so we need to make sure we don't add double arcs
			
			//if arc between i0,i1 does not exist
			if (!set.has(_key(i0, i1)))
			{
				//add arc between source (i0) and target (i1)
				set.set(_key(i0, i1));
				_arcData.push(i0);
				_arcData.push(i1);
			}
			
			if (!set.has(_key(i1, i2)))
			{
				set.set(_key(i1, i2));
				_arcData.push(i1);
				_arcData.push(i2);
			}
			
			if (!set.has(_key(i2, i0)))
			{
				set.set(_key(i2, i0));
				_arcData.push(i2);
				_arcData.push(i0);
			}
		}
		
		_nodeData = new Array<Float>();
		
		var s = "";
		var tmp = new Array<String>();
		for (p in _points)
		{
			tmp.push(Sprintf.format("%.2f", [p.x]));
			tmp.push(Sprintf.format("%.2f", [p.y]));
			
			_nodeData.push(p.x);
			_nodeData.push(p.y);
		}
		
		trace("var nodes = [" + tmp.join(",") + "];");
		trace("var arcs = [" + _arcData.join(",") + "];");
	}
	
	function _key(i0:Int, i1:Int):Int
	{
		return Bits.packI16(i0.min(i1), i0.max(i1));
	}
}