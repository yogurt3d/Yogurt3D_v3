/*
* TextureMapBase.as
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

package com.yogurt3d.core.texture.base
{
	import com.yogurt3d.core.texture.ITexture;
	
	import flash.display3D.Context3D;
	import flash.display3D.textures.TextureBase;
	import flash.utils.Dictionary;
	import com.yogurt3d.YOGURT3D_INTERNAL;

	public class TextureMapBase implements ITexture
	{
		use namespace YOGURT3D_INTERNAL;
		
		YOGURT3D_INTERNAL var m_type				:ETextureType;
		
		YOGURT3D_INTERNAL var m_context3DMap		:Dictionary;
		
		YOGURT3D_INTERNAL var m_width				:uint;
		
		YOGURT3D_INTERNAL var m_height				:uint;
		
		public function TextureMapBase(type:ETextureType)
		{
			m_context3DMap = new Dictionary();
			
			m_type = type;
		}
		
		public function get height():uint
		{
			return YOGURT3D_INTERNAL::m_height;
		}

		public function get width():uint
		{
			return YOGURT3D_INTERNAL::m_width;
		}

		public function get type():ETextureType
		{
			return YOGURT3D_INTERNAL::m_type;
		}

		public function getTextureForDevice(device:Context3D):TextureBase{
			return null;
		}
		
		protected function mapTextureForContext( texture:TextureBase, context:Context3D ):void
		{
			if( m_context3DMap[ context ] && m_context3DMap[ context ] != texture)
			{
				m_context3DMap[ context ].dispose();
			}
			m_context3DMap[ context ] = texture;
		}
		protected function hasTextureForContext( context:Context3D ):Boolean{
			return m_context3DMap[ context ]!=null;
		}
		
		protected function getTextureForContext( context:Context3D ):TextureBase
		{
			return m_context3DMap[ context ];
		}
		
		public function dispose():void{
			for each( var _texture:TextureBase in m_context3DMap )
			{
				_texture.dispose();
			}
			m_context3DMap = null;
		}
	}
}