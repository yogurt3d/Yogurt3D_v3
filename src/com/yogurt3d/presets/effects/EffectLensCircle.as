/*
* EffectLensCircle.as
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
	
	public class EffectLensCircle extends PostProcessingEffectBase
	{
		private var m_filter:FilterLensCircle;
		public function EffectLensCircle(_lensX:Number=0.45, _lensY:Number=0.38, _centerX:Number=0.5, _centerY:Number=0.5)
		{
			super();
			
			effects.push( m_filter = new FilterLensCircle(_lensX, _lensY, _centerX, _centerY));
		}
		
		public function get lensX():Number{
			return m_filter.lensX;
		}
		
		public function get lensY():Number{
			return m_filter.lensY;
		}
		
		public function get centerX():Number{
			return m_filter.centerX;
		}
		
		public function get centerY():Number{
			return m_filter.centerY;
		}
		
		public function set centerX(_value:Number):void{
			m_filter.centerX = _value;
		}
		
		public function set centerY(_value:Number):void{
			m_filter.centerY = _value;
		}
		
		public function set lensX(_value:Number):void{
			m_filter.lensX = _value;
		}
		
		public function set lensY(_value:Number):void{
			m_filter.lensY = _value;
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

internal class FilterLensCircle extends EffectBase
{
	private var m_lensX:Number;
	private var m_lensY:Number;
	private var m_centerX:Number;
	private var m_centerY:Number;
	public function FilterLensCircle(_lensX:Number=0.45, _lensY:Number=0.38, _centerX:Number=0.5, _centerY:Number=0.5)
	{
		super();
		m_lensX = _lensX;
		m_lensY = _lensY;
		m_centerX = _centerX;
		m_centerY = _centerY;
		
	}
	
	public function get lensX():Number{
		return m_lensX;
	}
	
	public function get lensY():Number{
		return m_lensY;
	}
	
	public function get centerX():Number{
		return m_centerX;
	}
	
	public function get centerY():Number{
		return m_centerY;
	}
	
	public function set centerX(_value:Number):void{
		m_centerX = _value;
	}
	
	public function set centerY(_value:Number):void{
		m_centerY = _value;
	}
	
	public function set lensX(_value:Number):void{
		m_lensX = _value;
	}
	
	public function set lensY(_value:Number):void{
		m_lensY = _value;
	}
	
	public override function setEffectParameters(_rect:Rectangle, _sampler:TextureBase):void{
		device.setTextureAt( 0, _sampler);
		device.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0,  Vector.<Number>([m_lensX, m_lensY, m_centerX, m_centerY]));
		device.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1,  Vector.<Number>([0.0, 1.0, 2.0, 3.0]));
	}
	
	public override function clean():void{
		device.setTextureAt( 0, null);
	}
		
	public override function getFragmentProgram():ByteArray{
		return ShaderUtils.fragmentAssambler.assemble( AGALMiniAssembler.FRAGMENT,
			//	vec4 Color = texture2D(sceneTex, gl_TexCoord[0].xy);
			//	float dist = distance(gl_TexCoord[0].xy, vec2(0.5,0.5));
			//	Color.rgb *= smoothstep(lensRadius.x, lensRadius.y, dist);
			[
				"tex ft0 v0 fs0<2d,wrap,linear>", // get render to texture
				ShaderUtils.distance("ft1.x", "ft2", "v0.xy", "fc0.zw"), //distance(gl_TexCoord[0].xy, vec2(0.5,0.5)) 
				
				"mov ft2.x fc0.x",
				"mov ft2.y fc0.y",
				
				"sge ft2.z ft2.y ft2.x",// check height >= width
				"sub ft2.w fc1.y ft2.z",// 1 - result
				
				"mul ft4.x ft2.z ft2.y",
				"mul ft4.y ft2.w ft2.x",
				"add ft4.x ft4.x ft4.y",
				
				"mul ft4.y ft2.w ft2.y",
				"mul ft4.w ft2.z ft2.x",
				"add ft4.y ft4.w ft4.y",
				
				ShaderUtils.smoothstep("ft3", "ft5","ft4.x", "ft4.y", "ft1.x","fc1.z","fc1.w"),
				//"sub ft3 fc1.y ft3",
				"mul ft0 ft0 ft3", 
				"mov ft0.w fc1.y",
				
				"mov oc ft0"
				
			].join("\n")
			
		);
	}
}