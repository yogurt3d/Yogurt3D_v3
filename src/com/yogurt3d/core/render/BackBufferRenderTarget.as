/*
* BackBufferRenderTarget.as
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

package com.yogurt3d.core.render
{
import com.yogurt3d.core.render.base.RenderTargetBase;
import com.yogurt3d.core.render.texture.RenderTexture;
import com.yogurt3d.utils.MathUtils;

import flash.display.BitmapData;

public class BackBufferRenderTarget extends RenderTargetBase
	{	
		private var m_renderTexture				:RenderTexture;
		
		public function BackBufferRenderTarget(){}
		
		public override function render():void{
			
			//trace("[BackBufferRenderTarget][render] start");
			if(!m_newBackBufferRect.equals( m_currentBackBufferRect ) || antiAliasingDirty )
			{
				device.configureBackBuffer( m_newBackBufferRect.width, m_newBackBufferRect.height, antiAliasing.value, true );
				m_currentBackBufferRect.copyFrom( m_newBackBufferRect );
			}
			// TODO
			//device.clear(scene.sceneColor.r, scene.sceneColor.g, scene.sceneColor.b, scene.sceneColor.a);
			if( scene.renderTargets.length != 0 )
			{// if scene contains render targets
				// render RTT's
				scene.renderTargets.updateAll(device, scene, camera, drawRect);
				// set render to backbuffer
				device.setRenderToBackBuffer();
			}
			
			if( scene.postEffects.length > 0 )
			{// if scene contains post processing effects
				if( m_renderTexture == null )
				{
					m_renderTexture = new RenderTexture();
				}
				// render to texture
				m_renderTexture.scene = scene;
				m_renderTexture.camera = camera;
				m_renderTexture.device = device;
				m_renderTexture.renderer = this.renderer;
				m_renderTexture.drawRect.width = MathUtils.getClosestPowerOfTwo(drawRect.width);
				m_renderTexture.drawRect.height = MathUtils.getClosestPowerOfTwo(drawRect.height);
				m_renderTexture.render();
				
				//VertexStreamManager.instance.cleanVertexBuffers(device);
				// send rtt to postprocessing effects
				scene.postEffects.updateAll( device, scene, camera, m_renderTexture.drawRect, m_renderTexture);
			}else{ // if the scene does not contain and post processing effects
				// clear backbuffer
				device.clear(scene.sceneColor.r, scene.sceneColor.g, scene.sceneColor.b, scene.sceneColor.a);
				// draw
				m_renderer.render( device, scene, camera, m_currentBackBufferRect );
			}
			
			// flip backbuffer to front buffer
			
			
			device.present();
			
			//trace("[BackBufferRenderTarget][render] end");
		}
		
		public function getBitmapData():BitmapData{
			var bmp:BitmapData = new BitmapData(m_currentBackBufferRect.width, m_currentBackBufferRect.height);
			device.drawToBitmapData(bmp);
			return bmp;
		}
	}
}