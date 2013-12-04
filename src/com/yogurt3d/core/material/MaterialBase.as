/*
* MaterialBase.as
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

package com.yogurt3d.core.material
{
import com.yogurt3d.core.material.agalgen.AGALGEN;
import com.yogurt3d.core.material.agalgen.IRegister;
import com.yogurt3d.core.material.enum.ERegisterShaderType;
import com.yogurt3d.core.material.parameters.LightInput;
import com.yogurt3d.core.material.parameters.ShaderParameters;
import com.yogurt3d.core.material.parameters.VertexInput;
import com.yogurt3d.core.material.parameters.VertexOutput;
import com.yogurt3d.core.material.pass.BasePass;
import com.yogurt3d.core.material.pass.Pass;
import com.yogurt3d.core.sceneobjects.SceneObjectRenderable;
import com.yogurt3d.core.sceneobjects.camera.Camera3D;
import com.yogurt3d.core.sceneobjects.lights.Light;
import com.yogurt3d.core.texture.ITexture;
import com.yogurt3d.utils.Color;

import flash.display3D.Context3D;
import flash.geom.Matrix3D;

public class MaterialBase
	{
		private var m_basePass					:Pass;
		//private var m_directionalPass			:Pass;

		protected var m_lightFunction			:Function;
		protected var m_surfaceFunction			:Function;
		protected var m_vertexFunction			:Function;
	
		public var transparent					:Boolean = false;
		public var cutOff						:Boolean = false;
			
		public function MaterialBase(_initInternals:Boolean = true)
		{
			if(_initInternals)
				m_basePass = new BasePass();
			//m_directionalPass = new DirectionalPass();
		}
		
		public function get params():ShaderParameters{
			if(m_basePass)
				return m_basePass.surfaceParams;
			return null;
		}
		
		public function disposeDeep():void{
			if(m_basePass)
				m_basePass.disposeDeep(this);
		}
		
		public function get basePass():Pass
		{
			return m_basePass;
		}
		
		public function set basePass(value:Pass):void
		{
			m_basePass = value;
		}
		
		public function get emissiveColor():Color{
			return m_basePass.emissiveColor;
		}
		
		public function get ambientColor():Color{
			return m_basePass.ambientColor;
		}
		
		public function get diffuseColor():Color{
			return m_basePass.diffuseColor;
		}
		
		public function get specularColor():Color{
			return m_basePass.specularColor;
		}
		
		public function set emissiveColor(_value:Color):void{
			m_basePass.emissiveColor = _value;
			//m_directionalPass.emissiveColor = _value;
		}
		
		public function set ambientColor(_value:Color):void{
			m_basePass.ambientColor = _value;
		//	m_directionalPass.ambientColor = _value;
		}
		
		public function set diffuseColor(_value:Color):void{
			m_basePass.diffuseColor = _value;
		//	m_directionalPass.diffuseColor = _value;
		}
		
		public function set specularColor(_value:Color):void{
			m_basePass.specularColor = _value;
		//	m_directionalPass.specularColor = _value;
		}

		public function get vertexFunction():Function
		{
			return m_vertexFunction;
		}

		public function set vertexFunction(value:Function):void
		{
			if( value != null )
			{
				m_vertexFunction = value;
			}else{
				m_vertexFunction = emptyFunction;
			}
			m_basePass.vertexFunction = m_vertexFunction;
		//	m_directionalPass.vertexFunction = m_vertexFunction;
		}
	
		public function get lightFunction():Function
		{
			return m_lightFunction;
		}

		public function set lightFunction(value:Function):void
		{
			if( value != null )
			{
				m_lightFunction = value;
			}else{
				m_lightFunction = NoLight;
			}
			m_basePass.lightFunction = m_lightFunction;
		//	m_directionalPass.lightFunction = m_lightFunction;
		}

		public function get surfaceFunction():Function
		{
			return m_surfaceFunction;
		}
		
		public function set surfaceFunction(value:Function):void
		{
			if( value != null )
			{
				m_surfaceFunction = value;
			}else{
				m_surfaceFunction = emptyFunction;
			}
			m_basePass.surfaceFunction = surfaceFunction;
		//	m_directionalPass.surfaceFunction = surfaceFunction;
		}
			
		
		// TODO : Matrix 
		
		public function createConstantFromMatrix( type:ERegisterShaderType, name:String, mat:Matrix3D, register:IRegister = null, trans:Boolean = false):void{
			m_basePass.createConstantFromMatrix( type, name, mat, register, trans);
		}
			
		public function createConstantFromMatrixFunction( shaderType:ERegisterShaderType, name:String, callfunction:Function, register:IRegister = null, trans:Boolean = false ):void{
			m_basePass.createConstantFromMatrixFunction(shaderType, name, callfunction, register, trans);
		}
		
		public function createConstantFromVectorFunction( shaderType:ERegisterShaderType, name:String, callfunction:Function, register:IRegister = null ):void{
			m_basePass.createConstantFromVectorFunction( shaderType, name, callfunction, register);
		}
		/**
		 * Call this function inside the constructor to add a vector constant to either the FRAGMENT shader or the VERTEX shader. 
		 * @param shaderType
		 * @param name
		 * @param value
		 * @param register
		 * 
		 */
		public function createConstantFromVector( shaderType:ERegisterShaderType, name:String, value:Vector.<Number>, register:IRegister = null):void{
			m_basePass.createConstantFromVector( shaderType, name, value, register);
		//	m_directionalPass.createConstantFromVector( shaderType, name, value, register);
		}
		/**
		 * Call this function inside the constructor to add a texture constant to the FRAGMENT shader. 
		 * @param shaderType
		 * @param name
		 * @param value
		 * @param register
		 * 
		 */
		public function createConstantFromTexture( name:String, texture:ITexture, register:IRegister = null ):IRegister{
		//	m_directionalPass.createConstantFromTexture( ERegisterShaderType.FRAGMENT, name, texture, register);
			return m_basePass.createConstantFromTexture( ERegisterShaderType.FRAGMENT, name, texture, register);
		}
		
		public function getConstant( name:String ):IRegister{
			return m_basePass.getConstant(name);
		}
		public function getConstantVec( name:String ):Vector.<Number>{
			return m_basePass.getConstantVec(name);
		}
		public function getConstantMat( name:String ):Matrix3D{
			return m_basePass.getConstantMat(name);
		}
		public function getConstantTex( name:String ):ITexture{
			return m_basePass.getConstantTex(name);
		}
		public function setConstantTex( name:String, value:ITexture ):void{
			m_basePass.setConstantTex( name, value );
		//	m_directionalPass.setConstantTex( name, value );
		}
		
		public function render(_object:SceneObjectRenderable, 
							   _lights:Vector.<Light>, _device:Context3D, _camera:Camera3D):void
		{
            if(_object.geometry==null) return;
			if(_lights){
				m_basePass.render(_object, _lights[0], _device,_camera);
				//m_directionalPass.render(_object, _lights[1], _device,_camera);
			}else{
				m_basePass.render(_object, null, _device,_camera);
			}
				
		}
		
		public static function Lambert(input:LightInput, gen:AGALGEN):String{
			var code:String = "\n\n//****LightFunction START****/\n";
			var NdotL:IRegister = gen.createFT("NdotL",1);
			
			code += "// N.L \n";
			code += "dp3 " + NdotL + " " + input.Normal + " " + input.lightDirection + "\n";
			code += "sat " + NdotL + " " + NdotL + "\n";
			gen.destroyFT( input.Normal.id );
			gen.destroyFT( input.lightDirection.id );
			
			var result:IRegister = gen.createFT("result",4);
			code += "\n// result = color * lambert * lightColor * att \n"; 
			code += "mul "+ result.x + " " + input.atteniation + " " + NdotL + "\n";
			code += "mul "+ result.xyz + " " + input.lightColor + " " + result.xxx + "\n";
			code += "mul "+ result.xyz + " " + input.Albedo + " " + result.xyz + "\n";
			gen.destroyFT( input.atteniation.id );
			gen.destroyFT( input.Albedo.id );
			
			code += "\n//color.a = surfaceAlpha; \n";
			code += "mov "+ result.w + " " + input.Alpha + "\n";
			gen.destroyFT( input.Alpha.id );			
			code += "//****LightFunction END****/\n";
			
			
			return code;
		}
		public static function NoLight(input:LightInput, gen:AGALGEN):String{
			var code:String = "\n\n//****LightFunction START****/\n";
			
			var result:IRegister = gen.createFT("result",4);
			
			code += "mov " + result + " " + input.Albedo + "\n";
			gen.destroyFT( input.Albedo.id );
			
			code += "\n//color.a = surfaceAlpha; \n";
			code += "mov "+ result.w + " " + input.Alpha + "\n";
			gen.destroyFT( input.Alpha.id );			
			code += "//****LightFunction END****/\n";
			
			return code;
		}
		public static function emptyFunction(input:VertexInput, out:VertexOutput, gen:AGALGEN):String{return "";}
	}
}