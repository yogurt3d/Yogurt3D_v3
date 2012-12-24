/*
* MipmapGenerator.as
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
	import flash.display.*;
	import flash.display3D.textures.CubeTexture;
	import flash.display3D.textures.Texture;
	import flash.geom.*;
	
	public class MipmapGenerator
	{
		private static var _matrix : Matrix = new Matrix();
		private static var _rect : Rectangle = new Rectangle();
		
		public static function generateMipMaps(source : BitmapData, target : Texture, mipmap : BitmapData = null, alpha : Boolean = false) : void
		{
			var w : uint = MathUtils.getClosestPowerOfTwo(source.width),
				h : uint = MathUtils.getClosestPowerOfTwo(source.height);
			var i : uint = 0;
			var regen : Boolean = mipmap != null;
			mipmap ||= new BitmapData(w, h, alpha);
			
			_matrix.a = 1;
			_matrix.d = 1;
			
			_rect.width = w;
			_rect.height = h;
			
			while (w >= 1 || h >= 1) {
				if (alpha) mipmap.fillRect(_rect, 0x00000000);
				mipmap.draw(source, _matrix, null, null, null, true);
				target.uploadFromBitmapData(mipmap, i++);
				if( w == 1 && h == 1 )
				{
					break;
				}else{
					if( w > 1 )
						w >>= 1;
					if( h > 1 )
						h >>= 1;
					_matrix.a *= .5;
					_matrix.d *= .5;
					_rect.width = w;
					_rect.height = h;
				}
				
			}
			
			if (!regen)
				mipmap.dispose();
		}
		
		public static function generateMipMapsCube(source : BitmapData, target : CubeTexture, side:uint, mipmap : BitmapData = null, alpha : Boolean = false) : void
		{
			var w : uint = source.width,
				h : uint = source.height;
			var i : uint;
			var regen : Boolean = mipmap != null;
			mipmap ||= new BitmapData(w, h, alpha);
			
			_matrix.a = 1;
			_matrix.d = 1;
			
			_rect.width = w;
			_rect.height = h;
			
			while (w >= 1 || h >= 1) {
				if (alpha) mipmap.fillRect(_rect, 0);
				mipmap.draw(source, _matrix, null, null, null, true);
				target.uploadFromBitmapData(mipmap,side, i++);
				if( w == 1 && h == 1 )
				{
					break;
				}else{
					if( w > 1 )
						w >>= 1;
					if( h > 1 )
						h >>= 1;
					_matrix.a *= .5;
					_matrix.d *= .5;
					_rect.width = w;
					_rect.height = h;
				}
			}
			
			if (!regen)
				mipmap.dispose();
		}
	}
}