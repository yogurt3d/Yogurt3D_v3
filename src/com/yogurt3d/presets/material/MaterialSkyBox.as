package com.yogurt3d.presets.material
{
import com.yogurt3d.core.material.MaterialBase;
import com.yogurt3d.core.sceneobjects.SceneObjectRenderable;
import com.yogurt3d.core.sceneobjects.camera.Camera3D;
import com.yogurt3d.core.sceneobjects.lights.Light;
import com.yogurt3d.core.texture.CubeTextureMap;

import flash.display3D.Context3D;

public class MaterialSkyBox extends MaterialBase
	{
		private var m_pass:SkyBoxPass;
		public function MaterialSkyBox(_texture:CubeTextureMap)
		{
			super(false);
			
			m_pass = new SkyBoxPass(_texture);				
		}
				
		public function get texture():CubeTextureMap {
			return m_pass.texture;
		}
		
		public function set texture(value:CubeTextureMap):void{
			m_pass.texture = value;
		}
		
		public override function render(_object:SceneObjectRenderable, 
							   _lights:Vector.<Light>, _device:Context3D, _camera:Camera3D):void
		{
			m_pass.render(_object, null, _device,_camera);
		}
	}
}

import com.yogurt3d.core.material.agalgen.IRegister;
import com.yogurt3d.core.material.enum.EBlendMode;
import com.yogurt3d.core.material.enum.ERegisterShaderType;
import com.yogurt3d.core.material.parameters.ConstantFunctions;
import com.yogurt3d.core.material.parameters.FragmentInput;
import com.yogurt3d.core.material.parameters.VertexInput;
import com.yogurt3d.core.material.parameters.VertexOutput;
import com.yogurt3d.core.material.pass.Pass;
import com.yogurt3d.core.sceneobjects.SceneObjectRenderable;
import com.yogurt3d.core.sceneobjects.camera.Camera3D;
import com.yogurt3d.core.sceneobjects.lights.Light;
import com.yogurt3d.core.texture.CubeTextureMap;
import com.yogurt3d.utils.ShaderUtils;

import flash.display3D.Context3D;
import flash.display3D.Context3DCompareMode;
import flash.display3D.Context3DProgramType;
import flash.display3D.Context3DTriangleFace;
import flash.utils.ByteArray;

class SkyBoxPass extends Pass{
	
	private var m_texture:CubeTextureMap;
	public function SkyBoxPass(_texture:CubeTextureMap=null){
		m_texture = _texture;
		
		m_surfaceParams.blendEnabled 		= false;
		m_surfaceParams.blendMode 			= EBlendMode.NORMAL;
		m_surfaceParams.writeDepth 			= false;
		m_surfaceParams.depthFunction 		= Context3DCompareMode.ALWAYS;
		
		m_surfaceParams.colorMaskEnabled	= true;
		m_surfaceParams.colorMaskR			= true;
		m_surfaceParams.colorMaskG			= true;
		m_surfaceParams.colorMaskB			= true;
		m_surfaceParams.colorMaskA			= false;
		m_surfaceParams.culling 			= Context3DTriangleFace.NONE;
		
		createConstantFromMatrixFunction(ERegisterShaderType.VERTEX, "skybox", ConstantFunctions.SKYBOX_MATRIX_TRANSPOSED, null, true);
		createConstantFromVector(ERegisterShaderType.VERTEX, "constant1", Vector.<Number>([1, 0, 0, 0]));
		createConstantFromTexture(ERegisterShaderType.FRAGMENT, "skyTex", m_texture);
	}
	
	public function get texture():CubeTextureMap {
		return m_texture;
	}
	
	public function set texture(value:CubeTextureMap):void{
		m_texture = value;
		setConstantTex( "skyTex", value );
	}
	
	protected override function preRender(device:Context3D, _object:SceneObjectRenderable, _camera:Camera3D):void{
		m_currentCamera = _camera;
		m_vsManager.markTexture(device);
		uploadConstants(device);
		m_vsManager.sweepTexture(device);
	}
	
	public override function getVertexShader(isSkeletal:Boolean):ByteArray{
		var input:VertexInput = m_vertexInput = new VertexInput(gen);
		var out:VertexOutput = m_vertexOutput;
				
		var vc1:IRegister = gen.VC["skybox"];
		var vc0:IRegister = gen.VC["constant1"];
		var vt0:IRegister = gen.createVT("vt0", 4);
				
		var code:String = [
			//"\n\n//****Vertex Function START****/"+ "\n",
			gen.code("m44", "op", input.vertexpos, vc1),
			gen.code("nrm", vt0.xyz, input.vertexpos.xyz),
			gen.code("mov", vt0.w, vc0.x),
			gen.code("mov", out.uvMain, vt0)
			//"//****Vertex Function END****/\n\n"
		].join("\n");
		
//		trace(code + "\n");
		
		return ShaderUtils.vertexAssambler.assemble(Context3DProgramType.VERTEX, code, false );
	}
	
	public override function getFragmentShader(_light:Light):ByteArray{
		gen.destroyAllTmp();
		m_vertexOutput = new FragmentInput(gen);
		
		var code:String;
		
		var tmp:IRegister = gen.createFT("tmp", 4);
		code += [
			//"//****Fragment START****/",
			gen.tex( tmp, m_vertexOutput.uvMain, getConstant("skyTex"),"cube","clamp","linear"),
			gen.code("mov", "oc" , tmp)
			//"//****Fragment END****/"+ "\n"
		].join("\n");
		
//		trace(code + "\n");
		
		return ShaderUtils.fragmentAssambler.assemble(Context3DProgramType.FRAGMENT, code, false );
	}

}
