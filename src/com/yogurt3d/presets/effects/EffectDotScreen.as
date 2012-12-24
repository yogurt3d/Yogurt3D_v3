/*
* EffectDotScreen.as
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
	
	public class EffectDotScreen extends PostProcessingEffectBase
	{	
		private var m_filter:FilterDotScreen;
		
		public function EffectDotScreen(_centerX:Number=400, _centerY:Number=300, _angle:Number=1.1, _scale:Number=3.0)
		{
			super();
		
			effects.push( m_filter = new FilterDotScreen(_centerX, _centerY, _angle, _scale) );
	
		}
		
		public function get scale():Number
		{
			return m_filter.scale;
		}
		
		public function set scale(value:Number):void
		{
			m_filter.scale = value;
		}
		
		public function get angle():Number
		{
			return m_filter.angle;
		}
		
		public function set angle(value:Number):void
		{
			m_filter.angle = value;
		}
		
		public function get centerY():Number
		{
			return m_filter.centerY;
		}
		
		public function set centerY(value:Number):void
		{
			m_filter.centerY = value;
		}
		
		public function get centerX():Number
		{
			return m_filter.centerX;
		}
		
		public function set centerX(value:Number):void
		{
			m_filter.centerX = value;
		}
	}
}


import com.adobe.AGALMiniAssembler;
import com.yogurt3d.core.render.post.EffectBase;
import com.yogurt3d.core.utils.MathUtils;
import com.yogurt3d.core.utils.ShaderUtils;

import flash.display3D.Context3DProgramType;
import flash.display3D.textures.TextureBase;
import flash.geom.Rectangle;
import flash.utils.ByteArray;

internal class FilterDotScreen extends EffectBase
{
	private var m_centerX:Number;
	private var m_centerY:Number;
	private var m_angle:Number;
	private var m_scale:Number;
	
	public function FilterDotScreen(_centerX:Number=400, _centerY:Number=300, _angle:Number=1.1, _scale:Number=3.0)
	{
		super();
		m_centerX = _centerX;
		m_centerY = _centerY;
		m_angle = _angle;
		m_scale = _scale;
	}
	
	public function get scale():Number
	{
		return m_scale;
	}
	
	public function set scale(value:Number):void
	{
		m_scale = value;
	}
	
	public function get angle():Number
	{
		return m_angle;
	}
	
	public function set angle(value:Number):void
	{
		m_angle = value;
	}
	
	public function get centerY():Number
	{
		return m_centerY;
	}
	
	public function set centerY(value:Number):void
	{
		m_centerY = value;
	}
	
	public function get centerX():Number
	{
		return m_centerX;
	}
	
	public function set centerX(value:Number):void
	{
		m_centerX = value;
	}
	
	public override function setEffectParameters(_rect:Rectangle, _sampler:TextureBase):void{
		device.setTextureAt( 0, _sampler);
	
		var width:uint = MathUtils.getClosestPowerOfTwo(_rect.width);
		var height:uint = MathUtils.getClosestPowerOfTwo(_rect.height);
		device.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0,  Vector.<Number>([m_centerX, m_centerY, width, height]));
		device.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1,  Vector.<Number>([Math.sin(m_angle), Math.cos(m_angle), m_scale, 4.0]));
		device.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2,  Vector.<Number>([10.0, 5.0, 3.0, 1.0]));
		
	}
	
	public override function clean():void{
		device.setTextureAt( 0, null);
	}
		
	public override function getFragmentProgram():ByteArray{
		
		return ShaderUtils.fragmentAssambler.assemble( AGALMiniAssembler.FRAGMENT,
			
			[
				"tex ft0 v0 fs0<2d,clamp,nearest>", // get render to texture
				
				"add ft1.x ft0.x ft0.y",
				"add ft1.x ft1.x ft0.z",
				"div ft1.x ft1.x fc2.z",//float average = (color.r + color.g + color.b) / 3.0;
				"mul ft1.x ft1.x fc2.x",//average * 10.0
				"sub ft1.x ft1.x fc2.y",//average * 10.0 - 5.0
				
				//pattern
				"mul ft2.xy v0.xy fc0.zw",// vec2 tex = texCoord * texSize - center;
				"sub ft2.xy ft2.xy fc0.xy",
				
				"mul ft3.x fc1.x ft2.x",// s * tex.x
				"mul ft3.y fc1.x ft2.y",//s * tex.y
				
				"mul ft3.z fc1.y ft2.x",// c * tex.x
				"mul ft3.w fc1.y ft2.y",//c * tex.y
				
				"sub ft4.x ft3.z ft3.y",//c * tex.x - s * tex.y
				"add ft4.y ft3.x ft3.w",//s * tex.x + c * tex.y
				
				"mul ft4.xy ft4.xy fc1.z",
				
				"sin ft4.x ft4.x",//sin(point.x)
				"sin ft4.y ft4.y",//sin(point.y)
				"mul ft4.x ft4.x ft4.y",//(sin(point.x) * sin(point.y))
				"mul ft4.x ft4.x fc1.w",
				
				"add ft1.x ft1.x ft4.x",//vec3(average * 10.0 - 5.0 + pattern()
				"mov ft1.y fc2.w",
				
				"mov oc ft1.xxxy"
				
			].join("\n")
			
		);
	}
}