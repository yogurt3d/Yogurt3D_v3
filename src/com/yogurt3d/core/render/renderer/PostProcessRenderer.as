/*
* PostProcessRenderer.as
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

package com.yogurt3d.core.render.renderer
{
import com.yogurt3d.core.Scene3D;
import com.yogurt3d.core.managers.DeviceStreamManager;
import com.yogurt3d.core.sceneobjects.camera.Camera3D;

import flash.display3D.Context3D;
import flash.display3D.Context3DVertexBufferFormat;
import flash.display3D.IndexBuffer3D;
import flash.display3D.VertexBuffer3D;
import flash.geom.Rectangle;
import flash.utils.Dictionary;

public class PostProcessRenderer implements IRenderer
	{
		private static var m_vertexBuffer:Dictionary;
		private static var m_indiceBuffer:Dictionary;
		
		public function PostProcessRenderer()
		{
			if( m_vertexBuffer == null )
			{
				m_vertexBuffer = new Dictionary(true);
				m_indiceBuffer = new Dictionary(true);
			}
		}
		
		public function render(device:Context3D, scene:Scene3D=null, camera:Camera3D=null, rect:Rectangle=null , excludeList:Array = null):void
		{
			DeviceStreamManager.instance.markVertex(device);
			// set pos
			DeviceStreamManager.instance.setStream( device, 0, getVertexBuffer(device), 0, Context3DVertexBufferFormat.FLOAT_2 );
			// set uv
			DeviceStreamManager.instance.setStream( device, 1, getVertexBuffer(device), 2, Context3DVertexBufferFormat.FLOAT_2 );
			DeviceStreamManager.instance.sweepVertex(device);
			device.drawTriangles(getIndiceBuffer(device), 0, 2 );	
		}
		
		private function getVertexBuffer(_context3D:Context3D):VertexBuffer3D{
			if( m_vertexBuffer[_context3D] == null )
			{
				m_vertexBuffer[_context3D] = _context3D.createVertexBuffer( 4, 4 ); // 4 vertices, 4 floats per vertex
				m_vertexBuffer[_context3D].uploadFromVector(
					Vector.<Number>(
						[
							// x,y,u,v
							1,1,   1,0,    
							1,-1,  1,1, 
							-1,-1, 0,1, 
							-1,1,  0,0, 
						]
					),0, 4
				);
			}return m_vertexBuffer[_context3D];
		}
		
		private function getIndiceBuffer(_context3D:Context3D):IndexBuffer3D{
			if( m_indiceBuffer[_context3D] == null )
			{
				m_indiceBuffer[_context3D] = _context3D.createIndexBuffer( 6 );
				m_indiceBuffer[_context3D].uploadFromVector( Vector.<uint>( [ 0, 1, 2, 0, 2, 3 ] ), 0, 6 );   
			}return m_indiceBuffer[_context3D];
		}
	}
}