/*
* EffectBase.as
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

package com.yogurt3d.core.render.post
{

import com.adobe.AGALMiniAssembler;
import com.yogurt3d.core.Scene3D;
import com.yogurt3d.core.managers.ProgramManager;
import com.yogurt3d.core.material.enum.EBlendMode;
import com.yogurt3d.core.material.parameters.ShaderParameters;
import com.yogurt3d.utils.ShaderUtils;

import flash.display3D.Context3D;
import flash.display3D.Context3DCompareMode;
import flash.display3D.Context3DTriangleFace;
import flash.display3D.Program3D;
import flash.display3D.textures.TextureBase;
import flash.geom.Rectangle;
import flash.utils.ByteArray;
import flash.utils.getQualifiedClassName;

public class EffectBase
	{
		private var m_device						:Context3D;
		private var m_params						:ShaderParameters;
		private var m_key							:String;
		
		public function EffectBase()
		{
			key = getQualifiedClassName( this );
		}
		
		
		public function render(_device:Context3D, _scene:Scene3D,
							   _post:PostProcessingEffectBase):void{
			var program:Program3D;
			device = _device;
			device.clear();
			
			program = ProgramManager.getEffectProgram(this, device);
			device.setProgram(program);	
			////			// set program
			//			if( program != ProgramManager.lastProgram )
			//			{
			//				
			//				ProgramManager.lastProgram  = program;
			//			}
			
			EBlendMode.NORMAL.setToDevice(_device);
			
			device.setColorMask(true,true,true,false);
			device.setDepthTest( false, Context3DCompareMode.ALWAYS );
			device.setCulling( Context3DTriangleFace.NONE );
			
			setEffectParameters(_post.drawRect, _post.sampler, _scene);
			
			// render
			_post.renderer.render(device);
			
			clean();
			
			//VertexStreamManager.instance.cleanVertexBuffers(device);
			
		}
		public function dispose():void{}
		
		public function clean():void{}
		
		public function setEffectParameters(_rect:Rectangle, _sampler:TextureBase, _scene:Scene3D):void{}
		
		public function getVertexProgram():ByteArray{
			return ShaderUtils.vertexAssambler.assemble( AGALMiniAssembler.VERTEX, 
				"mov op va0\n"+
				"mov v0 va1"
			);
			return null;
		}
		
		public function getFragmentProgram():ByteArray{
			throw new Error("[Y3D_WARNING] EffectBase@getFragmentProgram:  getFragmentProgram must be overriden in shader!");
		}
		
		public function get key():String
		{
			return m_key;
		}
		
		public function set key(value:String):void
		{
			m_key = value;
		}
		
		public function get params():ShaderParameters
		{
			return m_params;
		}
		
		public function set params(value:ShaderParameters):void
		{
			m_params = value;
		}
		
		public function get device():Context3D
		{
			return m_device;
		}
		
		public function set device(value:Context3D):void
		{
			m_device = value;
		}
		
	}
}