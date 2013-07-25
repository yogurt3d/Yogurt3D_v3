/*
* DeviceStreamManager.as
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

package com.yogurt3d.core.managers
{
import com.yogurt3d.YOGURT3D_INTERNAL;
import com.yogurt3d.core.texture.CubeTextureMap;
import com.yogurt3d.core.texture.ITexture;
import com.yogurt3d.core.texture.TextureMap;

import flash.display3D.Context3D;
import flash.display3D.Context3DMipFilter;
import flash.display3D.Context3DTextureFilter;
import flash.display3D.Context3DWrapMode;
import flash.display3D.Context3DWrapMode;
import flash.display3D.VertexBuffer3D;
import flash.display3D.textures.CubeTexture;
import flash.display3D.textures.Texture;
import flash.display3D.textures.TextureBase;
import flash.utils.Dictionary;

public final class DeviceStreamManager
	{
		private static var m_instance				:DeviceStreamManager;
		
		private var m_contextBufferAllocation		:Dictionary ;
		private var m_contextSamplerAllocation		:Dictionary ;
		
		private var m_lastMarkVB					:int;
		private var m_lastMarkS						:int;

        private var m_textures:Dictionary;

        private var m_cullMode:String = "";

		public function DeviceStreamManager(enforcer:SingletonEnforcer)
		{
			m_contextBufferAllocation = new Dictionary();
			m_contextSamplerAllocation = new Dictionary();
            m_textures = new Dictionary();
		}
		
		public static function get instance():DeviceStreamManager{
			if( m_instance == null )
			{
				m_instance = new DeviceStreamManager(new SingletonEnforcer());
			}
			return m_instance;
		}
		
		[Inline]
		public function markVertex( device:Context3D ):void{
			if( m_contextBufferAllocation[device] == null )
			{
				m_contextBufferAllocation[device] = -1;
			}
			m_lastMarkVB = m_contextBufferAllocation[device];
			m_contextBufferAllocation[device] = -1;
			
		}
		
		[Inline]
		public function sweepVertex( device:Context3D ):void{
			while( m_contextBufferAllocation[device] < m_lastMarkVB && m_lastMarkVB>0 )
			{
				device.setVertexBufferAt( --m_lastMarkVB, null );
			}
		}
		
		[Inline]
		public function markTexture( device:Context3D ):void{
			if( m_contextSamplerAllocation[device] == null )
			{
				m_contextSamplerAllocation[device] = -1;
			}
			m_lastMarkS = m_contextSamplerAllocation[device];
			m_contextSamplerAllocation[device] = -1;
		}
		
		[Inline]
		public function sweepTexture( device:Context3D ):void{
			while( m_contextSamplerAllocation[device] < m_lastMarkS && m_lastMarkS > 0 )
			{
				device.setTextureAt( --m_lastMarkS, null );
                m_textures[m_lastMarkS] = null;
			}
		}
		
		[Inline]
		public function clearAllTextures( device:Context3D ):void{
            if(m_textures[0]!=null){
			    device.setTextureAt( 0, null );
                m_textures[0] = null;}
            if(m_textures[1]!=null){
			    device.setTextureAt( 1, null );
                m_textures[1] = null;}
            if(m_textures[2]!=null){
			    device.setTextureAt( 2, null );
                m_textures[2] = null;}
            if(m_textures[3]!=null){
			    device.setTextureAt( 3, null );
                m_textures[3] = null;}
            if(m_textures[4]!=null){
			    device.setTextureAt( 4, null );
                m_textures[4] = null;}
            if(m_textures[5]!=null){
			    device.setTextureAt( 5, null );
                m_textures[5] = null;}
            if(m_textures[6]!=null){
			    device.setTextureAt( 6, null );
                m_textures[6] = null;}
            if(m_textures[7]!=null){
			    device.setTextureAt( 7, null );
                m_textures[7] = null;}

            m_contextSamplerAllocation[device] = -1;

		}
		/*public function cleanVertexBuffers(device:Context3D):void{
			if( m_contextBufferAllocation[device] > -1 )
			{
				for( var i:uint = 0; i < m_contextBufferAllocation[device] ; i++)
				{
					device.setVertexBufferAt( i, null );
				}
				m_contextBufferAllocation[device] = -1;
			}
		}*/
		[Inline]
		public function setStream( _context3d:Context3D, index:uint, buffer:VertexBuffer3D, bufferOffset:uint = 0, format:String = "float4" ):void{
			if(m_contextBufferAllocation[_context3d] < index+1 )
			{
				m_contextBufferAllocation[_context3d] = index+1;
			}
			_context3d.setVertexBufferAt( index, buffer, bufferOffset, format );
		}
		
		[Inline]
		public function setTexture( device:Context3D, index:uint, texture:ITexture ):void{
			if(m_contextSamplerAllocation[device] < index+1 )
			{
				m_contextSamplerAllocation[device] = index+1;
			}
            if( m_textures[index] != texture){
                device.setTextureAt( index, texture.getTextureForDevice(device) );
                device.setSamplerStateAt(index,(texture is CubeTextureMap)?Context3DWrapMode.CLAMP:Context3DWrapMode.REPEAT,Context3DTextureFilter.LINEAR,(texture is TextureMap && TextureMap(texture).mipmap)?Context3DMipFilter.MIPLINEAR:Context3DMipFilter.MIPNONE);
                m_textures[index] = texture;
            }
        }
        [Inline]
        public function setCullMode( _device:Context3D, cullMode:String):void{
            if( m_cullMode != cullMode ){
                _device.setCulling(cullMode);
                m_cullMode = cullMode;
            }
        }
	}
}
internal class SingletonEnforcer {}