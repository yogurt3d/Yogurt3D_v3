/*
* RenderQueue.as
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
	import com.yogurt3d.Yogurt3D;
	import com.yogurt3d.core.managers.IDManager;
	import com.yogurt3d.core.material.MaterialBase;
	import com.yogurt3d.YOGURT3D_INTERNAL;
	import com.yogurt3d.core.objects.EngineObject;
	import com.yogurt3d.core.sceneobjects.SceneObjectRenderable;
	
	import flash.utils.Dictionary;

	public class RenderQueue extends EngineObject
	{
		private var m_subQueues						:Vector.<SubRenderQueue>;
		private var m_renderLayerSubQueueIndex		:Dictionary;
		
		private var m_background					:SubRenderQueue;
		private var m_opaque						:SubRenderQueue;
		private var m_alphakill						:SubRenderQueue;
		private var m_alpha							:SubRenderQueue;
		private var m_overlay						:SubRenderQueue;
		
		public function RenderQueue()
		{
			super();
			addSubRenderQueue(m_overlay = new SubRenderQueue(), 3000 );
			addSubRenderQueue(m_alpha = new SubRenderQueue(), 2000 );
			addSubRenderQueue(m_alphakill = new SubRenderQueue(), 1000 );
			addSubRenderQueue(m_opaque = new SubRenderQueue(), 0 );
			addSubRenderQueue(m_background = new SubRenderQueue(), -4000 );
			
//			Yogurt3D.onPostRender.addWithPriority(onPostRender, int.MAX_VALUE-1);
		}
		
	/*	private function onPostRender():void{
			clear();
		}*/
		
		public function clear():void{
			for( var i:int = 0; i < m_subQueues.length; i++)
			{
				m_subQueues[i].clear();
			}
		}
		
		protected override function trackObject():void
		{
			IDManager.trackObject(this, RenderQueue);
		}
		
		public override function renew():void{
			
		}
		
		public function addRenderable( scnObj:SceneObjectRenderable ):void{
			if(scnObj == null || scnObj.visible == false || scnObj.material == null ) return;
			
			if( !m_renderLayerSubQueueIndex.hasOwnProperty(scnObj.renderLayer ) )
			{
				addSubRenderQueue(new SubRenderQueue(), scnObj.renderLayer);
				//trace("if 1: addSubRenderQueue");
			}
			
			if( scnObj.renderLayer != 0 )
			{
				var layerIndex:int = m_renderLayerSubQueueIndex[scnObj.renderLayer];
				var queue:SubRenderQueue = m_subQueues[layerIndex];
				queue.addRenderable( scnObj );
				
				//trace("if 2: addSubRenderQueue", m_subQueues[layerIndex]);
			}else{
				var mat:MaterialBase = scnObj.material;
				if(mat.transparent )
				{
					m_alpha.addRenderable(scnObj);
				//	trace("if 3: Material Transparency");
				}else 
					if( mat.cutOff )
				{
					m_alphakill.addRenderable(scnObj);
				//	trace("if 4: Alpha Kill");
				}else{
					m_opaque.addRenderable(scnObj);
					
				//	trace("if 5: Opaque");
				}
			}
		}
		
		protected function addSubRenderQueue(subQueue:SubRenderQueue, layerIndex:int):void{
			subQueue.YOGURT3D_INTERNAL::index = layerIndex;
			var insertIndex:int = 0;
			for( var i:int = 0; i<m_subQueues.length; i++ )
			{
				if( layerIndex < m_subQueues[i].YOGURT3D_INTERNAL::index ){
					break;
				}
			}
			m_subQueues.splice( i, 0, subQueue );
			for( i = 0; i < m_subQueues.length; i++ )
			{
				m_renderLayerSubQueueIndex[m_subQueues[i].YOGURT3D_INTERNAL::index] = i;
			}
		}
		
		protected override function initInternals():void{
			m_renderLayerSubQueueIndex = new Dictionary();
			m_subQueues = new Vector.<SubRenderQueue>();
		}
		
		public function getNodeAt( index:uint ):RenderQueueNode{
			if(index != 0){
				for( var i:int = 0, count:uint = 0; (count = m_subQueues[i].count) < index; i++, index -= count ){}
				return m_subQueues[i].YOGURT3D_INTERNAL::getNodeAt( index );
			}
			else
				return getHead();
		}
		
		public function getHead():RenderQueueNode{
			var head:RenderQueueNode;
			for( var i:int = 0; i < m_subQueues.length - 1; i++ )
			{
				if( m_subQueues[i].count > 0 )
				{
					m_subQueues[i].YOGURT3D_INTERNAL::tail.next = m_subQueues[i+1].YOGURT3D_INTERNAL::head;
					if( head == null )
					{
						head = m_subQueues[i].YOGURT3D_INTERNAL::head;
					}
				}
			}
			return head;
		}
		
		public function getRenderableCount():uint{
			var c:uint = 0;
			for( var i:int = 0; i < m_subQueues.length - 1; i++ )
			{
				c+=m_subQueues[i].count;
			}
			return c;
		}
	}
}