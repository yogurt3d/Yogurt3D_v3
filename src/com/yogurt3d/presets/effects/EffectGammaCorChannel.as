/*
* EffectGammaCorChannel.as
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
	
	public class EffectGammaCorChannel extends PostProcessingEffectBase
	{
		private var m_filter:FilterGammaCorChannel;
		
		public function EffectGammaCorChannel(_gammaR:Number, _gammaG:Number, _gammaB:Number)
		{
			super();
					
			effects.push( m_filter = new FilterGammaCorChannel(_gammaR, _gammaG, _gammaB) );
		}
		
		public function get gammaR():Number{
			return m_filter.gammaR;
		}
		
		public function get gammaG():Number{
			return m_filter.gammaG;
		}
		
		public function get gammaB():Number{
			return m_filter.gammaB;
		}
		
		public function set gammaR(_value:Number):void{
			m_filter.gammaR = _value;
		}
		
		public function set gammaG(_value:Number):void{
			m_filter.gammaG = _value;
		}
		
		public function set gammaB(_value:Number):void{
			m_filter.gammaB = _value;
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

internal class FilterGammaCorChannel extends EffectBase
{
	
	private var m_gammaR:Number;
	private var m_gammaG:Number;
	private var m_gammaB:Number;
	
	public function FilterGammaCorChannel(_gammaR:Number, _gammaG:Number, _gammaB:Number)
	{
		super();
		
		m_gammaR = _gammaR;
		m_gammaG = _gammaG;
		m_gammaB = _gammaB;
	}
	
	public function get gammaR():Number{
		return m_gammaR;
	}
	
	public function get gammaG():Number{
		return m_gammaG;
	}
	
	public function get gammaB():Number{
		return m_gammaB;
	}
	
	public function set gammaR(_value:Number):void{
		m_gammaR = _value;
	}
	
	public function set gammaG(_value:Number):void{
		m_gammaG = _value;
	}
	
	public function set gammaB(_value:Number):void{
		m_gammaB = _value;
	}
	
	public override function setEffectParameters(_rect:Rectangle, _sampler:TextureBase, _scene:Scene3D):void{
		device.setTextureAt( 0, _sampler);
		device.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0,  Vector.<Number>([0.5, 0.5, 0.0, 1.0]));
		device.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1,  Vector.<Number>([m_gammaR, m_gammaG, m_gammaB, 1.0]));
	}
	
	public override function clean():void{
		device.setTextureAt( 0, null);
	}
	
	public override function getFragmentProgram():ByteArray{
		//outColor.rgb = pow(color, 1.0 / gammaRGB);
		
		return ShaderUtils.fragmentAssambler.assemble( AGALMiniAssembler.FRAGMENT,
			[
				"tex ft0 v0 fs0<2d,wrap,linear>", // get render to texture
				"mov ft4 fc1",
				"mov ft4.x fc1.x",
				"mov ft4.y fc1.y",
				"mov ft4.z fc1.z",
				"div ft4 fc1.w ft4",
				
				"pow ft1 ft0 ft4", //pow(color, 1.0 / gammaRGB)
				"slt ft2 ft0.x fc1.x",//if (color[0].r < 0.50)
				"mul ft1 ft2 ft1", // outColor.rgb = pow(color, 1.0 / gammaRGB);
				
				"sub ft3 fc0.w ft1", // else outColor.rgb = color;
				"mul ft0 ft0 ft3",
				
				"add ft0 ft0 ft1",
				"mov ft0.w fc0.w",
				
				"mov oc ft0"
				
			].join("\n")
		);
	}
}