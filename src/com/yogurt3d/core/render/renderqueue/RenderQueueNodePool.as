/*
* RenderQueueNodePool.as
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
	public class RenderQueueNodePool
	{
		public var m_pool					:Vector.<RenderQueueNode>;
		private var m_len					:int;
		
		private static var m_instance		:RenderQueueNodePool;
		
		public static function get instance():RenderQueueNodePool{
			if( m_instance == null )
			{
				m_instance = new RenderQueueNodePool(1000);
			}
			return m_instance;
		}
		
		public function RenderQueueNodePool(size:uint)
		{
			m_pool = new Vector.<RenderQueueNode>(size);
			for( var i:int = 0; i < size; i++){
				m_pool[i] = new RenderQueueNode(null);
			}
			m_len = size-1;
		}
		
		public function get object():RenderQueueNode{
			var i:int = m_len--;
			
			var tmp:RenderQueueNode = m_pool[i];
		//	trace("RenderQueuPool [g]", i);
			return tmp;
		}
		
		public function set object( value:RenderQueueNode ):void{
			value.next = null;
			value.scn = null;
		//	trace("RenderQueuPool [r]", m_len);
			m_pool[m_len++] = value;
		}
	}
}