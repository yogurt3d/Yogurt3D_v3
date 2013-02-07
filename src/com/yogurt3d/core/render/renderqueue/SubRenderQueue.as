/*
* SubRenderQueue.as
* This file is part of Yogurt3D Flash Rendering Engine 
*
* Copyright (C) 2011 - Yogurt3D Corp.
*
* Yogurt3D Flash Rendering Engine is free software; you can redistribute it and/or
* modify it under the terms of the YOGURT3D CLICK-THROUGH AGREEMENT
* License.
* 
* Yogurt3D Flash Rendering Engine is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
* 
* You should have received a copy of the YOGURT3D CLICK-THROUGH AGREEMENT
* License along with this library. If not, see <http://www.yogurt3d.com/yogurt3d/downloads/yogurt3d-click-through-agreement.html>. 
*/

package com.yogurt3d.core.render.renderqueue
{
import com.yogurt3d.YOGURT3D_INTERNAL;
import com.yogurt3d.core.sceneobjects.SceneObjectRenderable;

public class SubRenderQueue
	{
		use namespace YOGURT3D_INTERNAL;
		
		YOGURT3D_INTERNAL var index			:int;
		
		YOGURT3D_INTERNAL var head			:RenderQueueNode;
		YOGURT3D_INTERNAL var tail			:RenderQueueNode;
		
		public var count					:uint;
		private var m_pool					:RenderQueueNodePool = RenderQueueNodePool.instance;
		
		public function SubRenderQueue()	{}
		
		public function addRenderable( scnObj:SceneObjectRenderable ):void{
			if( head == null )
			{
				head = m_pool.object;
				head.scn = scnObj;
				tail = head;
				count = 1;
			}else{
				tail.next = m_pool.object;
				tail = tail.next;
				tail.scn = scnObj;
				count++;
			}
		}
		
		YOGURT3D_INTERNAL function getNodeAt( index:uint ):RenderQueueNode{
			var shead:RenderQueueNode = head;
			for( var i:int = 0; i < index; i++ )
			{
				shead = shead.next;
			}
			return shead;
		}
		
		public function clear():void{
			var tmp:RenderQueueNode;
			while( head )
			{
				tmp = head.next;
				if(head.scn != null)
					m_pool.object = head;
				head = tmp;
			}
			head = null;
			tail = null;
			count = 0;
		}
	}
}