/*
* EffectBrightnessContrast.as
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

public class EffectBrightnessContrast extends PostProcessingEffectBase
	{	
		private var m_filter:FilterBrightnessContrast;
		
		public function EffectBrightnessContrast(_brightness:Number= 0.0, _contrast:Number=0.0 )
		{
			super();
	
			effects.push(m_filter = new FilterBrightnessContrast(_brightness, _contrast));
		}
				
		public function get contrast():Number
		{
			return m_filter.contrast;
		}
		
		public function set contrast(value:Number):void
		{
			m_filter.contrast = value;
		}
		
		public function get brightness():Number
		{
			return m_filter.brightness;
		}
		
		public function set brightness(value:Number):void
		{
			m_filter.brightness = value;
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
import flash.utils.ByteArray;

internal class FilterBrightnessContrast extends EffectBase
{
	private var m_brightness:Number;
	private var m_contrast:Number;
	
	public function FilterBrightnessContrast(_brightness:Number= 0.0, _contrast:Number=0.0 )
	{
		super();
		m_brightness = _brightness;
		m_contrast = _contrast;
	}
	
	public function get contrast():Number
	{
		return m_contrast;
	}
	
	public function set contrast(value:Number):void
	{
		m_contrast = value;
	}
	
	public function get brightness():Number
	{
		return m_brightness;
	}
	
	public function set brightness(value:Number):void
	{
		m_brightness = value;
	}
	
	public override function setEffectParameters(_rect:Rectangle, _sampler:TextureBase, _scene:Scene3D):void{
		device.setTextureAt( 0, _sampler);
		device.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0,  Vector.<Number>([m_brightness, m_contrast, 0.0, 1.0]));
		device.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1,  Vector.<Number>([0.5, 0.0, 0.0, 0.0]));
	}
	
	public override function clean():void{
		device.setTextureAt( 0, null);
	}
	
	public override function getFragmentProgram():ByteArray{

		return ShaderUtils.fragmentAssambler.assemble( AGALMiniAssembler.FRAGMENT,
			[
				"tex ft0 v0 fs0<2d,wrap,linear>", // get render to texture
				"add ft0 ft0 fc0.x",//color.rgb += brightness
				
				"mov ft1.x fc0.y",
				ShaderUtils.greaterThan("ft1.y","ft1.x","fc0.z","ft2"),//if
				"sub ft1.z fc0.w ft1.y",//else
				
				"sub ft0 ft0 fc1.x",//ft0 = color.rgb - 0.5
				"sub ft2.x fc0.w ft1.x",// 1.0 - contrast
				"add ft2.y fc0.w ft1.x",// 1.0 + contrast
				
				"div ft3 ft0 ft2.x",//(color.rgb - 0.5) / (1.0 - contrast) 
				"add ft3 ft3 fc1.x",//(color.rgb - 0.5) / (1.0 - contrast) + 0.5
				"mul ft3 ft3 ft1.y",
				
				"div ft4 ft0 ft2.y",//(color.rgb - 0.5) / (1.0 + contrast) 
				"add ft4 ft4 fc1.x",//(color.rgb - 0.5) / (1.0 + contrast) + 0.5
				"mul ft4 ft4 ft1.z",
				
				"add oc ft3 ft4"
				
			].join("\n")
		);
	}
}