/*
* EffectPixelation.as
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
	
	public class EffectPixelation extends PostProcessingEffectBase
	{
		private var m_filter:FilterPixelation;
		public function EffectPixelation(_pixelWidth:Number=15.0, _pixelHeight:Number=10.0)
		{
			super();
			
			effects.push( m_filter = new FilterPixelation(_pixelWidth, _pixelHeight) );
		}
		
		public function get pixelWidth():Number{
			return m_filter.pixelWidth;
		}
		
		public function get pixelHeight():Number{
			return m_filter.pixelHeight;
		}
		
		public function set pixelWidth(_value:Number):void{
			m_filter.pixelWidth = _value;
		}
		
		public function set pixelHeight(_value:Number):void{
			m_filter.pixelHeight = _value;
		}
	}
}
import com.adobe.AGALMiniAssembler;
import com.yogurt3d.core.render.post.EffectBase;
import com.yogurt3d.core.render.post.PostProcessingEffectBase;
import com.yogurt3d.core.utils.MathUtils;
import com.yogurt3d.core.utils.ShaderUtils;

import flash.display3D.Context3DProgramType;
import flash.display3D.textures.TextureBase;
import flash.geom.Rectangle;
import flash.utils.ByteArray;

internal class FilterPixelation extends EffectBase
{
	private var m_pixelWidth:Number;
	private var m_pixelHeight:Number;
	
	
	public function FilterPixelation(_pixelWidth:Number=15.0, _pixelHeight:Number=10.0)
	{
		super();
		m_pixelWidth = _pixelWidth;
		m_pixelHeight = _pixelHeight;
	}
	
	public function get pixelWidth():Number{
		return m_pixelWidth;
	}
	
	public function get pixelHeight():Number{
		return m_pixelHeight;
	}
	
	public function set pixelWidth(_value:Number):void{
		m_pixelWidth = _value;
	}
	
	public function set pixelHeight(_value:Number):void{
		m_pixelHeight = _value;
	}
	
	public override function clean():void{
		device.setTextureAt( 0, null);
	}
	
	public override function setEffectParameters(_rect:Rectangle, _sampler:TextureBase):void{
		device.setTextureAt( 0, _sampler);
		
		var width:uint = MathUtils.getClosestPowerOfTwo(_rect.width);
		var height:uint = MathUtils.getClosestPowerOfTwo(_rect.height);
		
		var dx:Number = 1.0/width * m_pixelWidth;
		var dy:Number = 1.0/height * m_pixelHeight;
		
		device.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0,  Vector.<Number>([dx, dy, 1.0, 0.0]));
	}
	
	public override function getFragmentProgram():ByteArray{
		//			float dx = pixel_w*(1./rt_w);
		//			float dy = pixel_h*(1./rt_h);
		//			vec2 coord = vec2(dx*floor(uv.x/dx),
		//				dy*floor(uv.y/dy));
		//			tc = texture2D(sceneTex, coord).rgb;
		
		return ShaderUtils.fragmentAssambler.assemble( AGALMiniAssembler.FRAGMENT,
			
			[
				
				"tex ft0 v0 fs0<2d,wrap,linear>", // get render to texture
				
				"div ft1.x v0.x fc0.x",
				ShaderUtils.floorAGAL("ft2.x","ft1.x"),
				"mul ft1.x ft2.x fc0.x",
				
				"div ft1.y v0.y fc0.y",
				ShaderUtils.floorAGAL("ft2.x","ft1.y"),
				"mul ft1.y ft2.x fc0.y",
				
				"tex ft0 ft1.xy fs0<2d,wrap,linear>",
				
				"mov ft0.w fc0.z",
				
				"mov oc ft0"
				
			].join("\n")
			
		);
	}
}