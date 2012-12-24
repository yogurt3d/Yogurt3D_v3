/*
* EffectPosterization.as
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

package com.yogurt3d.presets.effects
{
	import com.yogurt3d.core.render.post.PostProcessingEffectBase;
	
	import flash.display3D.Context3DProgramType;
	
	public class EffectPosterization extends PostProcessingEffectBase
	{
		
		private var m_filter:FilterPosterization;
		public function EffectPosterization(_gamma:Number=0.6, _numColors:Number=8.0)
		{
			super();
			
			effects.push( m_filter = new FilterPosterization(_gamma, _numColors) );
		}
	
		public function get gamma():Number{
			return m_filter.gamma;
		}
		public function set gamma(_value:Number):void{
			m_filter.gamma = _value;
		}
		
		public function get numColors():Number{
			return m_filter.numColors;
		}
		public function set numColors(_value:Number):void{
			m_filter.numColors = _value;
		}
	}
}
import com.adobe.AGALMiniAssembler;
import com.yogurt3d.core.render.post.EffectBase;
import com.yogurt3d.core.render.post.PostProcessingEffectBase;
import com.yogurt3d.utils.ShaderUtils;

import flash.display3D.Context3DProgramType;
import flash.display3D.textures.TextureBase;
import flash.geom.Rectangle;
import flash.utils.ByteArray;

internal class FilterPosterization extends EffectBase
{
	
	private var m_gamma:Number;
	private var m_numColors:Number;
	public function FilterPosterization(_gamma:Number=0.6, _numColors:Number=8.0)
	{
		super();
		
		m_gamma = _gamma;
		m_numColors = _numColors;
		
	}
	
	public function get gamma():Number{
		return m_gamma;
	}
	public function set gamma(_value:Number):void{
		m_gamma = _value;
	}
	
	public function get numColors():Number{
		return m_numColors;
	}
	public function set numColors(_value:Number):void{
		m_numColors = _value;
	}
	
	public override function setEffectParameters(_rect:Rectangle, _sampler:TextureBase):void{
		device.setTextureAt( 0, _sampler);
		device.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0,  Vector.<Number>([m_gamma, m_numColors, (1.0/m_gamma as Number), 1.0]));
	}
	
	public override function clean():void{
		device.setTextureAt( 0, null);
	}
		
	public override function getFragmentProgram():ByteArray{
		//			vec3 c = texture2D(sceneTex, gl_TexCoord[0].xy).rgb;
		//			c = pow(c, vec3(gamma, gamma, gamma));
		//			c = c * numColors;
		//			c = floor(c);
		//			c = c / numColors;
		//			c = pow(c, vec3(1.0/gamma));
		//			gl_FragColor = vec4(c, 1.0);
		
		return ShaderUtils.fragmentAssambler.assemble( AGALMiniAssembler.FRAGMENT,
			[
				"tex ft0 v0 fs0<2d,wrap,linear>", // get render to texture
				"mov ft1.x fc0.x",
				"mov ft1.y fc0.x",
				"mov ft1.z fc0.x",
				"mov ft1.w fc0.x",
				"pow ft0 ft0 ft1",//c = pow(c, vec3(gamma, gamma, gamma));
				"mul ft0 ft0 fc0.y",//c = c * numColors;
				"mov ft1 ft0",
				ShaderUtils.floorAGAL("ft1","ft0"),
				//"frc ft0 ft0",//c = floor(c);
				"mov ft0 ft1",
				
				"div ft0 ft0 fc0.y",//c = c / numColors;
				"mov ft1.x fc0.z",
				"mov ft1.y fc0.z",
				"mov ft1.z fc0.z",
				"mov ft1.w fc0.z",
				"pow ft0 ft0 ft1",//c = pow(c, vec3(1.0/gamma));
				"mov ft0.w fc0.w",//alpha = 1
				
				"mov oc ft0"
				
			].join("\n")
		);
	}
}