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
	import flash.display3D.Context3D;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.TextureBase;
	import flash.utils.Dictionary;

	public final class DeviceStreamManager
	{
		private static var m_instance				:DeviceStreamManager;
		
		private var m_contextBufferAllocation		:Dictionary ;
		private var m_contextSamplerAllocation		:Dictionary ;
		
		private var m_lastMarkVB					:int;
		private var m_lastMarkS						:int;
		
		public function DeviceStreamManager(enforcer:SingletonEnforcer)
		{
			m_contextBufferAllocation = new Dictionary();
			m_contextSamplerAllocation = new Dictionary();
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
			}
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
		public function setTexture( _context3d:Context3D, index:uint, texture:TextureBase ):void{
			if(m_contextSamplerAllocation[_context3d] < index+1 )
			{
				m_contextSamplerAllocation[_context3d] = index+1;
			}
			_context3d.setTextureAt( index, texture );
		}
	}
}
internal class SingletonEnforcer {}