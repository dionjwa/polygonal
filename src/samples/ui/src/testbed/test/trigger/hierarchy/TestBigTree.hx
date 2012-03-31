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
package testbed.test.trigger.hierarchy;

import de.polygonal.core.math.random.Random;
import de.polygonal.ds.TreeNode;
import de.polygonal.ui.trigger.surface.BoxSurface;
import de.polygonal.ui.trigger.Trigger;
import flash.ui.Keyboard;
import testbed.display.TreeRenderer;
import testbed.test.trigger.TestTrigger;
import testbed.test.Menu;

using de.polygonal.ds.BitFlags;

class TestBigTree extends TestTrigger
{
	inline static var TREE_ROOT_SIZE = 100;
	inline static var TREE_OFFSET = 32;
	inline static var TREE_DEPTH = 5;
	inline static var TREE_MIN_CHILDREN = 2;
	inline static var TREE_MAX_CHILDREN = 3;
	
	override public function getName():String 
	{
		return "trigger hierarchy stress test";
	}
	
	override function _getMenuEntriesHook()
	{
		return
		[
			new MenuEntry("F2\tenable dragging"    , Keyboard.F2, _onToggleDragging         , hasf(TestTrigger.DRAG_ENABLED)),
			new MenuEntry("F3\tdrag lock to center", Keyboard.F3, _onToggleDragLockCenter   , hasf(TestTrigger.DRAG_LOCK_CENTER)),
			new MenuEntry("F4\tenable touch mode"  , Keyboard.F4, _onToggleTouchMode        , hasf(TestTrigger.TOUCH_MODE)),
			new MenuEntry("F7\tdraw pointer"       , Keyboard.F7, _onToggleDrawPointer      , hasf(TestTrigger.DRAW_POINTER))
		];
	}
	
	override function _createTriggerHook()
	{
		var trigger            = new Trigger(new BoxSurface(centerX - TREE_ROOT_SIZE / 2, 25, TREE_ROOT_SIZE, TREE_ROOT_SIZE));
		trigger.dragEnabled    = true;
		trigger.dragLockCenter = hasf(TestTrigger.DRAG_LOCK_CENTER);
		trigger.touchMode      = hasf(TestTrigger.TOUCH_MODE);
		trigger.dragEnabled    = true;
		trigger.attach(this);
		
		var template = new TreeNode<Int>(0);
		_defineRandomTree(template, 0);
		_createTree(trigger, template, 0, 200, 600);
		
		for (t in trigger)
			t.attach(this);
		
		return trigger;
	}
	
	override function _renderHook() 
	{
		_treeRenderer.render(_trigger, _vr,
			TreeRenderer.DRAW_SURFACE_BOUND |
			TreeRenderer.DRAW_HIERARCHY
			);
		
		if (hasf(TestTrigger.DRAW_POINTER))
			_drawPointer();
	}
	
	function _defineRandomTree(parentNode:TreeNode<Int>, depth:Int):Void
	{
		var childNode:TreeNode<Int>;
		
		if (depth < TREE_DEPTH)
		{
			var i = Random.randRange(TREE_MIN_CHILDREN, TREE_MAX_CHILDREN);
			while (i-- > 0)
			{
				childNode = new TreeNode<Int>(depth, parentNode);
				_defineRandomTree(childNode, depth + 1);
			}
		}
	}
	
	function _createTree(trigger:Trigger, treeNode:TreeNode<Int>, x:Float, y:Float, width:Float):Void
	{
		if (treeNode != null)
		{
			var depth = treeNode.val;
			var size = 50 - (depth * 10);
			var childTrigger = new Trigger(new BoxSurface(x - size / 2 + width / 2, y, size, size), trigger.pointer);
			childTrigger.userData = treeNode.val;
			childTrigger.dragEnabled = hasf(TestTrigger.DRAG_ENABLED);
			childTrigger.dragLockCenter = hasf(TestTrigger.DRAG_LOCK_CENTER);
			childTrigger.touchMode = hasf(TestTrigger.TOUCH_MODE);
			trigger.appendChild(childTrigger);
			
			var w = treeNode.numChildren();
			if (w > 0) w = Std.int(width / w);
			
			var xPosChild = x;
			
			var child = treeNode.children;
			while (child != null)
			{
				_createTree(childTrigger, child, xPosChild, y + TREE_OFFSET, w);
				child = child.next;
				
				xPosChild += w;
			}
		}
	}
}