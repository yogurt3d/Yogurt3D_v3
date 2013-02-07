package com.yogurt3d.presets.material
{
import com.yogurt3d.core.material.MaterialBase;
import com.yogurt3d.core.sceneobjects.SceneObjectRenderable;
import com.yogurt3d.core.sceneobjects.camera.Camera3D;
import com.yogurt3d.core.sceneobjects.lights.Light;

import flash.display3D.Context3D;

public class MaterialDepth extends MaterialBase
	{
		private var m_pass:PassDepth;
		public function MaterialDepth()
		{
			super(false);
			m_pass = new PassDepth();
		}
		
		public override function set vertexFunction(value:Function):void
		{
			if( value != null )
			{
				m_vertexFunction = value;
			}else{
				m_vertexFunction = emptyFunction;
			}
			m_pass.vertexFunction = m_vertexFunction;
		}
		
		public override function render(_object:SceneObjectRenderable, 
										_lights:Vector.<Light>, _device:Context3D, _camera:Camera3D):void
		{		
			
			m_pass.render(_object, null, _device,_camera);
			
		}
	}
}

import com.yogurt3d.YOGURT3D_INTERNAL;
import com.yogurt3d.core.geoms.IMesh;
import com.yogurt3d.core.geoms.SkeletalAnimatedMesh;
import com.yogurt3d.core.geoms.SkinnedSubMesh;
import com.yogurt3d.core.geoms.SubMesh;
import com.yogurt3d.core.material.Y3DProgram;
import com.yogurt3d.core.material.agalgen.IRegister;
import com.yogurt3d.core.material.enum.ERegisterShaderType;
import com.yogurt3d.core.material.parameters.FragmentInput;
import com.yogurt3d.core.material.parameters.VertexInput;
import com.yogurt3d.core.material.parameters.VertexOutput;
import com.yogurt3d.core.material.pass.Pass;
import com.yogurt3d.core.sceneobjects.SceneObjectRenderable;
import com.yogurt3d.core.sceneobjects.camera.Camera3D;
import com.yogurt3d.core.sceneobjects.lights.Light;
import com.yogurt3d.utils.ShaderUtils;

import flash.display3D.Context3D;
import flash.display3D.Context3DProgramType;
import flash.display3D.Context3DVertexBufferFormat;
import flash.display3D.VertexBuffer3D;
import flash.utils.ByteArray;

class PassDepth extends Pass{
	
	public function PassDepth(){
		
		createConstantFromVector( ERegisterShaderType.FRAGMENT, "constantF1", Vector.<Number>([ 1.0, ((1.0/(255.0)) as Number),255.0, 0.5]));
		createConstantFromVector( ERegisterShaderType.VERTEX, "constantV1", Vector.<Number>([ 0.5, 0.0, 0.0, 0.0]));
		
		createConstantFromVectorFunction(ERegisterShaderType.VERTEX, 
			"cameraPlanes", function():Vector.<Number>{
				var near:Number = m_currentCamera.frustum.near;
				var far:Number = m_currentCamera.frustum.far;
				
				return Vector.<Number>([ near, far, 0.5, 1]);
			});
		
	}
	public override function uploadConstants(device:Context3D):void{
		device.setProgramConstantsFromVector( Context3DProgramType.FRAGMENT, m_constants["constantF1"].register.index, m_constants["constantF1"].vec );
		device.setProgramConstantsFromVector( Context3DProgramType.VERTEX, m_constants["constantV1"].register.index, m_constants["constantV1"].vec );
		device.setProgramConstantsFromVector( Context3DProgramType.VERTEX, m_constants["cameraPlanes"].register.index, m_constants["cameraPlanes"].callFunction() );
	}
	
	protected override function preRender(device:Context3D, _object:SceneObjectRenderable, _camera:Camera3D):void{
		
		device.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, gen.VC["Model"].index, _object.transformation.matrixGlobal, true );
		device.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, gen.VC["ViewProjection"].index, _camera.viewProjectionMatrix, true );
//		TODO BONE MATRICES
		m_currentCamera = _camera;
		m_vsManager.markTexture(device);
		uploadConstants(device);
		m_vsManager.sweepTexture(device);
	}
	
	public override function render(_object:SceneObjectRenderable, _light:Light, _device:Context3D, _camera:Camera3D):void{
		m_currentLight = _light;
		
		var program:Y3DProgram = getProgram(_device, _object, _light);
		
		if( program != m_materialManager.YOGURT3D_INTERNAL::m_lastProgram)
		{
			_device.setProgram( program.program );
			m_materialManager.YOGURT3D_INTERNAL::m_lastProgram = program;
		}
		
		preRender(_device, _object, _camera);
		
		var _mesh:IMesh = _object.geometry;
		for( var submeshindex:uint = 0; submeshindex < _mesh.subMeshList.length; submeshindex++ )
		{
			var subMesh:SubMesh = _mesh.subMeshList[submeshindex];
			
			m_vsManager.markVertex(_device);
			
			m_vsManager.setStream( _device,  m_vertexInput.YOGURT3D_INTERNAL::m_vertexpos.index, subMesh.getPositonBufferByContext3D(_device),0, Context3DVertexBufferFormat.FLOAT_3);
			m_vsManager.setStream( _device,  m_vertexInput.YOGURT3D_INTERNAL::m_normal.index, subMesh.getNormalBufferByContext3D(_device),0, Context3DVertexBufferFormat.FLOAT_3);
			
		
			if( subMesh is SkinnedSubMesh)
			{
				var skinnedSubmesh:SkinnedSubMesh = subMesh as SkinnedSubMesh;
				var buffer:VertexBuffer3D = skinnedSubmesh.getBoneDataBufferByContext3D(_device);
								
				m_vsManager.setStream( _device, m_vertexInput.boneData.index,   buffer, 0, Context3DVertexBufferFormat.FLOAT_4 );
				m_vsManager.setStream( _device, m_vertexInput.boneData.index+1, buffer, 4, Context3DVertexBufferFormat.FLOAT_4 );
				m_vsManager.setStream( _device, m_vertexInput.boneData.index+2, buffer, 8, Context3DVertexBufferFormat.FLOAT_4 );
				m_vsManager.setStream( _device, m_vertexInput.boneData.index+3, buffer, 12,Context3DVertexBufferFormat.FLOAT_4 );
				
				for( var boneIndex:int = 0; boneIndex < skinnedSubmesh.originalBoneIndex.length; boneIndex++)
				{	
					var originalBoneIndex:uint = skinnedSubmesh.originalBoneIndex[boneIndex];
					_device.setProgramConstantsFromVector( Context3DProgramType.VERTEX, gen.VC["BoneMatrices"].index  + (boneIndex*3), SkeletalAnimatedMesh(_object.geometry).bones[originalBoneIndex].transformationMatrix.rawData, 3 );
				}
						
			}
				
			m_vsManager.sweepVertex(_device);
			_device.drawTriangles(subMesh.getIndexBufferByContext3D(_device), 0, subMesh.triangleCount);
		}
		
		postRender(_device);
		
	}
	
	public override function getVertexShader(isSkeletal:Boolean):ByteArray{
		var input:VertexInput = m_vertexInput = new VertexInput(gen);
		var out:VertexOutput = m_vertexOutput;
		gen.createVC("Model",4);
		gen.createVC("ViewProjection",4);
		
		var code:String;
		
		if(isSkeletal){
			gen.createVC("BoneMatrices",4);
			
			code = ShaderUtils.getSkeletalAnimationVertexShader( 
				input.vertexpos.index, 0, input.normal.index, 
				input.boneData.index, input.boneData.index + 2, // bone ind, bone weight
				gen.VC["ViewProjection"].index, gen.VC["Model"].index, gen.VC["BoneMatrices"].index, //MVP, model, bone matrice
				0, true, false, false  );
			
			code += [
				gen.code("mul", "vt0.z", "vt0.z", "vt0.w"),
				gen.code("div", "vt0.z", "vt0.z", gen.VC["cameraPlanes"].y),
				gen.code("mov", out.worldPos, "vt0"),
				
				gen.code("mul", "vt1.xyz", "vt1.xyz", gen.VC["constantV1"].x),
				gen.code("add", "vt1.xyz", "vt1.xyz", gen.VC["constantV1"].x),
				gen.code("nrm", "vt1.xyz", "vt1.xyz"),
				gen.code("mov", "vt1.w", gen.VC["constantV1"].w),
				gen.code("mov", out.normal, "vt1")
			].join("\n");
		}else{
			var worldPos:IRegister = gen.createVT("worldPos",4);
			
			code = [
				gen.code("m44", "vt1", input.vertexpos, gen.VC["Model"]),
				gen.code("m44", "vt1", "vt1", gen.VC["ViewProjection"]),
				
				gen.code("mov", "vt3", "vt1"),
				gen.code("mul", "vt3.z", "vt1.z", "vt1.w"),
				gen.code("div", "vt3.z", "vt3.z", gen.VC["cameraPlanes"].y),
				gen.code("mov", out.worldPos, "vt3"),
				
				gen.code("m33", "vt2.xyz", input.normal, gen.VC["Model"]),
				
				gen.code("mul", "vt2.xyz", "vt2.xyz", gen.VC["constantV1"].x),
				gen.code("add", "vt2.xyz", "vt2.xyz", gen.VC["constantV1"].x),
				gen.code("nrm", "vt2.xyz", "vt2.xyz"),
				
				gen.code("mov", "vt2.w", gen.VC["constantV1"].w),
				gen.code("mov", out.normal, "vt2"),
				
				// SCREEN POS 
				
				gen.code("mov", "op", "vt1")				
			].join("\n");
		}
		
		//trace("VERTEX .....");
		//trace(gen.printCode(code));
		//trace(".....");
		return ShaderUtils.vertexAssambler.assemble(Context3DProgramType.VERTEX, code, false );
		
	}
	
	public override function getFragmentShader(_light:Light):ByteArray{
		gen.destroyAllTmp();
		m_vertexOutput = new FragmentInput(gen);
		var normal:IRegister 	= m_vertexOutput.normal;
		var v0:IRegister 	= m_vertexOutput.worldPos;
		var ft0:IRegister = gen.createFT("ft0", 4);
		var ft1:IRegister = gen.createFT("ft1", 4);
		var fc0:IRegister = gen.FC["constantF1"];
		
		var code:String = [   
	//		gen.code("mov", "oc", fc0.xxxx)
//			
			gen.code("mov", ft0, normal),
			gen.code("nrm", ft0.xyz, ft0.xyz),
		
			// depth encode - decode	
			gen.code("mul", ft1.z, v0.z, fc0.z),
			
			gen.floorAGAL(ft1.x, ft1.z),//floor (depth*255)
			
			gen.code("div", ft0.z, ft1.x, fc0.z),// floor (depth*255)/255
			gen.code("frc", ft0.w, ft1.z), // frac(depth * 255)
			gen.code("mov", "oc", ft0)

	//		(m_type == "normalDepth")?"mov oc ft0":(m_type == "depth")?"mov oc ft0.zwzw":"mov oc fc0.xyxy"
		].join("\n");
		
		//trace("FRAGMENT .....");
		//trace(gen.printCode(code));
		//trace(".....");
		return ShaderUtils.fragmentAssambler.assemble(Context3DProgramType.FRAGMENT, code, false );
	
	}
}