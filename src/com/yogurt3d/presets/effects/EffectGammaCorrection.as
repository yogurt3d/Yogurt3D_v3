/*
* EffectGammaCorrection.as
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
	
	public class EffectGammaCorrection extends PostProcessingEffectBase
	{
	
		private var m_filter:FilterGammaCorrection;
		public function EffectGammaCorrection(_gamma:Number=2.2)
		{
			super();
					
			effects.push( m_filter = new FilterGammaCorrection(_gamma) );
		}
		
		public function get gamma():Number{
			return m_filter.gamma;
		}
		
		public function set gamma(_value:Number):void{
			m_filter.gamma = _value;
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

internal class FilterGammaCorrection extends EffectBase
{
	
	private var m_gamma:Number;
	public function FilterGammaCorrection(_gamma:Number=2.2)
	{
		super();
	}
	
	public function get gamma():Number{
		return m_gamma;
	}
	
	public function set gamma(_value:Number):void{
		m_gamma = _value;
	}
	
	public override function setEffectParameters(_rect:Rectangle, _sampler:TextureBase):void{
		device.setTextureAt( 0, _sampler);
		device.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0,  Vector.<Number>([1/m_gamma, 0.5, 0.0, 1.0]));
	}
	
	public override function clean():void{
		device.setTextureAt( 0, null);
	}
	
	public override function getFragmentProgram():ByteArray{
		//outColor.rgb = pow(color, 1.0 / gammaRGB);
		
		return ShaderUtils.fragmentAssambler.assemble( AGALMiniAssembler.FRAGMENT,
			[
				"tex ft0 v0 fs0<2d,wrap,linear>", // get render to texture
				"pow ft0 ft0 fc0.xxx", //pow(color, 1.0 / gammaRGB)
				"mov ft0.w fc0.w",
				
				"mov oc ft0"
				
			].join("\n")
		);
	}
}