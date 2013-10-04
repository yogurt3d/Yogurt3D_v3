/*
* RenderCubeTexture.as
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
import com.yogurt3d.core.render.texture.base.RenderTextureTargetBase;

public class RenderCubeTexture extends RenderTextureTargetBase
	{
		public function RenderCubeTexture()
		{
			super();
			priority = 150;
		}
		
		public override function render():void{
		//	trace("[RenderCubeTexture][render] start");
			// create cube texture if needed
			// set render target to  cube texture
			
			// render scene for each face
			renderer.render(m_device, m_scene, m_camera, m_currentBackBufferRect);
			renderer.render(m_device, m_scene, m_camera, m_currentBackBufferRect);
			renderer.render(m_device, m_scene, m_camera, m_currentBackBufferRect);
			renderer.render(m_device, m_scene, m_camera, m_currentBackBufferRect);
			renderer.render(m_device, m_scene, m_camera, m_currentBackBufferRect);
			renderer.render(m_device, m_scene, m_camera, m_currentBackBufferRect);
			
		//	trace("[RenderCubeTexture][render] end");
		}
        public override function get dirty():Boolean{
            return true;
        }
	}
}