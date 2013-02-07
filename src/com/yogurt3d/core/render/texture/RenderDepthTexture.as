/*
* RenderDepthTexture.as
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

package com.yogurt3d.core.render.texture
{
import com.yogurt3d.core.render.renderer.DepthRenderer;
import com.yogurt3d.core.render.texture.base.RenderTextureTargetBase;

import flash.display3D.Context3D;
import flash.display3D.Context3DTextureFormat;
import flash.display3D.textures.TextureBase;

public class RenderDepthTexture extends RenderTextureTargetBase
	{
		public function RenderDepthTexture()
		{
			super();
			autoUpdate = true;
			overrideToFront = true;
			renderer = new DepthRenderer();
		}
		
		public override function render():void{
	//		trace("[RenderDepthTexture][render] start");
			
			var texture:TextureBase = getTexture(m_device);
			
//			// set render target to texture
			device.setRenderToTexture(texture, true);
			device.clear( m_scene.sceneColor.r, m_scene.sceneColor.g, m_scene.sceneColor.b, m_scene.sceneColor.a);
				
			// render depth of scene
			renderer.render(m_device, m_scene, m_camera, m_currentBackBufferRect);
	//		trace("[RenderDepthTexture][render] end");
		}
		
		private function getTexture(device:Context3D):TextureBase{
			if( hasTextureForDevice(device) == false )
			{
				m_currentBackBufferRect.copyFrom( m_newBackBufferRect );
				var texture:TextureBase = device.createTexture( m_currentBackBufferRect.width, m_currentBackBufferRect.height, Context3DTextureFormat.BGRA, true );
				mapTextureForContext( texture, device );
				
			}else if(!m_newBackBufferRect.equals( m_currentBackBufferRect ) )
			{
				texture = getTextureForDevice(device);
				texture.dispose();
				
				texture = device.createTexture( m_newBackBufferRect.width, m_newBackBufferRect.height, Context3DTextureFormat.BGRA, true );
				mapTextureForContext(texture, device );
				m_currentBackBufferRect.copyFrom( m_newBackBufferRect );
			}
			return getTextureForDevice(device);
		}
	}
}