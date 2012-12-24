/*
* EffectColorGrading.as
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
	import com.yogurt3d.core.texture.TextureMap;
	
	import flash.display3D.Context3DProgramType;
	
	public class EffectColorGrading extends PostProcessingEffectBase
	{
		private var m_filter:FilterColorGrading;
		public function EffectColorGrading(_colorGradient:TextureMap)
		{
			super();
			effects.push(m_filter = new FilterColorGrading(_colorGradient));
		}
		
		public function get colorGradient():TextureMap{
			return m_filter.colorGradient;
		}
		
		public function set colorGradient(_value:TextureMap):void{
			m_filter.colorGradient = _value;
		}
	}
}
import com.adobe.AGALMiniAssembler;
import com.yogurt3d.core.render.post.EffectBase;
import com.yogurt3d.core.texture.TextureMap;
import com.yogurt3d.core.utils.ShaderUtils;

import flash.display3D.Context3DProgramType;
import flash.display3D.textures.TextureBase;
import flash.geom.Rectangle;
import flash.utils.ByteArray;

internal class FilterColorGrading extends EffectBase
{
	private var m_colorGradient:TextureMap;
	public function FilterColorGrading(_colorGradient:TextureMap)
	{
		super();	
		m_colorGradient = _colorGradient;
	}
	public function get colorGradient():TextureMap{
		return m_colorGradient;
	}
	
	public function set colorGradient(_value:TextureMap):void{
		m_colorGradient = _value;
	}
	
	public override function setEffectParameters(_rect:Rectangle, _sampler:TextureBase):void{
		device.setTextureAt( 0, _sampler);
		device.setTextureAt( 1, m_colorGradient.getTextureForDevice(device));
		device.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0,  Vector.<Number>([1.0, 0.5, 0.0, 0.0]));
		
	}
	
	public override function clean():void{
		device.setTextureAt( 0, null);
		device.setTextureAt( 1, null);
	}
	
	public override function getFragmentProgram():ByteArray{
		return ShaderUtils.fragmentAssambler.assemble( AGALMiniAssembler.FRAGMENT,
			[
				
				"tex ft0 v0 fs0<2d,wrap,linear>",// get render to texture
				"mov ft1.y fc0.y",
				"mov ft1.x ft0.x",
				
				"tex ft2 ft1.xy fs1<2d,clamp,linear>", // get gradient
				"mov ft0.x ft2.x",
				
				"mov ft1.x ft0.y",
				"tex ft2 ft1.xy fs1<2d,clamp,linear>", // get gradient
				
				"mov ft0.y ft2.y",
				"mov ft1.x ft0.z",
				"tex ft2 ft1.xy fs1<2d,clamp,linear>", // get gradient
				
				"mov ft0.z ft2.z",
				"mov ft0.w fc0.x",
				"mov oc ft0"
				
			].join("\n")
		);
	}
}