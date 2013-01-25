/*
 * PickRenderer.as
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
	import com.yogurt3d.YOGURT3D_INTERNAL;
	import com.yogurt3d.Yogurt3D;
	import com.yogurt3d.core.Scene3D;
	import com.yogurt3d.core.Viewport;
	import com.yogurt3d.core.geoms.IMesh;
	import com.yogurt3d.core.geoms.SkeletalAnimatedMesh;
	import com.yogurt3d.core.geoms.SkinnedSubMesh;
	import com.yogurt3d.core.geoms.SubMesh;
	import com.yogurt3d.core.managers.DeviceStreamManager;
	import com.yogurt3d.core.managers.MaterialManager;
	import com.yogurt3d.core.material.Y3DProgram;
	import com.yogurt3d.core.objects.EngineObject;
	import com.yogurt3d.core.render.renderqueue.RenderQueue;
	import com.yogurt3d.core.render.renderqueue.RenderQueueNode;
	import com.yogurt3d.core.sceneobjects.SceneObjectRenderable;
	import com.yogurt3d.core.sceneobjects.camera.Camera3D;
	import com.yogurt3d.utils.MatrixUtils;
	
	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DClearMask;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTriangleFace;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.VertexBuffer3D;
	import flash.events.Event;
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;

	/**
	 * 
	 * 
 	 * @author Yogurt3D Engine Core Team
 	 * @company Yogurt3D Corp.
 	 **/
	public class PickRenderer extends EngineObject implements IRenderer
	{
		private static var m_materialManager		:MaterialManager 	  = MaterialManager.instance;
		private var vsManager						:DeviceStreamManager  = DeviceStreamManager.instance;	
		
		private var m_initialized					:Boolean 		= false;
		private var m_viewMatrix					:Matrix3D		= new Matrix3D();
		private var m_modelViewMatrix				:Matrix3D		= new Matrix3D();
		private var m_tempMatrix					:Matrix3D 		= MatrixUtils.TEMP_MATRIX;
		
		private var shader							:PassHitObject;		
		private var shaderTriangle					:PassHitTriangle;
	
		private var m_bitmapData					:BitmapData;
		
		private var m_viewportData					:Vector.<Number> = new Vector.<Number>( 4, true );
		private var m_boundScale					:Vector.<Number> = new Vector.<Number>( 4, true );
		private var m_boundOffset					:Vector.<Number> = new Vector.<Number>( 4, true );
		
		private var m_mouseCoordX					:Number;
		private var m_mouseCoordY					:Number;
		
		private var m_lastHit						:SceneObjectRenderable;
		private var m_localHitPosition				:Vector3D;
		private var m_viewport						:Viewport;
		
		public function PickRenderer(_viewport:Viewport, _initInternals:Boolean=true)
		{
			super(_initInternals);
			m_viewport = _viewport;
		}
		
		public function get localHitPosition():Vector3D
		{
			return m_localHitPosition;
		}
		
		public function set localHitPosition(value:Vector3D):void
		{
			m_localHitPosition = value;
		}
		
		public function get lastHit():SceneObjectRenderable
		{
			return m_lastHit;
		}
		
		public function set lastHit(value:SceneObjectRenderable):void
		{
			m_lastHit = value;
		}
		
		public function get mouseCoordY():Number
		{
			return m_mouseCoordY;
		}
		
		public function set mouseCoordY(value:Number):void
		{
			m_mouseCoordY = value;
		}
		
		public function get mouseCoordX():Number
		{
			return m_mouseCoordX;
		}
		
		public function set mouseCoordX(value:Number):void
		{
			m_mouseCoordX = value;
		}
		
		private function initHandler( _e:Event ):void{
			m_initialized = false;
		}
		
		protected override function initInternals():void{
			shader = new PassHitObject();
			shaderTriangle = new PassHitTriangle();
			
			m_bitmapData = new BitmapData( 1, 1, false, 0x00000000 );
		}
	
		public function render( device:Context3D, _scene:Scene3D=null, _camera:Camera3D=null, rect:Rectangle=null, excludeList:Array = null ):void
		{		
			var _renderableObject:SceneObjectRenderable;
			var _mesh:IMesh;
			var _vertexBuffer:VertexBuffer3D;
			var submeshlen:uint;
			var subMeshIndex:uint;
			var program:Y3DProgram;
			var _submesh:SubMesh;
			
			var boneIndex:int;
			var originalBoneIndex:uint;
			
			var renderableCount:uint = 0;
			device = Viewport.YOGURT3D_INTERNAL::m_pickDevice;
					
			// foe each renderable object loop
			var _renderableSet:RenderQueue = _scene.getRenderableSet();
			if(_renderableSet)
				renderableCount = _renderableSet.getRenderableCount();
					
			m_lastHit = null;
				
			m_viewport.stage.stage3Ds[3].x = -50;
			m_viewport.stage.stage3Ds[3].y = -50;
			//m_viewport.stage.stage3Ds[3].addEventListener( Event.CONTEXT3D_CREATE, initHandler );
			
			if( !m_initialized)
			{
				device.configureBackBuffer(50, 50, 0, true);
				m_initialized = true;
			}
			
			// clean buffer
			
			device.clear(0,0,0,0);
			device.setScissorRectangle( new Rectangle( 0,0,1,1 ) );
			device.setCulling( Context3DTriangleFace.FRONT );
			
			// disable blending
			device.setBlendFactors( "one", "zero");
			device.setColorMask( true, true, true, true);
			device.setDepthTest( true, Context3DCompareMode.LESS );
			
			// viewport data that is used to shift the canvas under the mouse to 0,0 coordinates
			m_viewportData[2] = rect.width ;
			m_viewportData[3] = rect.height;
			m_viewportData[0] = 1 - ( m_mouseCoordX / rect.width ) * 2;
			m_viewportData[1] = ( m_mouseCoordY / rect.height ) * 2 - 1;
			
			// upload the viewport data
			device.setProgramConstantsFromVector( Context3DProgramType.VERTEX, shader.gen.VC["Viewport"].index, m_viewportData, 1 );
			
			m_viewMatrix.copyFrom( _camera.transformation.matrixGlobal );
			m_viewMatrix.invert();
			m_viewMatrix.append(_camera.frustum.projectionMatrix);
			
			var head:RenderQueueNode = _renderableSet.getHead();
			for(var i:int = 0;  head != null; i++, head = head.next )
			{
				_renderableObject = head.scn;
		
				if( !_renderableObject.interactive ) continue;
			
				if( _renderableObject.geometry == null ) continue;
				
				// calculate model view prrojection matrix
				m_modelViewMatrix.copyFrom( _renderableObject.transformation.matrixGlobal );	
				m_modelViewMatrix.append( m_viewMatrix );
				
				// upload modelViewProjectionMatrix
				device.setProgramConstantsFromMatrix( Context3DProgramType.VERTEX, shader.gen.VC["MVP"].index, m_modelViewMatrix, true );
				
				// set the selection index to objects' position on the renderable set plus one
				var selectionIndex:uint = i + 1;
				
				// split the selection index into 4 floating points
				device.setProgramConstantsFromVector( Context3DProgramType.FRAGMENT, shader.gen.FC["SIndex"].index, Vector.<Number>([
					(((selectionIndex) % 32) << 3) / 255.0, 
					(((selectionIndex>>5) % 32) << 3) / 255.0, 
					(((selectionIndex>>10) % 32) << 3) / 255.0, 1
				]), 1 );
				
				// for each submesh 
				submeshlen = _renderableObject.geometry.subMeshList.length;
				
				for( subMeshIndex = 0; subMeshIndex < submeshlen; subMeshIndex++ )
				{
					_submesh = _renderableObject.geometry.subMeshList[subMeshIndex];
					
					// get program// Hit Object
					program = shader.getProgram( device, _renderableObject, null );
				
					// get program
					if( program != m_materialManager.YOGURT3D_INTERNAL::m_lastProgram)
					{
						device.setProgram( program.program);
						m_materialManager.YOGURT3D_INTERNAL::m_lastProgram = program;
					}
					
					// set vertex streams
					
					vsManager.markVertex(device);
					// position
					vsManager.setStream( device,  shader.vertexInput.vertexpos.index ,_submesh.getPositonBufferByContext3D(device), 0 , Context3DVertexBufferFormat.FLOAT_3);// VA0
					
					// if skinned upload bone matrices
					if( _submesh is SkinnedSubMesh )
					{
						// bone data
						var skinnedSubmesh:SkinnedSubMesh = _submesh as SkinnedSubMesh;
						var buffer:VertexBuffer3D = skinnedSubmesh.getBoneDataBufferByContext3D(device);
						vsManager.setStream( device,  shader.vertexInput.boneData.index,   buffer, 0, Context3DVertexBufferFormat.FLOAT_4 );
						vsManager.setStream( device,  shader.vertexInput.boneData.index+1, buffer, 4, Context3DVertexBufferFormat.FLOAT_4 );
						vsManager.setStream( device,  shader.vertexInput.boneData.index+2, buffer, 8, Context3DVertexBufferFormat.FLOAT_4 );
						vsManager.setStream( device,  shader.vertexInput.boneData.index+3, buffer, 12,Context3DVertexBufferFormat.FLOAT_4 );
						
						//normal
						vsManager.setStream( device,  shader.vertexInput.normal.index, _submesh.getNormalBufferByContext3D(device),0, Context3DVertexBufferFormat.FLOAT_3);
						
						for( boneIndex = 0; boneIndex < SkinnedSubMesh(_submesh).originalBoneIndex.length; boneIndex++)
						{	
							originalBoneIndex = SkinnedSubMesh(_submesh).originalBoneIndex[boneIndex];
							m_tempMatrix.copyFrom( SkeletalAnimatedMesh(_renderableObject.geometry).bones[originalBoneIndex].transformationMatrix );
							device.setProgramConstantsFromVector( Context3DProgramType.VERTEX, shader.gen.VC["BoneMatrices"].index + (boneIndex*3), m_tempMatrix.rawData, 3 );
							vsManager.sweepVertex(device);
						}
						
					}
					vsManager.sweepVertex(device);
					// draw
					device.drawTriangles( _submesh.getIndexBufferByContext3D( device ), 0, _submesh.triangleCount );
				}
			}
			
			// draw single pixel to bitmap
			device.drawToBitmapData( m_bitmapData );
			
			// get selection color code
			var selectedIndexColor:uint = m_bitmapData.getPixel( 0,0 );
			// find selected object index
			var red:uint 	= (selectedIndexColor>>16) & 0xFF;
			var green:uint 	= (selectedIndexColor>>8) & 0xFF;
			var blue:uint 	= (selectedIndexColor) & 0xFF;
			var selectedIndex:uint = (( red / 8.0 )) +  (( green / 8.0 ) << 5) +  (( blue / 8.0 ) << 10);
						
			if( selectedIndex != 0 && 
				selectedIndex <= renderableCount && 
				_renderableSet && 
				_renderableSet.getNodeAt( selectedIndex - 1) &&
				(_renderableSet.getNodeAt( selectedIndex - 1).scn) &&
				(_renderableSet.getNodeAt( selectedIndex - 1).scn).interactive ){
				
				m_lastHit = _renderableSet.getNodeAt( selectedIndex - 1).scn;
				
			}else{
				m_lastHit = null;
			}
			
	
			// if an object is picked
			if( m_lastHit )
			{
				device.clear( 0, 0, 0, 0, 1, 0, Context3DClearMask.DEPTH );
				
				_renderableObject = m_lastHit;
				
				var scX:Number;
				var scY:Number;
				var scZ:Number;
				var offsX:Number, offsY:Number, offsZ:Number;
			
				var max:Vector3D = new Vector3D();
				var min:Vector3D = new Vector3D();
				// for each submesh 
				submeshlen = _renderableObject.geometry.subMeshList.length;
				for( subMeshIndex = 0; subMeshIndex < submeshlen; subMeshIndex++ )
				{
					_submesh = _renderableObject.geometry.subMeshList[subMeshIndex];
					
					//_submesh.axisAlignedBoundingBox.update( new Matrix3D() );
					
					if( subMeshIndex == 0 )
					{
						max.copyFrom( _submesh.axisAlignedBoundingBox.maxGlobal );
						min.copyFrom(_submesh.axisAlignedBoundingBox.minGlobal);
					}else{
						if( _submesh.axisAlignedBoundingBox.maxGlobal.x > max.x )	{max.x = _submesh.axisAlignedBoundingBox.maxGlobal.x}
						if( _submesh.axisAlignedBoundingBox.maxGlobal.y > max.y )	{max.y = _submesh.axisAlignedBoundingBox.maxGlobal.y}
						if( _submesh.axisAlignedBoundingBox.maxGlobal.z > max.z )	{max.z = _submesh.axisAlignedBoundingBox.maxGlobal.z}
						if( _submesh.axisAlignedBoundingBox.minGlobal.x < min.x )	{min.x = _submesh.axisAlignedBoundingBox.minGlobal.x}
						if( _submesh.axisAlignedBoundingBox.minGlobal.y < min.y )	{min.y = _submesh.axisAlignedBoundingBox.minGlobal.y}
						if( _submesh.axisAlignedBoundingBox.minGlobal.z < min.z )	{min.z = _submesh.axisAlignedBoundingBox.minGlobal.z}
					}
				}
				
				m_boundScale[0] = scX = 1 / (max.x - min.x);	m_boundScale[1] = scY = 1 / (max.y - min.y);	m_boundScale[2] = scZ = 1 / (max.z - min.z);
				m_boundOffset[0] = offsX = -min.x;	m_boundOffset[1] = offsY = -min.y;	m_boundOffset[2] = offsZ = -min.z;
				
				m_modelViewMatrix.copyFrom( _renderableObject.transformation.matrixGlobal );
				m_modelViewMatrix.append( m_viewMatrix );

				device.setDepthTest( false, Context3DCompareMode.ALWAYS );
				device.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, shaderTriangle.gen.VC["ModelView"].index, m_modelViewMatrix, true);
				device.setProgramConstantsFromVector(Context3DProgramType.VERTEX, shaderTriangle.gen.VC["Viewport"].index, m_viewportData, 1 );
				device.setProgramConstantsFromVector(Context3DProgramType.VERTEX, shaderTriangle.gen.VC["BoundOff"].index, m_boundOffset, 1);
				device.setProgramConstantsFromVector(Context3DProgramType.VERTEX, shaderTriangle.gen.VC["BoundScale"].index, m_boundScale, 1);
				
				for( subMeshIndex = 0; subMeshIndex < submeshlen; subMeshIndex++ )
				{
					_submesh = _renderableObject.geometry.subMeshList[subMeshIndex];
					
					program = shaderTriangle.getProgram( device, _renderableObject, null );
					// get program
					if( program != m_materialManager.YOGURT3D_INTERNAL::m_lastProgram)
					{
						device.setProgram( program.program);
						m_materialManager.YOGURT3D_INTERNAL::m_lastProgram = program;
					}
				
					// set vertex streams
					// position
					vsManager.markVertex(device);
					vsManager.setStream( device,  shaderTriangle.vertexInput.vertexpos.index ,_submesh.getPositonBufferByContext3D(device), 0 , Context3DVertexBufferFormat.FLOAT_3);// VA0
					
					// if skinned upload bone matrices
					if( _submesh is SkinnedSubMesh )
					{
						// bone data
						skinnedSubmesh = _submesh as SkinnedSubMesh;
						buffer = skinnedSubmesh.getBoneDataBufferByContext3D(device);
						vsManager.setStream( device,  shaderTriangle.vertexInput.boneData.index,   buffer, 0, Context3DVertexBufferFormat.FLOAT_4 );
						vsManager.setStream( device,  shaderTriangle.vertexInput.boneData.index+1, buffer, 4, Context3DVertexBufferFormat.FLOAT_4 );
						vsManager.setStream( device,  shaderTriangle.vertexInput.boneData.index+2, buffer, 8, Context3DVertexBufferFormat.FLOAT_4 );
						vsManager.setStream( device,  shaderTriangle.vertexInput.boneData.index+3, buffer, 12,Context3DVertexBufferFormat.FLOAT_4 );
						
						//normal
						vsManager.setStream( device,  shader.vertexInput.normal.index, _submesh.getNormalBufferByContext3D(device),0, Context3DVertexBufferFormat.FLOAT_3);
						
						
						for( boneIndex = 0; boneIndex < SkinnedSubMesh(_submesh).originalBoneIndex.length; boneIndex++)
						{	
							originalBoneIndex = SkinnedSubMesh(_submesh).originalBoneIndex[boneIndex];
							m_tempMatrix.copyFrom( SkeletalAnimatedMesh(_renderableObject.geometry).bones[originalBoneIndex].transformationMatrix );
							device.setProgramConstantsFromVector( Context3DProgramType.VERTEX, shaderTriangle.gen.VC["BoneMatrices"].index + (boneIndex*3), m_tempMatrix.rawData, 3 );
						}
					}
					// draw
					vsManager.sweepVertex(device);
					device.drawTriangles( _submesh.getIndexBufferByContext3D( device ), 0, _submesh.triangleCount );
				}
				
				device.drawToBitmapData( m_bitmapData );
				
				var col:uint = m_bitmapData.getPixel(0, 0);
				
				localHitPosition = new Vector3D();
				
				localHitPosition.x = ((col >> 16) & 0xFF) / (scX*255) - offsX;
				localHitPosition.y = ((col >> 8)  & 0xFF) / (scY*255) - offsY;
				localHitPosition.z = (col 		  & 0xFF) / (scZ*255) - offsZ;
			}	
	
			device.present();
			
			//device.configureBackBuffer( rec0t.width, rect.height, 16, true);
		}
	
	}
}
import com.yogurt3d.core.material.Y3DProgram;
import com.yogurt3d.core.material.agalgen.IRegister;
import com.yogurt3d.core.material.parameters.FragmentInput;
import com.yogurt3d.core.material.parameters.VertexInput;
import com.yogurt3d.core.material.parameters.VertexOutput;
import com.yogurt3d.core.material.pass.Pass;
import com.yogurt3d.core.sceneobjects.SceneObjectRenderable;
import com.yogurt3d.core.sceneobjects.lights.Light;
import com.yogurt3d.utils.ShaderUtils;

import flash.display3D.Context3D;
import flash.display3D.Context3DCompareMode;
import flash.display3D.Context3DProgramType;
import flash.display3D.Context3DTriangleFace;
import flash.utils.ByteArray;

class PassHitObject extends Pass{
	
	public function PassHitObject(){
		
		m_surfaceParams.blendEnabled 		= false;
		m_surfaceParams.writeDepth 			= true;
		m_surfaceParams.depthFunction 		= Context3DCompareMode.LESS;
		m_surfaceParams.colorMaskEnabled	= false;
		m_surfaceParams.culling 			= Context3DTriangleFace.FRONT;
		
		gen.createVC("Viewport",1);
		gen.createVC("MVP",4);
		gen.createVC("BoneMatrices",4);
		gen.createFC("SIndex");
	}
	
	public override function getVertexShader(isSkeletal:Boolean):ByteArray{
		var input:VertexInput = m_vertexInput = new VertexInput(gen);
		var out:VertexOutput = m_vertexOutput;
		var code:String;
		
		var vt0:IRegister = gen.createVT("vt00", 4);
		var vt1:IRegister = gen.createVT("vt01", 4);
		
		if( isSkeletal )
		{
		
			code = ShaderUtils.getSkeletalAnimationVertexShader( 
				input.vertexpos.index, 0, input.normal.index, 
				input.boneData.index, input.boneData.index + 2, 
				gen.VC["MVP"].index, 0, gen.VC["BoneMatrices"].index, 
				0, false, false, false);
			
			code = code.replace("m44 vt0, vt0, vc0\n", "");
			code = code.replace("m44 op, vt0, vc1\n", "");
			code += [
				"//****After Vertex Anim****/",
				gen.code("m44", vt0, vt0, "vc"+ gen.VC["MVP"].index),
				gen.code("mul", vt1.xy, vt0.w, gen.VC["Viewport"].xy),
				gen.code("add", vt0.xy, vt0.xy, vt1.xy),
				gen.code("mul", vt0.xy, vt0.xy, gen.VC["Viewport"].zw),
				gen.code("mov", "op", vt0)

			].join("\n");
				
		}else{
		
			code = [
				gen.code("m44", vt0, input.vertexpos, gen.VC["MVP"]),
				gen.code("mul", vt1.xy, vt0.w, gen.VC["Viewport"].xy),
				gen.code("add", vt0.xy, vt0.xy, vt1.xy),
				gen.code("mul", vt0.xy, vt0.xy, gen.VC["Viewport"].zw),
				gen.code("mov", "op", vt0)
			].join("\n");
		
		}
		gen.destroyVT("vt00");
		gen.destroyVT("vt01");
		
//		trace("PICK MANAGER-HIT OBJECT VERTEX");
//		trace(gen.printCode(code));
//		trace("END PICK MANAGER VERTEX");
		return ShaderUtils.vertexAssambler.assemble(Context3DProgramType.VERTEX, code, false );
	}
	
	public override function getFragmentShader(_light:Light):ByteArray{
		
		gen.destroyAllTmp();
		m_vertexOutput = new FragmentInput(gen);
		
		var code:String = gen.code("mov", "oc", gen.FC["SIndex"]);
		
//		trace("PICK MANAGER-HIT OBJECT FRAGMENT");
//		trace(gen.printCode(code));
//		trace("END PICK MANAGER FRAGMENT");
		
		return ShaderUtils.fragmentAssambler.assemble(Context3DProgramType.FRAGMENT, code, false );
	}
}


class PassHitTriangle extends Pass{
	
	public function PassHitTriangle(){
		
		m_surfaceParams.blendEnabled 		= false;
		m_surfaceParams.writeDepth 			= true;
		m_surfaceParams.depthFunction 		= Context3DCompareMode.LESS;
		m_surfaceParams.colorMaskEnabled	= false;
		m_surfaceParams.culling 			= Context3DTriangleFace.NONE;
		
		gen.createVC("Viewport",1);
		gen.createVC("ModelView",4);
		gen.createVC("BoundOff",1);
		gen.createVC("BoundScale", 1);
		gen.createVC("BoneMatrices",4);
	}
	
	public override function getVertexShader(isSkeletal:Boolean):ByteArray{
		var input:VertexInput = m_vertexInput = new VertexInput(gen);
		var out:VertexOutput = m_vertexOutput;
		var code:String;
		var vt0:IRegister = gen.createVT("vt00", 4);
		var vt1:IRegister = gen.createVT("vt01", 4);
		
		if( isSkeletal )
		{
			code = ShaderUtils.getSkeletalAnimationVertexShader( 
				input.vertexpos.index, 0, 0, 
				input.boneData.index, input.boneData.index+2, 
				gen.VC["ModelView"].index, gen.VC["Viewport"].index, gen.VC["BoneMatrices"].index, 
				0  , false, false, false);
			
			code += [
				"//****After Vertex Anim****/",
				gen.code("add", vt0, input.vertexpos, gen.VC["BoundOff"]),
				gen.code("mul", vt0, vt0, gen.VC["BoundScale"]),
				gen.code("mov", "v0", vt0),			
			].join("\n");
				
		}else{
			code = [
				gen.code("add", vt0, input.vertexpos, gen.VC["BoundOff"]),
				gen.code("mul", vt0, vt0, gen.VC["BoundScale"]),
				gen.code("mov", "v0", vt0),
				gen.code("m44", vt0, input.vertexpos, gen.VC["ModelView"]),
				gen.code("mul", vt1.xy, vt0.w,gen.VC["Viewport"].xy),
				gen.code("add", vt0.xy, vt0.xy, vt1.xy),
				gen.code("mul", vt0.xy, vt0.xy, gen.VC["Viewport"].zw),
				gen.code("mov", "op", vt0)
			].join("\n");
			
		}
		
		gen.destroyVT("vt00");
		gen.destroyVT("vt01");
		
//		trace("PICK MANAGER-HIT TRIANGLE VERTEX");
//		trace(gen.printCode(code));
//		trace("END PICK MANAGER VERTEX");
		return ShaderUtils.vertexAssambler.assemble(Context3DProgramType.VERTEX, code, false );
	}
	
	public override function getFragmentShader(_light:Light):ByteArray{
		
		gen.destroyAllTmp();
		m_vertexOutput = new FragmentInput(gen);
		
		var code:String = gen.code("mov", "oc", "v0");
		
//		trace("PICK MANAGER-HIT TRIANGLE FRAGMENT");
//		trace(gen.printCode(code));
//		trace("END PICK MANAGER FRAGMENT");
		
		return ShaderUtils.fragmentAssambler.assemble(Context3DProgramType.FRAGMENT, code, false );
	}
}