/*
* EffectHueSaturation.as
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

public class EffectHueSaturation extends PostProcessingEffectBase
	{
		private var m_filter:FilterHueSaturation;
		
		public function EffectHueSaturation(_hue:Number= 0.0, _saturation:Number=0.0 )
		{
			super();
				
			effects.push( m_filter = new FilterHueSaturation(_hue, _saturation) );
		}
		
		
		public function get saturation():Number
		{
			return m_filter.saturation;
		}
		
		public function set saturation(value:Number):void
		{
			m_filter.saturation = value;
		}
		
		public function get hue():Number
		{
			return m_filter.hue;
		}
		
		public function set hue(value:Number):void
		{
			m_filter.hue = value;
		}
	}
}

import com.adobe.AGALMiniAssembler;
import com.yogurt3d.core.Scene3D;
import com.yogurt3d.core.render.post.EffectBase;
import com.yogurt3d.utils.ShaderUtils;

import flash.display3D.Context3DProgramType;
import flash.display3D.textures.TextureBase;
import flash.geom.Rectangle;
import flash.geom.Vector3D;
import flash.utils.ByteArray;

internal class FilterHueSaturation extends EffectBase
{
	private var m_hue:Number;
	private var m_saturation:Number;
	private var m_weights:Vector3D;
	private var m_value:Number;
	
	public function FilterHueSaturation(_hue:Number= 0.0, _saturation:Number=0.0 )
	{
		super();
		
		m_weights = new Vector3D;
		hue = _hue;
		saturation = _saturation;	
		
	}
	
	public override function setEffectParameters(_rect:Rectangle, _sampler:TextureBase, _scene:Scene3D):void{
		device.setTextureAt( 0, _sampler);
		
		device.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0,  Vector.<Number>([m_saturation, 0.0, 1.0, 0.0]));
		device.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1,  Vector.<Number>([-1.0, 2.0, 3.0, -m_saturation]));
		device.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2,  Vector.<Number>([m_weights.x, m_weights.y, m_weights.z, m_value]));
		
	}
	
	public override function clean():void{
		device.setTextureAt( 0, null);
	}
	
	public function get saturation():Number
	{
		return m_saturation;
	}
	
	public function set saturation(value:Number):void
	{
		m_saturation = value;
		m_value = (1.0 - 1.0 / (1.001 - m_saturation))
	}
	
	public function get hue():Number
	{
		return m_hue;
	}
	
	public function set hue(value:Number):void
	{
		m_hue = value;
		
		var s:Number = Math.sin(m_hue);
		var c:Number = Math.cos(m_hue);
		
		m_weights.x = 2.0 * c;
		m_weights.y = -Math.sqrt(3.0) * s - c;
		m_weights.z = Math.sqrt(3.0) * s - c;
	}
		
	public override function getFragmentProgram():ByteArray{
		return ShaderUtils.fragmentAssambler.assemble( AGALMiniAssembler.FRAGMENT,
			[
				"tex ft0 v0 fs0<2d,wrap,linear>", // get render to texture
				
				"mov ft1.xyz fc2.xyz",//weights
				"add ft1.xyz ft1.xyz fc0.z",//(vec3(2.0 * c, -sqrt(3.0) * s - c, sqrt(3.0) * s - c) + 1.0)
				"div ft1.xyz ft1.xyz fc1.z",// vec3 weights = (vec3(2.0 * c, -sqrt(3.0) * s - c, sqrt(3.0) * s - c) + 1.0) / 3.0;
				
				"dp3 ft2.x ft0.xyz ft1.xyz",//dot(color.rgb, weights.xyz)
				"dp3 ft2.y ft0.xyz ft1.zxy",//dot(color.rgb, weights.zxy)
				"dp3 ft2.z ft0.xyz ft1.yzx",// dot(color.rgb, weights.yzx)
				
				"add ft1.w ft2.x ft2.y",
				"add ft1.w ft1.w ft2.z",
				"div ft1.w ft1.w fc1.z",//average = (color.r + color.g + color.b) / 3.0;
				
				"mov ft3.x fc0.x",
				ShaderUtils.greaterThan("ft3.y","ft3.x","fc0.y","ft7"),//if
				"sub ft3.z fc0.z ft3.y",//else
				
				"sub ft4.xyz ft1.w ft2.xyz",//average - color.rgb
				
				"mul ft5.xyz ft4.xyz fc2.w",//(average - color.rgb) * (1.0 - 1.0 / (1.001 - saturation))
				"add ft5.xyz ft5.xyz ft2.xyz",
				"mul ft5.xyz ft5.xyz ft3.y",
				
				"mul ft6.xyz ft4.xyz fc1.w",
				"add ft6.xyz ft6.xyz ft2.xyz",
				"mul ft6.xyz ft6.xyz ft3.z",
				
				"add ft0.xyz ft5.xyz ft6.xyz",
				"mov ft0.w fc0.z",
				
				"mov oc ft0"
				
			].join("\n")
		);
	}
}