/*
* DirectionalPass.as
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

package com.yogurt3d.core.material.pass
{
	import com.yogurt3d.YOGURT3D_INTERNAL;
	import com.yogurt3d.core.geoms.IMesh;
	import com.yogurt3d.core.geoms.SkinnedSubMesh;
	import com.yogurt3d.core.geoms.SubMesh;
	import com.yogurt3d.core.managers.DeviceStreamManager;
	import com.yogurt3d.core.material.Y3DProgram;
	import com.yogurt3d.core.material.enum.EBlendMode;
	import com.yogurt3d.core.sceneobjects.SceneObjectRenderable;
	import com.yogurt3d.core.sceneobjects.camera.Camera3D;
	import com.yogurt3d.core.sceneobjects.lights.Light;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.VertexBuffer3D;
	
	public class DirectionalPass extends Pass
	{
		public function DirectionalPass()
		{
			super();
		}
		
		public override function render(_object:SceneObjectRenderable, 
										_light:Light, _device:Context3D, _camera:Camera3D):void{
			// handle base pass
			var _vsManager:DeviceStreamManager = DeviceStreamManager.instance;
			m_currentLight = _light;
			var program:Y3DProgram = getProgram(_device, _object, _light);
			_device.setProgram( program.program );
			EBlendMode.ADD.setToDevice(_device);
			_device.setColorMask( m_surfaceParams.colorMaskR, m_surfaceParams.colorMaskG, m_surfaceParams.colorMaskB, m_surfaceParams.colorMaskA);
			_device.setDepthTest( m_surfaceParams.writeDepth, m_surfaceParams.depthFunction );
			_device.setCulling( m_surfaceParams.culling );
			
			preRender(_device, _object, _camera);
			
			var mesh:IMesh = _object.geometry;
			
			for( var submeshindex:uint = 0; submeshindex < mesh.subMeshList.length; submeshindex++ )
			{
				// Move to VertexStreamManager START
				var subMesh:SubMesh = mesh.subMeshList[submeshindex];
				if( m_vertexInput.YOGURT3D_INTERNAL::m_vertexpos )
				{
					_vsManager.setStream( _device,  m_vertexInput.YOGURT3D_INTERNAL::m_vertexpos.index, subMesh.getPositonBufferByContext3D(_device),0, Context3DVertexBufferFormat.FLOAT_3);
				}
				if( m_vertexInput.YOGURT3D_INTERNAL::m_normal )
				{
					_vsManager.setStream( _device,  m_vertexInput.YOGURT3D_INTERNAL::m_normal.index, subMesh.getNormalBufferByContext3D(_device),0, Context3DVertexBufferFormat.FLOAT_3);
				}
				if( m_vertexInput.YOGURT3D_INTERNAL::m_tangent )
				{
					_vsManager.setStream( _device,  m_vertexInput.YOGURT3D_INTERNAL::m_tangent.index, subMesh.getTangentBufferByContext3D(_device),0, Context3DVertexBufferFormat.FLOAT_3);
				}
				if( m_vertexInput.YOGURT3D_INTERNAL::m_uvMain )
				{
					_vsManager.setStream( _device,  m_vertexInput.YOGURT3D_INTERNAL::m_uvMain.index, subMesh.getUVBufferByContext3D(_device),0, Context3DVertexBufferFormat.FLOAT_2);
				}
				if( m_vertexInput.YOGURT3D_INTERNAL::m_uvSecond )
				{
					_vsManager.setStream( _device,  m_vertexInput.YOGURT3D_INTERNAL::m_uvSecond.index, subMesh.getUV2BufferByContext3D(_device),0, Context3DVertexBufferFormat.FLOAT_2);
				}
				if( m_vertexInput.YOGURT3D_INTERNAL::m_boneData )
				{
					var skinnedSubmesh:SkinnedSubMesh = subMesh as SkinnedSubMesh;
					var buffer:VertexBuffer3D = skinnedSubmesh.getBoneDataBufferByContext3D(_device);
					_vsManager.setStream( _device, m_vertexInput.YOGURT3D_INTERNAL::m_boneData.index, buffer, 0, Context3DVertexBufferFormat.FLOAT_4 );
					_vsManager.setStream( _device, m_vertexInput.YOGURT3D_INTERNAL::m_boneData.index+1, buffer, 4, Context3DVertexBufferFormat.FLOAT_4 );
					_vsManager.setStream( _device, m_vertexInput.YOGURT3D_INTERNAL::m_boneData.index+2, buffer, 8, Context3DVertexBufferFormat.FLOAT_4 );
					_vsManager.setStream( _device, m_vertexInput.YOGURT3D_INTERNAL::m_boneData.index+3, buffer, 12,Context3DVertexBufferFormat.FLOAT_4 );
					_vsManager.setStream( _device,  m_vertexInput.YOGURT3D_INTERNAL::m_normal.index, subMesh.getNormalBufferByContext3D(_device),0, Context3DVertexBufferFormat.FLOAT_3);
				}
				// Move to VertexStreamManager END
				_device.drawTriangles(subMesh.getIndexBufferByContext3D(_device), 0, subMesh.triangleCount);
			}
			
			postRender(_device);
		}
	}
}