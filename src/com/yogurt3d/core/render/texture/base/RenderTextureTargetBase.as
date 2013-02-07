/*
* RenderTextureTargetBase.as
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

package com.yogurt3d.core.render.texture.base
{
import com.yogurt3d.core.render.base.RenderTargetBase;
import com.yogurt3d.core.texture.ITexture;

import flash.display3D.Context3D;
import flash.display3D.textures.TextureBase;
import flash.utils.Dictionary;

public class RenderTextureTargetBase extends RenderTargetBase implements ITexture
	{
		public var overrideToFront				:Boolean = false;
		public var overrideToBack				:Boolean = false;
		public var priority						:uint = 0;
		
		private var m_context3DMap				:Dictionary;
		
		public function RenderTextureTargetBase()
		{
			super();
			m_newBackBufferRect.width = m_newBackBufferRect.height = 512;
			m_context3DMap = new Dictionary(true);
		}
		
		public override function render():void{
			throw new Error();
		}
		
		protected function mapTextureForContext( texture:TextureBase, device:Context3D ):void
		{
			if( m_context3DMap[ device ] && m_context3DMap[ device ] != texture)
			{
				m_context3DMap[ device ].dispose();
			}
			m_context3DMap[ device ] = texture;
		}
		
		protected function hasTextureForDevice( device:Context3D ):Boolean{
			return m_context3DMap[ device ]!=null;
		}
		
		public function getTextureForDevice( device:Context3D ):TextureBase
		{
			return m_context3DMap[ device ];
		}
	}
}