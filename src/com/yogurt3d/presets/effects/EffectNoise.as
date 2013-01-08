/*
* EffectNoise.as
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
	
	public class EffectNoise extends PostProcessingEffectBase
	{
		
		private var m_filter:FilterNoise;
		public function EffectNoise(_amount:Number= 0.0)
		{
			super();
			effects.push( m_filter = new FilterNoise(_amount) );
		}
		
		public function get amount():Number
		{
			return m_filter.amount;
		}
		
		public function set amount(value:Number):void
		{
			m_filter.amount = value;
		}
	}
}
import com.adobe.AGALMiniAssembler;
import com.yogurt3d.core.Scene3D;
import com.yogurt3d.core.render.post.EffectBase;
import com.yogurt3d.core.render.post.PostProcessingEffectBase;
import com.yogurt3d.utils.ShaderUtils;

import flash.display3D.Context3DProgramType;
import flash.display3D.textures.TextureBase;
import flash.geom.Rectangle;
import flash.utils.ByteArray;

internal class FilterNoise extends EffectBase
{
	
	private var m_amount:Number;
	public function FilterNoise(_amount:Number= 0.0)
	{
		super();
		m_amount = _amount;
	}
	
	public function get amount():Number
	{
		return m_amount;
	}
	
	public function set amount(value:Number):void
	{
		m_amount = value;
	}
	
	public override function setEffectParameters(_rect:Rectangle, _sampler:TextureBase, _scene:Scene3D):void{
		device.setTextureAt( 0, _sampler);
		
		device.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0,  Vector.<Number>([m_amount, 0.5, 12.9898,78.233]));
		device.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1,  Vector.<Number>([43758.5453, 0.0, 0.0, 0.0]));
	}
	
	public override function clean():void{
		device.setTextureAt( 0, null);
	}
		
	public override function getFragmentProgram():ByteArray{
		
		return ShaderUtils.fragmentAssambler.assemble( AGALMiniAssembler.FRAGMENT,
			
			[
				"tex ft0 v0 fs0<2d,wrap,linear>", // get render to texture
				
				"mul ft2.x v0.x fc0.z",
				"mul ft2.y v0.y fc0.w",
				"add ft1.x ft2.x ft2.y",
				
				"sin ft1.x ft1.x",
				"mul ft1.x ft1.x fc1.x",
				"frc ft1.x ft1.x",
				
				"sub ft1.x ft1.x fc0.y",
				"mul ft1.x ft1.x fc0.x",//float diff = (rand(texCoord) - 0.5) * amount;\
				
				"add ft0.x ft0.x ft1.x",
				"add ft0.y ft0.y ft1.x",
				"add ft0.z ft0.z ft1.x",
				
				"mov oc ft0"
				
				
			].join("\n")
			
		);
	}
}