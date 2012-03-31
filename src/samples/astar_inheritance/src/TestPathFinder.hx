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
import de.polygonal.core.event.IObservable;
import de.polygonal.core.event.IObserver;
import de.polygonal.ds.DA;
import de.polygonal.ds.Graph;
import de.polygonal.ds.GraphNode;
import de.polygonal.gl.text.fonts.coreweb.ArialBold;
import de.polygonal.gl.VectorRenderer;
import de.polygonal.gl.Window;
import de.polygonal.ui.Key;
import de.polygonal.ui.trigger.pointer.MousePointer;
import de.polygonal.ui.trigger.surface.CircleSurface;
import de.polygonal.ui.trigger.Trigger;
import de.polygonal.ui.trigger.TriggerEvent;
import de.polygonal.ui.UI;
import de.polygonal.ui.UIEvent;

class TestPathFinder implements IObserver
{
	static var NODE_RADIUS = 10;
	static var ARC_OFFSET = 4;
	
	static var _app:TestPathFinder;
	public static function main()
	{
		Window.initBackgroundColor = 0xffffff;
		de.polygonal.core.Root.init(onInit, true);
	}
	
	static function onInit()
	{
		_app = new TestPathFinder();
	}
	
	var _graph:Graph<Int>;
	var _wayPoints:DA<Waypoint<Int>>;
	
	var _astar:GraphAStar<Int>;
	var _path:DA<Waypoint<Int>>;
	
	var _source:Waypoint<Int>;
	var _target:Waypoint<Int>;
	
	var _editor:Editor;
	var _info:String;
	var _vr:VectorRenderer;
	
	public function new()
	{
		_vr = new VectorRenderer();
		_editor = new Editor();
		
		_info = "click to create waypoints, press SPACE when done.";
		_drawInfo();
		_vr.flush(Window.surface.graphics);
		
		UI.sAttach(this, UIEvent.MOUSE_DOWN | UIEvent.KEY_DOWN);
	}
	
	function _buildGraph()
	{
		//an array of point coordinates:
		//the first point's x coordinate is at index [0] and its y coordinate at index [1],
		//followed by the coordinates of the remaining points.
		var nodeData = [82.00,298.00,132.00,446.00,184.00,179.00,228.00,326.00,306.00,478.00,391.00,373.00,406.00,240.00,414.00,111.00,500.00,447.00,537.00,245.00,597.00,376.00,618.00,186.00];
		
		//an array of arc indices:
		//the source node is at index [0], target node at index[1], followed by all remaining arcs.
		var arcData = [9,10,10,11,11,9,7,9,11,7,6,5,5,9,9,6,3,5,6,3,2,0,0,3,3,2,0,1,1,3,1,4,4,3,5,8,8,9,4,5,2,6,6,7,7,2,8,10,4,8];
		
		nodeData = _editor.getNodeData();
		arcData = _editor.getArcData();
		
		_graph = new Graph<Int>();
		_astar = new GraphAStar<Int>(_graph);
		
		_wayPoints = new DA<Waypoint<Int>>();
		
		//create nodes + waypoints
		var i = 0;
		var id = 0;
		while (i < nodeData.length)
		{
			var nodeX = nodeData[i++];
			var nodeY = nodeData[i++];
			
			//create a waypoint object for each node
			var wp = new Waypoint<Int>(id++);
			wp.x   = nodeX;
			wp.y   = nodeY;
			_graph.addNode(cast wp);
			
			_wayPoints.pushBack(wp); //index => graph node
			
			//create a button for each node
			var trigger = new Trigger(new CircleSurface(nodeX, nodeY, NODE_RADIUS));
			trigger.attach(this, TriggerEvent.CLICK);
			
			//resolve waypoint from trigger
			trigger.userData = wp;
		}
		
		//create arcs between nodes
		var i = 0;
		while (i < arcData.length)
		{
			var index0 = arcData[i++];
			var index1 = arcData[i++];
			var source = _wayPoints.get(index0);
			var target = _wayPoints.get(index1);
			
			_graph.addMutualArc(cast source, cast target, 1);
		}
		
		_redraw();
	}
	
	public function update(type:Int, source:IObservable, userData:Dynamic):Void 
	{
		switch (type)
		{
			case UIEvent.KEY_DOWN:
				if (userData == Key.SPACE)
				{
					if (_editor.getNodeData().length < 6)
						return;
					
					source.detach(this);
					
					/*///////////////////////////////////////////////////////
					// initialize graph structure
					///////////////////////////////////////////////////////*/
					_buildGraph();
					
					_editor = null;
					_info = "pick source waypoint.";
					_redraw();
				}
			
			case UIEvent.MOUSE_DOWN:
				var font = new ArialBold();
				_editor.update(_vr);
				_drawInfo();
				_vr.flush(Window.surface.graphics);
				
			case TriggerEvent.CLICK:
				selectWayPoint(userData.userData);
				
				//selection valid?
				if (_source != null && _target != null)
				{
					/*///////////////////////////////////////////////////////
					// find shortest path from first to second node
					///////////////////////////////////////////////////////*/
					_path = new DA<Waypoint<Int>>();
					var pathExists = _astar.find(_graph, _source, _target, _path);
					trace("path exists: " + pathExists);
					if (pathExists) trace("waypoints : " + _path);
					
					_info = "computing path...\npick source waypoint.";
					
					_redraw();
					
					//reset
					_path   = null;
					_source = null;
					_target = null;
				}
			
		}
	}
	
	function selectWayPoint(waypoint:Waypoint<Int>)
	{
		if (_source == null)
		{
			//pick first waypoint
			_source = waypoint;
			_target = null;
			_info = "pick target waypoint.";
		}
		else
		if (_target == null)
		{
			//pick second waypoint
			if (_source != waypoint)
				_target = waypoint;
		}
		
		_redraw();
	}
	
	function _redraw()
	{
		_draw();
		_drawInfo();
		_vr.flush(Window.surface.graphics);
	}
	
	function _draw()
	{
		_vr.setLineStyle(0, .75, 0);
		var f = new ArialBold();
		f.size = 12;
		f.setRenderer(_vr);
		
		_vr.setLineStyle(0, .5, 2);
		for (wp in _wayPoints) _vr.circle3(wp.x, wp.y, NODE_RADIUS);
		
		//draw waypoint ids
		_vr.clearStroke();
		_vr.setFillColor(0);
		_vr.fillStart();
		for (wp in _wayPoints) f.write(Std.string(wp.val), wp.x, wp.y, true);
		_vr.fillEnd();
		f.free();
		
		//draw all outgoing arcs for each node
		_vr.setLineStyle(0, .5);
		_graph.clearMarks();
		_graph.BFS(false, null, _drawNodeArcs);
		
		_vr.setLineStyle(0xff0000, 1, 2);
		
		//draw selection
		if (_source != null) _vr.circle3(_source.x, _source.y, NODE_RADIUS);
		if (_target != null) _vr.circle3(_target.x, _target.y, NODE_RADIUS);
		
		//draw shortest path
		if (_path != null)
		{
			//draw waypoints
			for (wp in _path) _vr.circle3(wp.x, wp.y, NODE_RADIUS);
			
			//draw arcs between waypoints
			_vr.setLineStyle(0xff0000, 1, 2);
			var i = 0;
			while (i < _path.size() - 1)
			{
				var wp1 = _path.get(i);
				var wp2 = _path.get(i + 1);
				
				var dx = wp2.x - wp1.x;
				var dy = wp2.y - wp1.y;
				var len = Math.sqrt(dx * dx + dy * dy);
				var xdir = dx / len;
				var ydir = dy / len;
				
				_vr.arrowLine5
				(
					wp1.x + ARC_OFFSET * xdir + NODE_RADIUS * xdir,
					wp1.y + ARC_OFFSET * ydir + NODE_RADIUS * ydir,
					wp2.x - ARC_OFFSET * xdir - NODE_RADIUS * xdir,
					wp2.y - ARC_OFFSET * ydir - NODE_RADIUS * ydir,
					8);
				i++;
			}
		}
	}
	
	function _drawInfo()
	{
		var f = new ArialBold();
		f.size = 12;
		f.setRenderer(_vr);
		_vr.clearStroke();
		_vr.setFillColor(0);
		_vr.fillStart();
		f.write(_info, 10, 20);
		_vr.fillEnd();
		f.free();
	}
	
	function _drawNodeArcs(node:GraphNode<Dynamic>, preflight:Bool, userData:Dynamic):Bool
	{
		var wp1:Waypoint<Int> = cast node;
		
		var arc = wp1.arcList;
		while (arc != null)
		{
			var wp2:Waypoint<Int> = cast arc.node;
			
			var dx = wp2.x - wp1.x;
			var dy = wp2.y - wp1.y;
			var len = Math.sqrt(dx * dx + dy * dy);
			var xdir = dx / len;
			var ydir = dy / len;
			
			_vr.arrowLine5
			(
				wp1.x + ARC_OFFSET * xdir + NODE_RADIUS * xdir,
				wp1.y + ARC_OFFSET * ydir + NODE_RADIUS * ydir,
				wp2.x - ARC_OFFSET * xdir - NODE_RADIUS * xdir,
				wp2.y - ARC_OFFSET * ydir - NODE_RADIUS * ydir,
				4);
			arc = arc.next;
		}
		
		return true;
	}
}