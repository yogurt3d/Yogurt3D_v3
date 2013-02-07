/*
* Pass.as
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
import com.yogurt3d.core.managers.MaterialManager;
import com.yogurt3d.core.material.MaterialBase;
import com.yogurt3d.core.material.Y3DProgram;
import com.yogurt3d.core.material.agalgen.AGALGEN;
import com.yogurt3d.core.material.agalgen.IRegister;
import com.yogurt3d.core.material.enum.ERegisterShaderType;
import com.yogurt3d.core.material.parameters.FragmentInput;
import com.yogurt3d.core.material.parameters.LightInput;
import com.yogurt3d.core.material.parameters.ShaderParameters;
import com.yogurt3d.core.material.parameters.SurfaceOutput;
import com.yogurt3d.core.material.parameters.VertexInput;
import com.yogurt3d.core.material.parameters.VertexOutput;
import com.yogurt3d.core.sceneobjects.SceneObjectRenderable;
import com.yogurt3d.core.sceneobjects.camera.Camera3D;
import com.yogurt3d.core.sceneobjects.lights.ELightType;
import com.yogurt3d.core.sceneobjects.lights.Light;
import com.yogurt3d.core.texture.ITexture;
import com.yogurt3d.utils.Color;
import com.yogurt3d.utils.ShaderUtils;

import flash.display3D.Context3D;
import flash.display3D.Context3DProgramType;
import flash.display3D.Context3DVertexBufferFormat;
import flash.display3D.VertexBuffer3D;
import flash.geom.Matrix3D;
import flash.utils.ByteArray;
import flash.utils.Dictionary;

public class Pass
	{
		public var lightFunction				:Function 		= MaterialBase.Lambert;
		public var surfaceFunction				:Function 		= MaterialBase.emptyFunction;
		public var vertexFunction				:Function 		= MaterialBase.emptyFunction;
		public var gen							:AGALGEN 		= new AGALGEN();
		
		protected var m_vertexInput				:VertexInput;
		protected var m_constants				:Dictionary;
		protected var m_vertexOutput			:VertexOutput;
		protected var m_program					:Y3DProgram;
		protected var m_surfaceParams			:ShaderParameters;
		protected var m_currentLight			:Light;
		protected var m_currentCamera			:Camera3D;
		
		public var m_textureSamplerDict			:Dictionary;
		
		protected var m_emissiveColor			:Color;
		protected var m_ambientColor			:Color;
		protected var m_diffuseColor			:Color;
		protected var m_specularColor			:Color;
		protected var m_shininess				:Number;
		
		protected var m_vsManager:DeviceStreamManager = DeviceStreamManager.instance;
		
		protected static var m_materialManager:MaterialManager = MaterialManager.instance;
		
		public function Pass()
		{
			
			m_textureSamplerDict = new Dictionary();
			m_constants = new Dictionary();
			m_vertexInput = new VertexInput(gen);
			
			m_surfaceParams = new ShaderParameters();
			
			m_emissiveColor 			= new Color( 0,0,0,1 );
			m_ambientColor  			= new Color( 0,0,0,1 );
			m_diffuseColor  			= new Color( 1,1,1,1 );
			m_specularColor 			= new Color( 1,1,1,1 );
		}
		
		public function get vertexInput():VertexInput
		{
			return m_vertexInput;
		}
		
		public function set vertexInput(value:VertexInput):void
		{
			m_vertexInput = value;
		}
		
		public function get surfaceParams():ShaderParameters
		{
			return m_surfaceParams;
		}
		
		public function set surfaceParams(value:ShaderParameters):void
		{
			m_surfaceParams = value;
		}
		
		public function get shininess():Number
		{
			return m_shininess;
		}
		
		public function get specularColor():Color
		{
			return m_specularColor;
		}
		
		public function get diffuseColor():Color
		{
			return m_diffuseColor;
		}
		
		public function get ambientColor():Color
		{
			return m_ambientColor;
		}
		
		public function get emissiveColor():Color
		{
			return m_emissiveColor;
		}
		
		public function set emissiveColor(_value:Color):void{
			m_emissiveColor = _value;
			
			getConstantVec("yEmmisiveCol")[0] = m_emissiveColor.r;
			getConstantVec("yEmmisiveCol")[1] = m_emissiveColor.g;
			getConstantVec("yEmmisiveCol")[2] = m_emissiveColor.b;
			getConstantVec("yEmmisiveCol")[3] = m_emissiveColor.a;
		}
		
		public function set ambientColor(_value:Color):void{
			m_ambientColor = _value;
			
			getConstantVec("yAmbientCol")[0] = m_ambientColor.r;
			getConstantVec("yAmbientCol")[1] = m_ambientColor.g;
			getConstantVec("yAmbientCol")[2] = m_ambientColor.b;
			getConstantVec("yAmbientCol")[3] = m_ambientColor.a;
		}
		
		public function set diffuseColor(_value:Color):void{
			m_diffuseColor = _value;
			
			getConstantVec("yDiffuseCol")[0] = m_diffuseColor.r;
			getConstantVec("yDiffuseCol")[1] = m_diffuseColor.g;
			getConstantVec("yDiffuseCol")[2] = m_diffuseColor.b;
			getConstantVec("yDiffuseCol")[3] = m_diffuseColor.a;
		}
		
		public function set specularColor(_value:Color):void{
			m_specularColor = _value;
			
			getConstantVec("ySpecCol")[0] = m_specularColor.r;
			getConstantVec("ySpecCol")[1] = m_specularColor.g;
			getConstantVec("ySpecCol")[2] = m_specularColor.b;
			getConstantVec("ySpecCol")[3] = m_specularColor.a;
		}
		
		public function set shininess(_value:Number):void{
			m_shininess = _value;
		}
		
		public function disposeDeep(_materialBase:MaterialBase):void{
			m_materialManager.uncacheProgram(_materialBase, this);
		}
		
		public function getProgram(device:Context3D, _object:SceneObjectRenderable, _light:Light ):Y3DProgram{
			if( m_program == null || !m_materialManager.hasProgram( _object.material, this, _object.geometry.type ))
			{
				if( !m_materialManager.hasProgram( _object.material, this, _object.geometry.type ) )
				{
					m_program = new Y3DProgram();
				//	trace("PASS CREATED", _object.material, this,  _object.geometry.type);
					m_program.fragment = getFragmentShader(_light);
					m_program.vertex = getVertexShader( (_object.geometry.type.indexOf("AnimatedGPUMesh") != -1));
					m_program.program = device.createProgram();
					m_program.program.upload( m_program.vertex, m_program.fragment );	
					m_materialManager.cacheProgram(_object.material, this, _object.geometry.type, m_program);
				}else{
			//		trace("PASS GET PROGRAM", _object.material, this,  _object.geometry.type);
					m_program = m_materialManager.getProgram(_object.material, this, _object.geometry.type);
					getFragmentShader(_light);
					getVertexShader((_object.geometry.type.indexOf("AnimatedGPUMesh") != -1));
				}
			}
			return m_materialManager.getProgram(_object.material, this, _object.geometry.type);
		}
		
		private function getDirectionalIndex(_lights:Vector.<Light>):int{
			
			for(var k:uint = 0; k < _lights.length; k++){
				
				if(_lights[k].type == ELightType.DIRECTIONAL)
					return k;
			}
			return -1;
		}
		
		public function render(_object:SceneObjectRenderable, _light:Light, _device:Context3D, _camera:Camera3D):void{
			
			// handle base pass
			
			m_currentLight = _light;
			
			var program:Y3DProgram = getProgram(_device, _object, _light);
			
			if( program != m_materialManager.YOGURT3D_INTERNAL::m_lastProgram)
			{
				_device.setProgram( program.program );
				m_materialManager.YOGURT3D_INTERNAL::m_lastProgram = program;
			}
			
			m_surfaceParams.blendMode.setToDevice(_device);
		//	EBlendMode.ALPHA.setToDevice(_device);
			
			_device.setColorMask( m_surfaceParams.colorMaskR, m_surfaceParams.colorMaskG, m_surfaceParams.colorMaskB, m_surfaceParams.colorMaskA);
			_device.setDepthTest( m_surfaceParams.writeDepth, m_surfaceParams.depthFunction );
			_device.setCulling( m_surfaceParams.culling );
			
			preRender(_device, _object, _camera);
			
			var mesh:IMesh = _object.geometry;
			
			for( var submeshindex:uint = 0; submeshindex < mesh.subMeshList.length; submeshindex++ )
			{
				// Move to VertexStreamManager START
				var subMesh:SubMesh = mesh.subMeshList[submeshindex];
				m_vsManager.markVertex(_device);
				if( m_vertexInput.YOGURT3D_INTERNAL::m_vertexpos )
				{
					m_vsManager.setStream( _device,  m_vertexInput.YOGURT3D_INTERNAL::m_vertexpos.index, subMesh.getPositonBufferByContext3D(_device),0, Context3DVertexBufferFormat.FLOAT_3);
				}
				if( m_vertexInput.YOGURT3D_INTERNAL::m_normal )
				{
					m_vsManager.setStream( _device,  m_vertexInput.YOGURT3D_INTERNAL::m_normal.index, subMesh.getNormalBufferByContext3D(_device),0, Context3DVertexBufferFormat.FLOAT_3);
				}
				if( m_vertexInput.YOGURT3D_INTERNAL::m_tangent )
				{
					m_vsManager.setStream( _device,  m_vertexInput.YOGURT3D_INTERNAL::m_tangent.index, subMesh.getTangentBufferByContext3D(_device),0, Context3DVertexBufferFormat.FLOAT_3);
				}
				if( m_vertexInput.YOGURT3D_INTERNAL::m_uvMain )
				{
					m_vsManager.setStream( _device,  m_vertexInput.YOGURT3D_INTERNAL::m_uvMain.index, subMesh.getUVBufferByContext3D(_device),0, Context3DVertexBufferFormat.FLOAT_2);
				}
				if( m_vertexInput.YOGURT3D_INTERNAL::m_uvSecond )
				{   if( subMesh.uvt2 && subMesh.uvt2.length > 0)
					    m_vsManager.setStream( _device,  m_vertexInput.YOGURT3D_INTERNAL::m_uvSecond.index, subMesh.getUV2BufferByContext3D(_device),0, Context3DVertexBufferFormat.FLOAT_2);
				    else
                        m_vsManager.setStream( _device,  m_vertexInput.YOGURT3D_INTERNAL::m_uvSecond.index, subMesh.getUVBufferByContext3D(_device),0, Context3DVertexBufferFormat.FLOAT_2);
                }
				if( m_vertexInput.YOGURT3D_INTERNAL::m_boneData )
				{
					var skinnedSubmesh:SkinnedSubMesh = subMesh as SkinnedSubMesh;
					var buffer:VertexBuffer3D = skinnedSubmesh.getBoneDataBufferByContext3D(_device);
					m_vsManager.setStream( _device, m_vertexInput.YOGURT3D_INTERNAL::m_boneData.index, buffer, 0, Context3DVertexBufferFormat.FLOAT_4 );
					m_vsManager.setStream( _device, m_vertexInput.YOGURT3D_INTERNAL::m_boneData.index+1, buffer, 4, Context3DVertexBufferFormat.FLOAT_4 );
					m_vsManager.setStream( _device, m_vertexInput.YOGURT3D_INTERNAL::m_boneData.index+2, buffer, 8, Context3DVertexBufferFormat.FLOAT_4 );
					m_vsManager.setStream( _device, m_vertexInput.YOGURT3D_INTERNAL::m_boneData.index+3, buffer, 12,Context3DVertexBufferFormat.FLOAT_4 );
					m_vsManager.setStream( _device,  m_vertexInput.YOGURT3D_INTERNAL::m_normal.index, subMesh.getNormalBufferByContext3D(_device),0, Context3DVertexBufferFormat.FLOAT_3);
				}
				m_vsManager.sweepVertex(_device);
				// Move to VertexStreamManager END
				_device.drawTriangles(subMesh.getIndexBufferByContext3D(_device), 0, subMesh.triangleCount);
			}
			
			postRender(_device);
		}
		
		
		protected function preRender(device:Context3D, _object:SceneObjectRenderable, _camera:Camera3D):void{
			m_currentCamera = _camera;
			
			device.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, gen.VC["Model"].index, _object.transformation.matrixGlobal, true );
			device.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, gen.VC["ViewProjection"].index, m_currentCamera.viewProjectionMatrix, true );
			m_vsManager.markTexture(device);
			uploadConstants(device);
			m_vsManager.sweepTexture(device);
		}
		
		protected function postRender(device:Context3D):void{
//			VertexStreamManager.instance.cleanVertexBuffers(device);
//			
//			for each(var value:Constant in m_constants) {
//				if( value is TextureConstant )
//				{
//					var texConst:TextureConstant = value as TextureConstant;
//					device.setTextureAt(texConst.register.index, null );
//				}
//			}
		}
		
		public function uploadConstants(device:Context3D):void{
			//trace("****************CONSTANTS*************************");
			for each(var value:Constant in m_constants) {
				if( value is MatrixConstant )
				{
					device.setProgramConstantsFromMatrix( value.type.value, value.register.index, MatrixConstant(value).matrix, true );
					
					//trace("Matrix Type", value.register.id);
				}else if( value is VectorConstant )
				{
					device.setProgramConstantsFromVector( value.type.value, value.register.index, VectorConstant(value).vec );
					//trace("Vector Type", value.register.id, VectorConstant(value).vec );
				}else if( value is TextureConstant )
				{
					var texConst:TextureConstant = value as TextureConstant;
					m_vsManager.setTexture(device, texConst.register.index, texConst.texture.getTextureForDevice(device) );
					//device.setTextureAt(texConst.register.index, texConst.texture.getTextureForDevice(device) );
				}else if( value is VectorFunctionConstant )
				{
					device.setProgramConstantsFromVector( value.type.value, value.register.index, VectorFunctionConstant(value).callFunction(m_currentLight, m_currentCamera) );
					//trace("Vector Func Type", value);
				}else if( value is MatrixFunctionConstant )
				{
					device.setProgramConstantsFromMatrix( value.type.value, value.register.index, MatrixFunctionConstant(value).callFunction(m_currentLight, m_currentCamera), MatrixFunctionConstant(value).transposed);
				}
					
			}
			
		//	trace("****************CONSTANTS END*************************");
		}

		public function createConstantFromVector( type:ERegisterShaderType, name:String, vec:Vector.<Number>, register:IRegister = null ):IRegister{
			var vertexConstant:VectorConstant;
			if( m_constants[name] != null )
			{
				m_constants[name].vec = vec;
				return m_constants[name].register;
			}
			if( type == ERegisterShaderType.VERTEX)
			{
				vertexConstant = new VectorConstant();
				vertexConstant.type = ERegisterShaderType.VERTEX;
				vertexConstant.register = (register)?register:gen.createVC(name, vec.length/4);
				vertexConstant.vec = vec;
				m_constants[name] = vertexConstant;
			//	trace("Vertex Vec", name);
			}else if( type == ERegisterShaderType.FRAGMENT ){
				vertexConstant = new VectorConstant();
				vertexConstant.type = ERegisterShaderType.FRAGMENT;
				vertexConstant.register = (register)?register:gen.createFC(name, vec.length/4);
				vertexConstant.vec = vec;
				m_constants[name] = vertexConstant;
			//	trace("Fragment Vec", name);
			}
			return vertexConstant.register;
		}
		
		public function createConstantFromMatrixFunction( type:ERegisterShaderType, name:String, callfunction:Function, register:IRegister = null , trans:Boolean = false):IRegister{
			var vertexConstant:MatrixFunctionConstant;
			if( m_constants[name] != null )
			{
				m_constants[name].callFunction = callfunction;
				return m_constants[name].register;
			}
			if( type == ERegisterShaderType.VERTEX)
			{
				vertexConstant = new MatrixFunctionConstant();
				vertexConstant.type = ERegisterShaderType.VERTEX;
				vertexConstant.register = (register)?register:gen.createVC(name, 4);
				vertexConstant.callFunction = callfunction;
				vertexConstant.transposed = trans;
				m_constants[name] = vertexConstant;
			//	trace("Vertex Func", name);
			}else if( type == ERegisterShaderType.FRAGMENT ){
				vertexConstant = new MatrixFunctionConstant();
				vertexConstant.type = ERegisterShaderType.FRAGMENT;
				vertexConstant.register = (register)?register:gen.createFC(name, 4);
				vertexConstant.callFunction = callfunction;
				vertexConstant.transposed = trans;
				m_constants[name] = vertexConstant;
				
			//	trace("Fragment Vec", name);
			}
			return vertexConstant.register;
		}
		
		public function createConstantFromVectorFunction( type:ERegisterShaderType, name:String, callfunction:Function, register:IRegister = null ):IRegister{
			var vertexConstant:VectorFunctionConstant;
			if( m_constants[name] != null )
			{
				m_constants[name].callFunction = callfunction;
				return m_constants[name].register;
			}
			if( type == ERegisterShaderType.VERTEX)
			{
				vertexConstant = new VectorFunctionConstant();
				vertexConstant.type = ERegisterShaderType.VERTEX;
				vertexConstant.register = (register)?register:gen.createVC(name, 1);
				vertexConstant.callFunction = callfunction;
				m_constants[name] = vertexConstant;
			//	trace("Vertex Func", name);
			}else if( type == ERegisterShaderType.FRAGMENT ){
				vertexConstant = new VectorFunctionConstant();
				vertexConstant.type = ERegisterShaderType.FRAGMENT;
				vertexConstant.register = (register)?register:gen.createFC(name, 1);
				vertexConstant.callFunction = callfunction;
				m_constants[name] = vertexConstant;
				
			//	trace("Fragment Vec", name);
			}
			return vertexConstant.register;
		}
		
		public function createConstantFromTexture( type:ERegisterShaderType, name:String, texture:ITexture, register:IRegister = null ):IRegister{
			var textureConstant:TextureConstant;
			if( type == ERegisterShaderType.VERTEX)
			{
				throw new Error("No texture samplers allowed in the vertex shader");
			}else if( type == ERegisterShaderType.FRAGMENT ){
				textureConstant = new TextureConstant();
				textureConstant.type = ERegisterShaderType.FRAGMENT;
				textureConstant.register = (register)?register:gen.createFS(name);
				textureConstant.texture = texture;
				m_constants[name] = textureConstant;
			}
			return textureConstant.register;
		}
		
		public function createConstantFromMatrix( type:ERegisterShaderType, name:String, mat:Matrix3D, register:IRegister = null, trans:Boolean=false ):IRegister{
			var matrixConstant:MatrixConstant;
			if( type == ERegisterShaderType.VERTEX)
			{
				matrixConstant = new MatrixConstant();
				matrixConstant.type = ERegisterShaderType.VERTEX;
				matrixConstant.register = 	(register)?register:gen.createVC(name, 4);
				matrixConstant.matrix = mat;
				matrixConstant.transposed = trans;
				m_constants[name] = matrixConstant;
			}else if( type == ERegisterShaderType.FRAGMENT ){
				matrixConstant = new MatrixConstant();
				matrixConstant.type = ERegisterShaderType.FRAGMENT;
				matrixConstant.register = 	(register)?register:gen.createFC(name, 4);
				matrixConstant.matrix = mat;
				m_constants[name] = matrixConstant;
				matrixConstant.transposed = trans;
			}
			return matrixConstant.register;
		}
		
		public function getConstant( name:String ):IRegister{
			return m_constants[name].register;
		}
		
		public function getConstantVec( name:String ):Vector.<Number>{
			return m_constants[name].vec;
		}
		
		public function getConstantMat( name:String ):Matrix3D{
			return m_constants[name].matrix;
		}
		
		public function getConstantTex( name:String ):ITexture{
			return m_constants[name].texture;
		}
		
		public function setConstantTex( name:String, value:ITexture ):void{
			m_constants[name].texture = value;
		}
		
		public function createFT(name:String, size:int):IRegister{
			return gen.createFT( name, size);
		}
		public function destroyFT( name:String ):void{
			gen.destroyFT(name);
		}
			
		public function getVertexShader(isSkeletal:Boolean):ByteArray{
			var input:VertexInput = m_vertexInput = new VertexInput(gen);
			var out:VertexOutput = m_vertexOutput;
			var worldPos:IRegister = gen.createVT("worldPos",4);
			var screenPos:IRegister = gen.createVT("screenPos",4);
			
			gen.createVC("Model",4);
			
			gen.createVC("ViewProjection",4);
			
			var vertex:String = vertexFunction(input,out, gen);
			
			var code:String = "//*****VERTEX SHADER*****//\n";
			code += "// calculate world pos\n";
			code += gen.code("m44",worldPos, input.vertexpos, gen.VC["Model"])+ "\n";
			// add skeletal animation here
			
			if( out.normal)
			{
				code += "\n// calculate normal\n";
				code += gen.code("m33",out.normal.xyz, input.normal, gen.VC["Model"])+ "\n";
				code += gen.code("mov",out.normal.w, input.normal.w)+ "\n";
			}
			
			code += vertex;
			
			if( out.normal)
			{
				code += "\n//move normal to varying\n";
			}
			if( out.vertexPosition )
			{
				code += "\n// move vertexpos to varying\n";
				code += gen.code("mov", out.vertexPosition, input.vertexpos)+"\n";
			}
			if( out.worldPos)
			{
				code += "\n// move worldpos to varying\n";
				code += gen.code("mov", out.worldPos, worldPos);
			}
            if( out.uvMain )
            {
                code += "\n// add uv shift code here\n"
                code += "// move uv to varying\n";
                code += gen.code("mov", out.uvMain, input.uvMain )+"\n";
            }
            if( out.uvSecond )
            {
                code += "\n// add uv shift code here\n"
                code += "// move uv to varying\n";
                code += gen.code("mov", out.uvSecond, input.uvSecond )+"\n";
            }
			code+="\n// Calculate and Output screen pos\n";
			code+=gen.code("m44",screenPos, worldPos, gen.VC["ViewProjection"])+"\n";
			code+=gen.code("mov","op", screenPos)+"\n";
			
//			trace("VERTEX SHADER");
//			trace( code );
//			trace("END VERTEX SHADER");
			
			return ShaderUtils.vertexAssambler.assemble(Context3DProgramType.VERTEX, code, false );
		}
	
		protected function generateNeededCalculations(_light:Light, _surfaceOutput:SurfaceOutput):String{
		
			var result:String = "";
			if( _surfaceOutput.YOGURT3D_INTERNAL::m_normal )
			{
				result += "// move normal from varying to temp\n";
				result += "mov " + _surfaceOutput.YOGURT3D_INTERNAL::m_normal + " " + FragmentInput(m_vertexOutput).normal + "\n";
				result += "nrm " + _surfaceOutput.YOGURT3D_INTERNAL::m_normal + " " + _surfaceOutput.YOGURT3D_INTERNAL::m_normal + "\n"
			}
			if( _surfaceOutput.YOGURT3D_INTERNAL::m_lightColor )
			{
				var lightColorFC:IRegister = createConstantFromVectorFunction(
					ERegisterShaderType.FRAGMENT,
					"lightColor",
					function():Vector.<Number>{
						return m_currentLight.color.getColorVectorRaw();
					},
					_surfaceOutput.YOGURT3D_INTERNAL::m_lightColor
				);
				result += "//Assigned lightColor to "+ lightColorFC + "\n";
			}
			if( _surfaceOutput.YOGURT3D_INTERNAL::m_lightDir )
			{
				result += "// Calculate lightDirection ("+_surfaceOutput.YOGURT3D_INTERNAL::m_lightDir+")\n";
				if( _light && _light.type == ELightType.DIRECTIONAL )
				{
					var lightDirectionFC:IRegister = createConstantFromVectorFunction(
						ERegisterShaderType.FRAGMENT,
						"lightDirectionConstant",
						function():Vector.<Number>{
							return m_currentLight.directionVector;
						}
					);
					result += "//Assigned lightDirection to "+ lightDirectionFC + "\n";
					result += "mov " + _surfaceOutput.YOGURT3D_INTERNAL::m_lightDir + " " + lightDirectionFC.xyz + "\n";
				}
			}
			if( _surfaceOutput.YOGURT3D_INTERNAL::m_viewDir )
			{
				result += "// Calculate viewDirection ("+_surfaceOutput.YOGURT3D_INTERNAL::m_viewDir+")\n\n";
				result += "sub "+ _surfaceOutput.YOGURT3D_INTERNAL::m_viewDir + " " + gen.FC["cameraPos"] + " " + FragmentInput(m_vertexOutput).worldPos + "\n";
				result += "nrm"+ " "+ _surfaceOutput.YOGURT3D_INTERNAL::m_viewDir+ " "+ _surfaceOutput.YOGURT3D_INTERNAL::m_viewDir;
			}
			if( _surfaceOutput.YOGURT3D_INTERNAL::m_atteniation )
			{
				result += "// Calculate atteniation ("+_surfaceOutput.YOGURT3D_INTERNAL::m_atteniation+")\n";
				if( _light && _light.type == ELightType.DIRECTIONAL )
				{
					result += "// Directional Light Attenuation = 1\n";
					createConstantFromVector(ERegisterShaderType.FRAGMENT, "half", Vector.<Number>([1,2,0.5,255]) );
					
					result += "mov " + _surfaceOutput.YOGURT3D_INTERNAL::m_atteniation + " " + getConstant("half").x + "\n";
				}
			}
		
			return result;
		}
			
		public function getFragmentShader(_light:Light):ByteArray{
			gen.destroyAllTmp();
			
			m_vertexOutput = new FragmentInput(gen);
			var surfaceOutput:LightInput = new LightInput(gen);
			
			var surface:String = surfaceFunction( m_vertexOutput as FragmentInput, surfaceOutput, gen );
			var light:String;
			if( _light == null )
			{
				light = MaterialBase.NoLight(surfaceOutput,gen);
			}else{
				light = lightFunction(surfaceOutput,gen);
			}
			
			var code:String = "//*****PIXEL SHADER*****//\n";
			
			code += generateNeededCalculations(_light, surfaceOutput);
			
			code += surface + light;
			
			code += "\n//Move result to output\n";
			code += "mov oc " + gen.FT["result"];
			
//			trace("FRAGMENT SHADER");
//			trace(code);
//			trace("END FRAGMENT SHADER");
			
			return ShaderUtils.fragmentAssambler.assemble(Context3DProgramType.FRAGMENT, code, false );
		}
	}
}

import com.yogurt3d.core.material.agalgen.IRegister;
import com.yogurt3d.core.material.enum.ERegisterShaderType;
import com.yogurt3d.core.texture.ITexture;

import flash.geom.Matrix3D;

internal class TextureSample{
	public var texture:ITexture;
	public var register:IRegister;
}
internal class Constant{
	public var type:ERegisterShaderType;
	public var register:IRegister;
}
internal class VectorConstant extends Constant{
	public var vec:Vector.<Number>;
}
internal class TextureConstant extends Constant{
	public var texture:ITexture;
}
internal class MatrixConstant extends Constant{
	public var matrix:Matrix3D;
	public var transposed:Boolean;
}
internal class VectorFunctionConstant extends Constant{
	public var callFunction:Function;
}
internal class MatrixFunctionConstant extends Constant{
	public var transposed:Boolean;
	public var callFunction:Function;
}