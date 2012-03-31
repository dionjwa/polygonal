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
package testbed.display;

import de.polygonal.core.math.Vec2;
import de.polygonal.ds.Bits;
import de.polygonal.ds.HashTable;
import de.polygonal.ds.TreeNode;
import de.polygonal.gl.color.RainbowGradient;
import de.polygonal.gl.text.VectorFont;
import de.polygonal.gl.VectorRenderer;
import de.polygonal.motor.geom.closest.ClosestPointAABB;
import de.polygonal.motor.geom.gpc.GPC;
import de.polygonal.motor.geom.gpc.GPCPolygon;
import de.polygonal.motor.geom.primitive.AABB2;
import de.polygonal.ui.trigger.state.TriggerState;
import de.polygonal.ui.trigger.state.TriggerStateDragOver;
import de.polygonal.ui.trigger.state.TriggerStateMachine;
import de.polygonal.ui.trigger.Trigger;

using de.polygonal.gl.color.ARGB;
using de.polygonal.ds.BitFlags;

class TreeRenderer 
{
	public static var sColorTreeBound    = 0x80ffffff;
	public static var sColorUserData      = 0xff000000;
	public static var sColorHierarchy     = 0x80ffffff;
	public static var sLineAlphaBound    = 1.0;
	public static var sFillAlphaBound    = 1.0;
	public static var sLineColor          = 0xffffffff;
	
	public static function setDefaultColors()
	{
		sLineColor          = 0xffffffff;
		sColorTreeBound    = 0x80ffffff;
		sColorUserData      = 0xff000000;
		sColorHierarchy     = 0x80ffffff;
		sLineAlphaBound    = 1.0;
		sFillAlphaBound    = 1.0;
	}
	
	inline public static var DRAW_SURFACE_BOUND = Bits.BIT_01;
	inline public static var DRAW_SURFACE_CENTER = Bits.BIT_02;
	inline public static var DRAW_TRIGGER_BOUND = Bits.BIT_03;
	inline public static var DRAW_USER_DATA      = Bits.BIT_04;
	inline public static var DRAW_HIERARCHY      = Bits.BIT_05;
	inline public static var DRAW_CLIPPED_BOUND = Bits.BIT_06;
	
	/* required if DRAW_USER_DATA flag is set */
	public var font:VectorFont;
	
	var _processCounter:Int;
	var _bits:Int;
	var _vr:VectorRenderer;
	
	var _rootNode:TreeNode<Trigger>;
	
	/* clipping */
	var _clippedBound:HashTable<Trigger, ClippedAABB>;
	
	public function new()
	{
		_clippedBound = new HashTable(64);
	}
	
	public function render(trigger:Trigger, vr:VectorRenderer, flags:Int)
	{
		_bits = flags;
		_vr = vr;
		_processCounter = 0;
		
		var node = trigger.getNode();
		
		_rootNode = node;
		
		if (hasf(DRAW_CLIPPED_BOUND))
		{
			for (t in node)
			{
				if (!_clippedBound.hasKey(t))
					_clippedBound.set(t, new ClippedAABB(t.surface.getBound()));
			}
			
			for (i in _clippedBound) i.init();
			
			//clip each node against subtree rooted at this node
			//node.preorder(_processNodeWithClippingBruteForce, false);
			node.preorder(_processNodeWithClippingBruteSmart);
		}
		
		node.preorder(_processNode);
	}
	
	function _processNode(node:TreeNode<Trigger>, preflight:Bool, userData:Dynamic):Bool
	{
		_drawSurfaceBound(node);
		_drawExtraInfo(node);
		return true;
	}
	
	function _processNodeWithClippingBruteSmart(node:TreeNode<Trigger>, preflight:Bool, userData:Dynamic):Bool
	{
		var trigger = node.val;
		var surface = trigger.surface;
		
		//process all nodes above this node (all children of node)
		_rootNode.preorder(_clipAgainstSubTree, false, false, node);
		
		//now go up and right to find all other nodes above this node
		var parent = node.parent;
		while (parent != null)
		{
			var parentNext = parent.next;
			while (parentNext != null)
			{
				parentNext.preorder(_clipAgainstSubTree, false, false, node);
				parentNext = parentNext.next;
			}
			
			parent = parent.next;
		}
		
		return true;
	}
	
	function _processNodeWithClippingBruteForce(node:TreeNode<Trigger>, userData:Dynamic):Bool
	{
		var trigger = node.val;
		var surface = trigger.surface;
		
		//brute-force
		_rootNode.preorder(_clipAgainstSubTree, false, false, node);
		return true;
	}
	
	function _clipAgainstSubTree(node:TreeNode<Trigger>, preflight:Bool, userData:Dynamic)
	{
		var currentNode:TreeNode<Trigger> = userData;
		
		//don't clip against myself
		if (node == currentNode)
			return true;
		
		var A = _clippedBound.get(currentNode.val);
		var B = _clippedBound.get(node.val);
		
		//A = A - B
		GPC.clip(A.poly, B.poly, A.poly, ClipOperation.Difference);
		
		return true;
	}
	
	function _clip(nodeA:TreeNode<Trigger>, nodeB:TreeNode<Trigger>)
	{
		//A = A - B
		var A = _clippedBound.get(nodeA.val);
		var B = _clippedBound.get(nodeB.val);
		GPC.clip(A.poly, B.poly, A.poly, ClipOperation.Difference);
	}
	
	function _drawSurfaceBound(node:TreeNode<Trigger>)
	{
		if (!hasf(DRAW_SURFACE_BOUND)) return;
		
		var trigger = node.val;
		var surface = trigger.surface;
		
		var brightness = .6;
		
		if (trigger.incf(Trigger.BIT_TOUCHING | Trigger.BIT_ENABLED))
			brightness = .9;
		
		if (trigger.hasf(Trigger.BIT_IS_DRAGGING))
			brightness = .9;
			
		if (trigger.incf(Trigger.BIT_TOUCHING | Trigger.BIT_ENABLED | Trigger.BIT_TOUCH_MODE))
		{
			var friend:{private var _state:TriggerStateMachine;} = trigger;
			var state:TriggerState = friend._state.getState();
			if (Std.is(state, TriggerStateDragOver))
				brightness = .9;
		}
		
		var treeSize = node.getRoot().size();
		var color = RainbowGradient.instance().getColor(treeSize, _processCounter, .6, brightness).get24();
		_processCounter++;
		
		if (sLineColor == 0)
			_vr.setLineStyle(color, sLineAlphaBound, 0);
		else
			_vr.setLineStyle(sLineColor, sLineAlphaBound, 0);

		_vr.setFillColor(color, sFillAlphaBound);
		_vr.fillStart();
		
		if (hasf(DRAW_CLIPPED_BOUND))
		{
			for (c in _clippedBound.get(node.val).poly)
				_vr.polyLineScalar(c.toArray(), true);
		}
		else
		{
			_vr.aabb(surface.getBound());
		}
		_vr.fillEnd();
	}
	
	function _drawExtraInfo(node:TreeNode<Trigger>)
	{
		var trigger = node.val;
		var surface = trigger.surface;
		
		if (hasf(DRAW_TRIGGER_BOUND))
		{
			//draw tree bounding box
			_vr.setLineStyle(sColorTreeBound.getRGB(), sColorTreeBound.getAf(), 0);
			_vr.aabb(trigger.getBound());
		}
		
		if (hasf(DRAW_HIERARCHY))
		{
			//draw parent->child relationship
			if (node.hasChildren())
			{
				_vr.setLineStyle(sColorHierarchy.getRGB(), sColorHierarchy.getAf());
				var child = node.children;
				while (child != null)
				{
					var q = surface.getCenter().clone();
					ClosestPointAABB.find2(q, child.val.surface.getBound(), q);
					_vr.arrowLine3(surface.getCenter(), q, 4);
					child = child.next;
				}
			}
		}
		
		if (hasf(DRAW_SURFACE_CENTER))
		{
			_vr.setLineStyle(0xffffff, .25);
			_vr.crossSkewed2(surface.getCenter(), 3);
		}
		
		if (hasf(DRAW_USER_DATA))
		{
			//draw user data
			if (Std.is(trigger.userData, String) || Std.is(trigger.userData, Int))
			{
				font.setRenderer(_vr);
				_vr.clearStroke();
				_vr.setFillColor(sColorUserData.getRGB(), sColorUserData.getAf());
				_vr.fillStart();
				
				var cx = trigger.surface.getCenter().x;
				var cy = trigger.surface.getCenter().y;
				font.write(Std.string(trigger.userData), cx, cy, true);
				_vr.fillEnd();
			}
		}
	}
}

private class ClippedAABB
{
	public var poly:GPCPolygon;
	
	var _bound:AABB2;
	var _vertices:Array<Float>;
	
	public function new(bound:AABB2)
	{
		_bound   = bound;
		_vertices = new Array<Float>();
		
		poly = new GPCPolygon();
		poly.reserve(32, 64);
	}
	
	public function init()
	{
		var vertices = _bound.getVertexListScalar(_vertices);
		
		poly.clear();
		poly.addContour(vertices, 8);
	}
}