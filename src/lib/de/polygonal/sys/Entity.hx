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
package de.polygonal.sys;

import de.polygonal.core.event.IObservable;
import de.polygonal.core.event.IObserver;
import de.polygonal.core.event.Observable;
import de.polygonal.core.fmt.Sprintf;
import de.polygonal.core.fmt.StringUtil;
import de.polygonal.core.math.Limits;
import de.polygonal.ds.Bits;
import de.polygonal.ds.TreeNode;
import de.polygonal.core.util.Assert;

class Entity implements IObserver, implements IObservable
{
	public static var format:Entity->String = null;
	
	inline static var BIT_ADVANCE          = Bits.next(Entity);
	inline static var BIT_RENDER           = Bits.next(Entity);
	inline static var BIT_STOP_PROPAGATION = Bits.next(Entity);
	inline static var BIT_PROCESS_SUBTREE  = Bits.next(Entity);
	inline static var BIT_PENDING_ADD      = Bits.next(Entity);
	inline static var BIT_PENDING_REMOVE   = Bits.next(Entity);
	inline static var BIT_ADDED            = Bits.next(Entity);
	inline static var BIT_REMOVED          = Bits.next(Entity);
	inline static var BIT_PROCESS          = Bits.next(Entity);
	inline static var BIT_COMMIT_REMOVAL   = Bits.next(Entity);
	inline static var BIT_COMMIT_SUICIDE   = Bits.next(Entity);
	inline static var BIT_INITIATOR        = Bits.next(Entity);
	inline static var BIT_RECOMMIT         = Bits.next(Entity);
	
	/**
	 * The id of this entity.<br/>
	 * The default value is the unqualified class name of this entity.
	 */
	public var id:Dynamic;
	
	/**
	 * The processing order of this entity.<br/>
	 * The smaller the value, the higher the priority.<br/>
	 * The default value is 0xFFFF.
	 */
	public var priority:Int;
	
	/**
	 * The tree node that stores this entity.
	 */
	public var node(default, null):TreeNode<Entity>;
	
	/**
	 * If false, <code>onAdvance()</code> is not called on this entity.<br/>
	 * Default ist true.
	 */
	public var doAdvance(_doAdvanceGetter, _doAdvanceSetter):Bool;
	function _doAdvanceGetter():Bool
	{
		return _hasFlag(BIT_ADVANCE);
	}
	function _doAdvanceSetter(x:Bool):Bool
	{
		x ? _setFlag(BIT_ADVANCE) : _clrFlag(BIT_ADVANCE);
		return x;
	}
	
	/**
	 * If false, <code>onRender()</code> is not called on this entity.<br/>
	 * Default ist false.
	 */
	public var doRender(_doRenderGetter, _doRenderSetter):Bool;
	function _doRenderGetter():Bool
	{
		return _hasFlag(BIT_RENDER);
	}
	function _doRenderSetter(x:Bool):Bool
	{
		x ? _setFlag(BIT_RENDER) : _clrFlag(BIT_RENDER);
		return x;
	}
	
	/**
	 * If false, the children of this node are neither updated nor rendered.<br/>
	 * Default is true.
	 */
	public var doChildren(_doChildrenGetter, _doChildrenSetter):Bool;
	function _doChildrenGetter():Bool
	{
		return _hasFlag(BIT_PROCESS_SUBTREE);
	}
	function _doChildrenSetter(x:Bool):Bool
	{
		x ? _setFlag(BIT_PROCESS_SUBTREE) : _clrFlag(BIT_PROCESS_SUBTREE);
		return x;
	}
	
	var _flags:Int;
	var _observable:Observable;
	var _class:Class<Entity>;
	
	public function new(?id:Dynamic)
	{
		this.id = id == null ? StringUtil.getUnqualifiedClassName(this) : id;
		node = new TreeNode<Entity>(this);
		priority = Limits.UINT16_MAX;
		_flags = BIT_ADVANCE | BIT_PROCESS_SUBTREE;
		_observable = null;
		_class = null;
	}
	
	/**
	 * Recursively destroys the subtree rooted at this entity (including this entity) from the bottom up.<br/>
	 * The method invokes <code>onFree()</code> on each entity, giving each entity the opportunity to perform some cleanup (e.g. free resources or unregister from listeners).<br/>
	 * Only effective if <code>commit()</code> is called afterwards.
	 */
	public function free():Void
	{
		if (_hasFlag(BIT_COMMIT_SUICIDE))
		{
			de.polygonal.core.log.Log.getLog(Entity).warn(Sprintf.format("entity %s already freed", [Std.string(id)]));
			return;
		}
		
		if (node.hasParent())
		{
			_setFlag(BIT_COMMIT_SUICIDE);
			remove();
		}
	}
	
	public function stopPropagation():Void
	{
		_setFlag(BIT_STOP_PROPAGATION);
	}
	
	public function sleep(deep = false)
	{
		if (deep)
			_clrFlag(BIT_ADVANCE | BIT_RENDER | BIT_PROCESS_SUBTREE);
		else
			_clrFlag(BIT_ADVANCE | BIT_RENDER);
	}
	
	public function wakeup(deep = false)
	{
		if (deep)
			_setFlag(BIT_ADVANCE | BIT_RENDER | BIT_PROCESS_SUBTREE);
		else
			_setFlag(BIT_ADVANCE | BIT_RENDER);
	}
	
	inline public function getParent():Entity
	{
		return node.hasParent() ? node.parent.val : null;
	}
	
	inline public function hasParent():Bool
	{
		return node.hasParent();
	}
	
	public function getChildAtIndex<T>(i:Int):T
	{
		D.assert(i >= 0 && i < node.numChildren(), 'index out of range');
		var n = node.children;
		for (j in 0...i) n = n.next;
		return cast n.val;
	}
	
	public function sortChildren():Void
	{
		var n = node.children;
		while (n != null)
		{
			if (n.val.priority < Limits.INT16_MAX)
			{
				node.sort(_sortChildrenCompare, true);
				break;
			}
			n = n.next;
		}
	}
	
	/**
	 * Recursively adds all pending additions and removals.
	 */
	public function commit():Void
	{
		//if tree is being updated, re-update it in a second pass
		var n = node, e;
		while (n != null)
		{
			e = n.val;
			if (e._hasFlag(BIT_INITIATOR))
			{
				e._setFlag(BIT_RECOMMIT);
				return;
			}
			n = n.parent;
		}
		
		//do nothing if subtree hasn't changed
		if (!_isDirty())
		{
			_clrFlag(BIT_INITIATOR | BIT_RECOMMIT);
			return;
		}
		
		_setFlag(BIT_INITIATOR);
		
		//prepare for adding nodes
		node.postorder
		(
			function(n, u)
			{
				var e = n.val;
				if (e._hasFlag(BIT_PENDING_ADD))
				{
					e._clrFlag(BIT_PENDING_ADD);
					e._setFlag(BIT_PROCESS);
				}
				return true;
			}
		);
		
		//propagate tree changes due to adding nodes
		node.postorder
		(
			function(n, u)
			{
				var e = n.val;
				var p = e.getParent();
				if (e._hasFlag(BIT_PROCESS))
				{
					//child is a pending node; parent is an existing node
					p._addChild(e);
				}
				else
				if (!e._hasFlag(BIT_PENDING_REMOVE)) //nodes are removed in a second pass
				{
					//child and parent are both existing
					if (p != null)
					{
						//propagate new subtree state
						e._propagateAddParentPendingSubtree(p);
						e._propagateAddChildPendingSubtree(p);
					}
				}
				return true;
			}
		);
		
		//reset flags of added nodes
		node.postorder
		(
			function(n, u)
			{
				n.val._clrFlag(BIT_PROCESS | BIT_ADDED);
				return true;
			}
		);
		
		//prepare for removing nodes
		node.postorder
		(
			function(n, u)
			{
				var e = n.val;
				if (e._hasFlag(BIT_PENDING_REMOVE))
				{
					e._clrFlag(BIT_PENDING_REMOVE);
					e._setFlag(BIT_PROCESS);
				}
				return true;
			}
		);
		
		//propagate tree changes due to removing nodes
		node.postorder
		(
			function(n, u)
			{
				var e = n.val;
				var p = e.getParent();
				
				//child is a pending node; parent is an existing node
				if (e._hasFlag(BIT_PROCESS))
				{
					//propagate change
					p._removeChild(e);
					
					//node is removed later so traversal doesn't break
					e._setFlag(BIT_COMMIT_REMOVAL);
				}
				else
				if (!e._hasFlag(BIT_PENDING_ADD))
				{
					//child and parent are both existing nodes
					if (p != null)
					{
						//propagate new subtree state
						e._propagateRemoveParentPendingSubtree(p);
						e._propagateRemoveChildPendingSubtree(p);
					}
				}
				return true;
			}
		);
		
		//post-processing
		node.postorder
		(
			function(n, u)
			{
				var e = n.val;
				
				//resort children
				e.sortChildren();
				
				//unlink node marked for removal?
				if (e._hasFlag(BIT_COMMIT_REMOVAL))
				{
					n.unlink();
					
					//recursively destroy subtree rooted at n?
					if (e._hasFlag(BIT_COMMIT_SUICIDE))
						e._free();
				}
				
				//clear flags
				e._clrFlag(BIT_PROCESS | BIT_ADDED | BIT_REMOVED | BIT_COMMIT_REMOVAL);
				return true;
			}
		);
		
		_clrFlag(BIT_INITIATOR);
		if (_hasFlag(BIT_RECOMMIT))
		{
			_clrFlag(BIT_RECOMMIT);
			commit();
		}
	}
	
	/**
	 * Updates all entities in the subtree rooted at this node (excluding this node) by calling <code>onAdvance()</code> on each node.
	 * @param dt the time step passed to each node.
	 */
	public function advance(dt:Float):Void
	{
		_propagateAdvance(dt, this);
	}
	
	/**
	 * Renders all entities in the subtree rooted at this node (excluding this node) by calling <code>onRender()</code> on each node.
	 * @param  alpha a blending factor in the range <arg>&#091;0, 1&#093;</arg> between the previous and current state.
	 */
	public function render(alpha:Float):Void
	{
		_propagateRender(alpha, this);
	}
	
	/**
	 * Adds a <code>child</code> entity to this entity.
	 */
	//public function add(child:Entity, ?childId:Dynamic, priority = Limits.UINT16_MAX):Void
	public function add(child:Entity, priority = Limits.UINT16_MAX):Void
	{
		#if debug
		if (child._hasFlag(BIT_PENDING_ADD))
		{
			de.polygonal.core.log.Log.getLog(Entity).warn(Sprintf.format("entity %s already added to %s", [child.id, id]));
			return;
		}
		#end
		D.assert(!node.contains(child), 'given entity is a child of this entity');
		
		//TODO!
		//if (childId != null) child.id = childId;
		if (priority != Limits.UINT16_MAX) child.priority = priority;
		
		//modify tree
		node.appendNode(child.node);
		
		//mark as pending addition
		child._clrFlag(BIT_PENDING_REMOVE);
		child._setFlag(BIT_PENDING_ADD);
	}
	
	/**
	 * Removes a <code>child</code> entity from this entity or this entity if <code>child</code> is omitted.
	 * @param deep if true, recursively removes all nodes in the subtree rooted at this node.
	 */
	public function remove(?child:Entity, deep = false):Void
	{
		if (child == null)
		{
			//remove this entity
			if (getParent() != null)
				getParent().remove(this, deep);
			return;
		}
		
		#if debug
		if (child._hasFlag(BIT_PENDING_REMOVE))
		{
			de.polygonal.core.log.Log.getLog(Entity).warn(Sprintf.format("entity %s already removed from %s", [Std.string(child.id), Std.string(id)]));
			return;
		}
		D.assert(child != this, 'given entity (%s) equals this entity.');
		D.assert(node.contains(child), Sprintf.format('given entity (%s) is not a child of this entity (%s).', [Std.string(child.id), Std.string(id)]));
		#end
		
		child.sleep();
		
		//mark as pending removal
		child._clrFlag(BIT_PENDING_ADD);
		child._setFlag(BIT_PENDING_REMOVE);
		
		if (deep)
		{
			var n = child.node.children;
			while (n != null)
			{
				remove(n.val, deep);
				n = n.next;
			}
		}
	}
	
	/**
	 * Removes all child entities.
	 * @param deep if true, recursively removes all nodes in the subtree rooted at this node.
	 */
	public function removeChildren(deep = false):Entity
	{
		var n = node.children;
		while (n != null)
		{
			remove(n.val);
			if (deep) n.val.removeChildren(deep);
			n = n.next;
		}
		return this;
	}
	
	/**
	 * Returns the first occurrence of an entity whose id matches <code>x</code> or null if no entity was found.
	 * @param deep if true, searches the entire subtree rooted at this node.
	 */
	public function findChildById(x:Dynamic, deep = false):Entity
	{
		if (deep)
		{
			for (i in node)
			{
				if (i == this) continue;
				if (i.id == x) return i;
			}
			return null;
		}
		else
		{
			var n = node.children, e;
			while (n != null)
			{
				e = n.val;
				if (e.id == x) return e;
				n = n.next;
			}
		}
		return null;
	}
	
	/**
	 * Returns the first occurrence of an entity whose class matches <code>x</code> or null if no entity was found.
	 * @param deep if true, searches the entire subtree rooted at this node.
	 */
	public function findChildByClass<T>(x:Class<T>, deep = false):T
	{
		var c:Class<Dynamic>;
		if (deep)
		{
			for (i in node)
			{
				if (i == this) continue;
				c = i._getClass();
				if (c == x) return cast i;
			}
		}
		else
		{
			var n = node.children, e;
			while (n != null)
			{
				e = n.val;
				c = e._getClass();
				if (c == x) return cast e;
				n = n.next;
			}
		}
		return null;
	}
	
	/**
	 * Returns the first occurrence of an entity whose id matches <code>x</code> or null if no entity was found.
	 */
	public function findSiblingById(x:Dynamic):Entity
	{
		var n = node.getFirstSibling(), e;
		while (n != null)
		{
			e = n.val;
			if (e.id == x) return e;
			n = n.next;
		}
		return null;
	}
	
	/**
	 * Returns the first occurrence of an entity whose class matches <code>x</code> or null if no entity was found.
	 */
	public function findSiblingByClass<T>(x:Class<T>):T
	{
		var c:Class<Dynamic>;
		var n = node.getFirstSibling(), e;
		while (n != null)
		{
			e = n.val;
			c = e._getClass();
			if (c == x) return cast e;
			n = n.next;
		}
		return null;
	}
	
	/**
	 * Returns the first occurrence of an entity whose id matches <code>x</code> or null if no entity was found.
	 */
	public function findParentById(x:Dynamic):Entity
	{
		var n = node.parent, e;
		while (n != null)
		{
			e = n.val;
			if (e.id == x) return e;
			n = n.parent;
		}
		return null;
	}
	
	/**
	 * Returns the first occurrence of an entity whose class matches <code>x</code> or null if no entity was found.
	 */
	public function findParentByClass<T>(x:Class<T>):T
	{
		var c:Class<Dynamic>;
		var n = node.parent, e;
		while (n != null)
		{
			e = n.val;
			c = e._getClass();
			if (c == x) return cast e;
			n = n.parent;
		}
		return null;
	}
	
	public function getObservable():Observable
	{
		if (_observable == null)
			_observable = new Observable();
		return _observable;
	}
	
	public function attach(o:IObserver, mask = 0):Void
	{
		getObservable().attach(o, mask);
	}
	
	public function detach(o:IObserver, mask = 0):Void
	{
		getObservable().detach(o, mask);
	}
	
	public function notify(type:Int, userData:Dynamic = null):Void
	{
		getObservable().notify(type, userData);
	}
	
	public function update(type:Int, source:IObservable, userData:Dynamic):Void
	{
	}
	
	/**
	 * Sends a message <code>x</code> to all ancestors of this node.<br/>
	 * Bubbling can be aborted by calling <code>stopPropagation()</code>.
	 */
	public function liftMessage(x:String, userData:Dynamic = null):Void
	{
		var n = node.parent, e;
		while (n != null)
		{
			e = n.val;
			if (e._hasFlag(BIT_PENDING_ADD | BIT_PENDING_REMOVE | BIT_COMMIT_SUICIDE)) break;
			e._clrFlag(BIT_STOP_PROPAGATION);
			e.onMessage(x, userData);
			if (e._hasFlag(BIT_STOP_PROPAGATION)) break;
			n = n.parent;
		}
	}
	
	/**
	 * Sends a message <code>x</code> to all descendants of this node.<br/>
	 * Bubbling can be aborted by calling <code>stopPropagation()</code>.
	 */
	public function dropMessage(x:String, userData:Dynamic = null):Void
	{
		var n = node.children, e;
		while (n != null)
		{
			e = n.val;
			if (e._hasFlag(BIT_PENDING_ADD | BIT_PENDING_REMOVE | BIT_COMMIT_SUICIDE))
			{
				n = n.next;
				continue;
			}
			
			e._clrFlag(BIT_STOP_PROPAGATION);
			e.onMessage(x, userData);
			if (e._hasFlag(BIT_STOP_PROPAGATION)) break;
			e.dropMessage(x, userData);
			n = n.next;
		}
	}
	
	/**
	 * Sends a message <code>x</code> to all siblings of this node.<br/>
	 * Bubbling can be aborted by calling <code>stopPropagation()</code>.
	 */
	public function slipMessage(x:String, userData:Dynamic = null):Void
	{
		var n = node.prev, e;
		while (n != null)
		{
			e = n.val;
			if (e._hasFlag(BIT_PENDING_ADD | BIT_PENDING_REMOVE | BIT_COMMIT_SUICIDE))
			{
				n = n.prev;
				continue;
			}
			
			e._clrFlag(BIT_STOP_PROPAGATION);
			e.onMessage(x, userData);
			if (e._hasFlag(BIT_STOP_PROPAGATION)) return;
			n = n.prev;
		}
		
		n = node.next;
		while (n != null)
		{
			e = n.val;
			if (e._hasFlag(BIT_PENDING_ADD | BIT_PENDING_REMOVE | BIT_COMMIT_SUICIDE))
			{
				n = n.next;
				continue;
			}
			e._clrFlag(BIT_STOP_PROPAGATION);
			e.onMessage(x, userData);
			if (e._hasFlag(BIT_STOP_PROPAGATION)) return;
			n = n.next;
		}
	}
	
	public function toString():String
	{
		if (format != null) return format(this);
		
		if (priority != Limits.UINT16_MAX)
			return Sprintf.format('[id=%s #c=%d, p=%02d%s]', [Std.string(id), node.numChildren(), priority, _hasFlag(BIT_PENDING_ADD | BIT_PENDING_REMOVE) ? ' p' : '']);
		else
			return Sprintf.format('[id=%s #c=%d%s]', [Std.string(id), node.numChildren(), _hasFlag(BIT_PENDING_ADD | BIT_PENDING_REMOVE) ? ' p' : '']);
	}
	
	/**
	 * Invoked by <code>free()</code> on all children,
	 * giving each one the opportunity to perform some cleanup (override for implementation).
	 */
	function onFree():Void {}
	
	/**
	 * Invoked after this entity was attached to the <code>parent</code> entity (override for implementation).
	 */
	function onAdd(parent:Entity):Void {}

	/**
	 * Invoked after an <code>ancestor</code> was added (override for implementation).
	 */
	function onAddAncestor(ancestor:Entity):Void {}
	
	/**
	 * Invoked after a <code>descendant</code> was added (override for implementation).
	 */
	function onAddDescendant(child:Entity):Void {}
	
	/**
	 * Invoked after an entity somewhere next to this entity was added (override for implementation).
	 */
	function onAddSibling(sibling:Entity):Void {}
	
	/**
	 * Invoked after this entity was removed from its <code>parent</code> entity (override for implementation).
	 */
	function onRemove(parent:Entity):Void {}
	
	/**
	 * Invoked after an <code>ancestor</code> was removed (override for implementation).
	 */
	function onRemoveAncestor(ancestor:Entity):Void {}
	
	/**
	 * Invoked after a <code>descendant</code> was removed (override for implementation).
	 */
	function onRemoveDescendant(descendant:Entity):Void {}
	
	/**
	 * Invoked after an entity somewhere next to this entity was removed (override for implementation).
	 */
	function onRemoveSibling(sibling:Entity):Void {}
	
	/**
	 * Updates this entity (override for implementation).
	 */
	function onAdvance(dt:Float, parent:Entity):Void {}
	
	/**
	 * Renders this entity (override for implementation).
	 */
	function onRender(alpha:Float, parent:Entity):Void {}
	
	/**
	 * Receives a <code>message</code> (override for implementation).
	 */
	function onMessage(message:String, userData:Dynamic):Void {}
	
	function _addChild(child:Entity):Void
	{
		//mark as added
		child._setFlag(BIT_ADDED);
		
		//register child with parent
		child._preOnAdd(this);
		
		//for each node in the subtree rooted at child (inclusive child):
		//- invoke x.onAddAncestor(this);
		//- invoke this.onAddDescendant(x)
		child._propagateAddParentSubtree(node.val);
		child._propagateAddChildSubtree(this);
		
		//invoke onAddSibling() for each sibling of child
		var n = node.children, e;
		while (n != null)
		{
			if (n != child.node)
			{
				e = n.val;
				if (e._hasFlag(BIT_ADDED))
				{
					e.onAddSibling(child);
					child.onAddSibling(e);
				}
			}
			n = n.next;
		}
	}
	
	function _propagateAddParentSubtree(p:Entity):Void
	{
		if (!_hasFlag(BIT_PENDING_ADD))
			_preOnAddAncestor(p);
		var n = node.children, e;
		while (n != null)
		{
			e = n.val;
			if (!e._hasFlag(BIT_PENDING_ADD))
				e._propagateAddParentSubtree(p);
			n = n.next;
		}
	}
	
	function _propagateAddParentPendingSubtree(p:Entity):Void
	{
		if (_hasFlag(BIT_PROCESS))
		{
			_propagateAddParentSubtree(p);
			return;
		}
		var n = node.children, e;
		while (n != null)
		{
			e = n.val;
			if (!e._hasFlag(BIT_PENDING_ADD))
				e._propagateAddParentPendingSubtree(p);
			n = n.next;
		}
	}
	
	function _propagateAddChildSubtree(p:Entity):Void
	{
		if (!p._hasFlag(BIT_PENDING_ADD))
			p._preOnAddDescendant(this);
		var n = node.children, e;
		while (n != null)
		{
			e = n.val;
			if (!e._hasFlag(BIT_PENDING_ADD))
				e._propagateAddChildSubtree(p);
			n = n.next;
		}
	}
	
	function _propagateAddChildPendingSubtree(p:Entity):Void
	{
		if (_hasFlag(BIT_PROCESS))
		{
			_propagateAddChildSubtree(p);
			return;
		}
		var n = node.children, e;
		while (n != null)
		{
			e = n.val;
			e._propagateAddChildPendingSubtree(p);
			n = n.next;
		}
	}
	
	function _preOnAdd(parent:Entity):Void
	{
		onAdd(parent);
	}
	
	function _preOnAddAncestor(ancestor:Entity):Void
	{
		onAddAncestor(ancestor);
	}
	
	function _preOnAddDescendant(descendant:Entity):Void
	{
		onAddDescendant(descendant);
	}
	
	function _removeChild(child:Entity):Void
	{
		//mark as removed
		child._setFlag(BIT_REMOVED);
		
		//register child with parent
		child._preOnRemove(this);
		
		//for each node in the subtree rooted at child (inclusive child):
		//- invoke x.onRemoveParent(this);
		//- invoke this.onRemoveChild(x)
		child._propagateRemoveParentSubtree(node.val);
		child._propagateRemoveChildSubtree(this);
		
		//invoke onRemoveSibling() for each sibling of child
		var n = node.children, e;
		while (n != null)
		{
			if (n != child.node)
			{
				e = n.val;
				if (!e._hasFlag(BIT_REMOVED))
				{
					e.onRemoveSibling(child);
					child.onRemoveSibling(e);
				}
			}
			n = n.next;
		}
	}
	
	function _propagateRemoveParentSubtree(p:Entity):Void
	{
		if (!_hasFlag(BIT_PENDING_REMOVE))
			_preOnRemoveAncestor(p);
		var n = node.children, e;
		while (n != null)
		{
			e = n.val;
			if (!e._hasFlag(BIT_PENDING_REMOVE))
				e._propagateRemoveParentSubtree(p);
			n = n.next;
		}
	}
	
	function _propagateRemoveParentPendingSubtree(p:Entity):Void
	{
		if (_hasFlag(BIT_PROCESS))
		{
			_propagateRemoveParentSubtree(p);
			return;
		}
		var n = node.children, e;
		while (n != null)
		{
			e = n.val;
			if (!e._hasFlag(BIT_PENDING_REMOVE))
				e._propagateRemoveParentPendingSubtree(p);
			n = n.next;
		}
	}
	
	function _propagateRemoveChildSubtree(p:Entity):Void
	{
		if (!p._hasFlag(BIT_PENDING_REMOVE))
			p._preOnRemoveDescendant(this);
		var n = node.children, e;
		while (n != null)
		{
			e = n.val;
			if (!e._hasFlag((BIT_PENDING_REMOVE)))
				e._propagateRemoveChildSubtree(p);
			n = n.next;
		}
	}
	
	function _propagateRemoveChildPendingSubtree(p:Entity):Void
	{
		if (_hasFlag(BIT_PROCESS))
		{
			_propagateRemoveChildSubtree(p);
			return;
		}
		var n = node.children, e;
		while (n != null)
		{
			e = n.val;
			e._propagateRemoveChildPendingSubtree(p);
			n = n.next;
		}
	}
	
	function _preOnRemove(parent:Entity):Void
	{
		onRemove(parent);
	}
	
	function _preOnRemoveAncestor(ancestor:Entity):Void
	{
		onRemoveAncestor(ancestor);
	}
	
	function _preOnRemoveDescendant(descendant:Entity):Void
	{
		onRemoveDescendant(descendant);
	}
	
	function _propagateAdvance(timeDelta:Float, parent:Entity):Void
	{
		D.assert(node != null, 'node != null');
		var n = node.children, e;
		while (n != null)
		{
			e = n.val;
			if (e._hasFlag(BIT_PENDING_ADD | BIT_PENDING_REMOVE | BIT_COMMIT_SUICIDE))
			{
				n = n.next;
				continue;
			}
			e._clrFlag(BIT_STOP_PROPAGATION);
			if (e._hasFlag(BIT_ADVANCE)) e.onAdvance(timeDelta, parent);
			if (e._doSubtree()) e._propagateAdvance(timeDelta, e);
			n = n.next;
		}
	}
	
	function _propagateRender(alpha:Float, parent:Entity):Void
	{
		D.assert(node != null, 'node != null');
		var n = node.children, hook, e;
		while (n != null)
		{
			e = n.val;
			if (e._hasFlag(BIT_PENDING_ADD | BIT_PENDING_REMOVE | BIT_COMMIT_SUICIDE))
			{
				n = n.next;
				continue;
			}
			e._clrFlag(BIT_STOP_PROPAGATION);
			if (e._hasFlag(BIT_RENDER)) e.onRender(alpha, parent);
			if (e._doSubtree()) e._propagateRender(alpha, e);
			n = n.next;
		}
	}
	
	function _sortChildrenCompare(a:Entity, b:Entity)
	{
		return a.priority - b.priority;
	}
	
	function _free()
	{
		var tmp = node;
		node.postorder
		(
			function(n, u)
			{
				var e = n.val;
				if (e._observable != null)
				{
					e._observable.free();
					e._observable = null;
				}
				e._class = null;
				e.node = null;
				e.onFree();
				return true;
			});
		
		//destroy tree
		tmp.free();
	}
	
	function _isDirty()
	{
		if (_hasFlag(BIT_PENDING_ADD | BIT_PENDING_REMOVE)) return true;
		var n = node.children;
		while (n != null)
		{
			if (n.val._isDirty())
				return true;
			n = n.next;
		}
		return false;
	}
	
	inline function _doSubtree()
	{
		return _flags & (BIT_STOP_PROPAGATION | BIT_PROCESS_SUBTREE) == BIT_PROCESS_SUBTREE;
	}
	
	inline function _hasFlag(x:Int)
	{
		return _flags & x > 0;
	}
	
	inline function _setFlag(x:Int)
	{
		_flags |= x;
	}
	
	inline function _clrFlag(x:Int)
	{
		_flags &= ~x;
	}
	
	inline function _getClass():Class<Entity>
	{
		if (_class == null)
			_class = Type.getClass(this);
		return _class;
	}
}