/*
* TextureMapDefaults.as
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

package com.yogurt3d.core.utils
{
	import com.yogurt3d.core.texture.CubeTextureMap;
	import com.yogurt3d.core.texture.ITexture;
	import com.yogurt3d.core.texture.TextureMap;
	
	import flash.display.BitmapData;
	import flash.display.Sprite;

	public class TextureMapDefaults
	{
		private static var m_checkerBoard		:ITexture;
		private static var m_white				:TextureMap;
		private static var m_whitemipmap		:TextureMap;
		private static var m_blackmipmap		:TextureMap;
		private static var m_black				:TextureMap;
		private static var m_blackCube			:CubeTextureMap;
		
		public static function get CHECKER_BOARD():ITexture{
			if( m_checkerBoard == null )
			{
				
				var sprite:Sprite = new Sprite();
				// Box colour 1
				var even:uint = 0xCCCCCC;
				
				// Box colour 2
				var odd:uint = 0x999999;
				
				// Box size
				var size:int = 8;
				
				// number of boxes horizontally
				var nH:int = 64 / size;
				
				// number of boxes vertically
				var nV:int = 64 / size;
				
				// vars to be used in the loops
				var clr:uint;
				var i:uint;
				var j:uint;
				
				// loop vertical
				for (i=0;i<nV;++i)
				{
					// Flip values of Even and Odd colours using Bitwise operations
					even ^= odd;
					odd  ^= even;
					even ^= odd;
					
					// loop horizontal
					for (j=0;j<nH;++j)
					{
						//bitwise modulus
						//check if column is odd or even, then set colour
						clr = j & 1 ? even : odd;
						
						// draw box with previously set colour
						sprite.graphics.beginFill(clr,1);
						sprite.graphics.drawRect(Number(j*size),Number(i*size),size,size);
						sprite.graphics.endFill();
					}
				}
				
				m_checkerBoard = new TextureMap(null,sprite);
			}
			return m_checkerBoard;
		}
		
		public static function get BLACKCUBEMAP():CubeTextureMap{
			if(m_blackCube == null){
				m_blackCube = new CubeTextureMap();
				m_blackCube.setFace(0, new BitmapData(1, 1, false, 0x000000));
				m_blackCube.setFace(1, new BitmapData(1, 1, false, 0x000000));
				m_blackCube.setFace(2, new BitmapData(1, 1, false, 0x000000));
				m_blackCube.setFace(3, new BitmapData(1, 1, false, 0x000000));
				m_blackCube.setFace(4, new BitmapData(1, 1, false, 0x000000));
				m_blackCube.setFace(5, new BitmapData(1, 1, false, 0x000000));
			}
			return m_blackCube;
		}
		public static function get WHITE():TextureMap{
			if( m_white == null )
			{
				m_white = new TextureMap(new BitmapData(1, 1, false, 0xFFFFFF));
			//	m_white.mipmap = true;
			}
			return m_white;
		}
		
		public static function get WHITEMIPMAP():TextureMap{
			if( m_whitemipmap == null )
			{
				m_whitemipmap = new TextureMap(new BitmapData(1, 1, false, 0xFFFFFF));
				m_whitemipmap.mipmap = true;
			}
			return m_whitemipmap;
		}
		
		public static function get BLACKMIPMAP():TextureMap{
			if( m_blackmipmap == null )
			{
				m_blackmipmap = new TextureMap(new BitmapData(1, 1, false, 0x000000));
				m_blackmipmap.mipmap = true;
			}
			return m_blackmipmap;
		}
		
		public static function get BLACK():TextureMap{
			if( m_black == null )
			{
				m_black = new TextureMap(new BitmapData(1, 1, false, 0x000000));
			//	m_white.mipmap = true;
			}
			return m_black;
		}
	}
}