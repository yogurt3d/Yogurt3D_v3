/*
* PPPriorityList.as
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

package com.yogurt3d.utils
{
	import com.yogurt3d.core.sceneobjects.camera.Camera3D;
	import com.yogurt3d.core.render.post.PostProcessingEffectBase;
	import com.yogurt3d.core.render.texture.RenderTexture;
	import com.yogurt3d.core.Scene3D;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.TextureBase;
	import flash.geom.Rectangle;
	
	public class PPPriorityList
	{
		private var m_list:Vector.<PostProcessingEffectBase>;
		
		public function PPPriorityList()
		{
			m_list = new Vector.<PostProcessingEffectBase>();
		}
		
		public function get length():uint{
			return m_list.length;
		}
		
		public function add( value:PostProcessingEffectBase ):void{
			if( value.overrideToFront )
			{
				$addToFront( value );
			}
			else if( value.overrideToBack ){
				$addToBack( value );
			}else{
				$add( value );
			}
		}
		
		public function removeAll():void{
			m_list.splice(0, m_list.length);
		}
		
		public function remove( value:PostProcessingEffectBase ):void{
			var index:uint;
			if( (index = m_list.indexOf( value ) ) != -1 )
			{
				m_list.splice(index,1);
			}
		}
		
		public function removeByIndex( value:uint ):void{
		}
		
		private var tempTarget:TextureBase;
		public function updateAll( device:Context3D, scene:Scene3D, camera:Camera3D, drawRect:Rectangle, rtt:RenderTexture ):void{
			
			//VertexStreamManager.instance.cleanVertexBuffers(device);
			//trace("[PostProcessing][updateAll] start");
			var lastTexture:TextureBase;
			var len:uint;
			if( tempTarget == null)
			{
				tempTarget = device.createTexture(drawRect.width,drawRect.height,Context3DTextureFormat.BGRA, true);
			}
			
			for( var i:int = 0; i < m_list.length; i++ )
			{
				
				var post:PostProcessingEffectBase = m_list[i];
				post.device = device;
				post.scene = scene;
				post.camera = camera;
				post.drawRect = drawRect;
				len = post.effects.length;
				
				for( var j:int = 0; j < len; j++ )
				{
					
					if( lastTexture == null )
					{
						post.sampler = rtt.getTextureForDevice( device );
					}else{
						post.sampler = lastTexture;
					}
					
					if( j ==  len - 1 && i == m_list.length - 1 ){
						device.setRenderToBackBuffer();
					}else{
						device.setRenderToTexture( tempTarget );
						
					}
						
					// render
					post.effects[j].render(device, post);
					
					if(  i != m_list.length - 1){
						lastTexture = tempTarget;
						tempTarget = post.sampler;
					}else if(j != len - 1){
						lastTexture = tempTarget;
						tempTarget = post.sampler;
					}
				}

			}
			
			tempTarget = null;
			//lastTexture = null;
		//	trace("[PostProcessing][updateAll] end");
		}
		
		private function $add( value:PostProcessingEffectBase ):void{
			for( var i:int = 0; i < m_list.length; i++ )
			{
				var rtt:PostProcessingEffectBase = m_list[i];
				if( rtt.overrideToFront ) continue;
				if( rtt.priority > value.priority ){
					m_list.splice( i, 0, value );
					return;
				}
				if( rtt.overrideToBack ){
					m_list.splice( i, 0, value );
				}
			}
			m_list.splice( i, 0, value );
		}
		
		private function $addToFront( value:PostProcessingEffectBase ):void{
			for( var i:int = 0; i < m_list.length; i++ )
			{
				var rtt:PostProcessingEffectBase = m_list[i];
				if( !rtt.overrideToFront || (rtt.overrideToFront && rtt.priority > value.priority) ){
					m_list.splice( i, 0, value );
					return;
				}
			}
		}
		
		private function $addToBack( value:PostProcessingEffectBase ):void{
			for( var i:int = m_list.length - 1; i >= 0 ; i-- )
			{
				var rtt:PostProcessingEffectBase = m_list[i];
				if( !rtt.overrideToBack || (rtt.overrideToBack && rtt.priority < value.priority) ){
					m_list.splice( i, 0, value );
					return;
				}
			}
		}
	}
}