/*
* EffectNightVision.as
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
	
	public class EffectNightVision extends PostProcessingEffectBase
	{
		private var m_filter:FilterNightVision;
		public function EffectNightVision(_noise:TextureMap, 
										  _mask:TextureMap, 
										  _noiseRandomize:Number, 
										  _luminanceThreshold:Number=0.2,
										  _colorAmplifaction:Number=4.0,
										  _effectCoverage:Number=1 )
		{
			super();
			effects.push(m_filter = new FilterNightVision(	_noise, _mask, 
															_noiseRandomize, 
															_luminanceThreshold,
															_colorAmplifaction,
															_effectCoverage));
		}
		
		public function get effectCoverage():Number
		{
			return m_filter.effectCoverage;
		}
		
		public function set effectCoverage(value:Number):void
		{
			m_filter.effectCoverage = value;
		}
		
		public function get colorAmplifaction():Number
		{
			return m_filter.colorAmplifaction;
		}
		
		public function set colorAmplifaction(value:Number):void
		{
			m_filter.colorAmplifaction = value;
		}
		
		public function get luminanceThreshold():Number
		{
			return m_filter.luminanceThreshold;
		}
		
		public function set luminanceThreshold(value:Number):void
		{
			m_filter.luminanceThreshold = value;
		}
		
		public function get noiseRandomize():Number
		{
			return m_filter.noiseRandomize;
		}
		
		public function set noiseRandomize(value:Number):void
		{
			m_filter.noiseRandomize = value;
		}
		
		public function get mask():TextureMap
		{
			return m_filter.mask;
		}
		
		public function set mask(value:TextureMap):void
		{
			m_filter.mask = value;
		}
		
		public function get noise():TextureMap
		{
			return m_filter.noise;
		}
		
		public function set noise(value:TextureMap):void
		{
			m_filter.noise = value;
		}
	}
}
import com.adobe.AGALMiniAssembler;
import com.yogurt3d.core.Scene3D;
import com.yogurt3d.core.render.post.EffectBase;
import com.yogurt3d.core.render.post.PostProcessingEffectBase;
import com.yogurt3d.core.texture.TextureMap;
import com.yogurt3d.utils.ShaderUtils;

import flash.display3D.Context3DProgramType;
import flash.display3D.textures.TextureBase;
import flash.geom.Rectangle;
import flash.utils.ByteArray;

internal class FilterNightVision extends EffectBase
{
	private var m_noiseRandomize:Number;//seconds
	private var m_elapsedSin:Number;
	private var m_elapsedCos:Number;
	private var m_luminanceThreshold:Number;//0.2
	private var m_colorAmplifaction:Number;//4.0
	private var m_effectCoverage:Number;//0.5
	private var m_noise:TextureMap = null;
	private var m_mask:TextureMap = null;
	public function FilterNightVision(_noise:TextureMap, 
									   _mask:TextureMap, 
									   _noiseRandomize:Number, 
									   _luminanceThreshold:Number=0.2,
									   _colorAmplifaction:Number=4.0,
									   _effectCoverage:Number=1)
	{
		super();	
		m_noise = _noise;
		m_mask = _mask;
		m_noiseRandomize = _noiseRandomize;
		m_elapsedSin = 0.4 * Math.sin(50* m_noiseRandomize);
		m_elapsedCos = 0.4 * Math.sin(50* m_noiseRandomize);
		
		m_luminanceThreshold = _luminanceThreshold;
		m_colorAmplifaction = _colorAmplifaction;
		m_effectCoverage = _effectCoverage;
	}
	
	public function get effectCoverage():Number
	{
		return m_effectCoverage;
	}
	
	public function set effectCoverage(value:Number):void
	{
		m_effectCoverage = value;
	}
	
	public function get colorAmplifaction():Number
	{
		return m_colorAmplifaction;
	}
	
	public function set colorAmplifaction(value:Number):void
	{
		m_colorAmplifaction = value;
	}
	
	public function get luminanceThreshold():Number
	{
		return m_luminanceThreshold;
	}
	
	public function set luminanceThreshold(value:Number):void
	{
		m_luminanceThreshold = value;
	}
	
	public function get noiseRandomize():Number
	{
		return m_noiseRandomize;
	}
	
	public function set noiseRandomize(value:Number):void
	{
		m_noiseRandomize = value;
		m_elapsedSin = 0.4 * Math.sin(50* m_noiseRandomize);
		m_elapsedCos = 0.4 * Math.sin(50* m_noiseRandomize);
	}
	
	public function get mask():TextureMap
	{
		return m_mask;
	}
	
	public function set mask(value:TextureMap):void
	{
		m_mask = value;
	}
	
	public function get noise():TextureMap
	{
		return m_noise;
	}
	
	public function set noise(value:TextureMap):void
	{
		m_noise = value;
	}
	
	public override function setEffectParameters(_rect:Rectangle, _sampler:TextureBase, _scene:Scene3D):void{
		device.setTextureAt( 0, _sampler);
		device.setTextureAt(1, m_noise.getTextureForDevice(device));
		device.setTextureAt(2, m_mask.getTextureForDevice(device));
		device.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0,  Vector.<Number>([
			m_elapsedSin, 
			m_elapsedCos, 
			luminanceThreshold, colorAmplifaction]));
		
		device.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1,  Vector.<Number>([effectCoverage, 3.5, 0.005, 1.0]));
		device.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2,  Vector.<Number>([0.3, 0.59, 0.11, 0.2]));
		device.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 3,  Vector.<Number>([0.1, 0.95, 0.2, 1.0]));
		
	}
	
	public override function clean():void{
		device.setTextureAt( 0, null);
		device.setTextureAt( 1, null);
		device.setTextureAt( 2, null);
	}
	
	public override function getFragmentProgram():ByteArray{
		return ShaderUtils.fragmentAssambler.assemble( AGALMiniAssembler.FRAGMENT,
			[
				//			vec2 uv;
				//			uv.x = 0.4*sin(elapsedTime*50.0);
				//			uv.y = 0.4*cos(elapsedTime*50.0);
				//			float m = texture2D(maskTex, gl_TexCoord[0].st).r;
				//			vec3 n = texture2D(noiseTex,
				//				(gl_TexCoord[0].st*3.5) + uv).rgb;
				//			vec3 c = texture2D(sceneBuffer, gl_TexCoord[0].st
				//				+ (n.xy*0.005)).rgb;
				//			
				//			float lum = dot(vec3(0.30, 0.59, 0.11), c);
				//			if (lum < luminanceThreshold)
				//				c *= colorAmplification; 
				//			
				//			vec3 visionColor = vec3(0.1, 0.95, 0.2);
				//			finalColor.rgb = (c + (n*0.2)) * visionColor * m;
				
				"tex ft1 v0 fs2<2d,wrap,linear>",// get mask
				"mov ft2.x ft1.x",//float m = texture2D(maskTex, gl_TexCoord[0].st).r;
				
				"mul ft1.xy v0.xy fc1.y",//(gl_TexCoord[0].st*3.5)
				"add ft1.xy ft1.xy fc0.xy",//(gl_TexCoord[0].st*3.5) + uv
				"tex ft1 ft1.xy fs1<2d,wrap,linear>",//vec3 n = texture2D(noiseTex,(gl_TexCoord[0].st*3.5) + uv).rgb;
				
				"mul ft0.xy ft1.xy fc1.z",//(n.xy*0.005)
				"add ft0.xy v0.xy ft0.xy",//gl_TexCoord[0].st + (n.xy*0.005)
				"tex ft0 ft0.xy fs0<2d,wrap,linear>",//vec3 c = texture2D(sceneBuffer, gl_TexCoord[0].st+ (n.xy*0.005)).rgb;
				
				"dp3 ft2.y fc2.xyz ft0",//float lum = dot(vec3(0.30, 0.59, 0.11), c);
				
				"slt ft2.z ft2.y fc0.z",//if (lum < luminanceThreshold)
				"sub ft2.w fc1.w ft2.z",//1 - result
				
				"mul ft4 ft0 fc0.w",//c *= colorAmplification; 
				"mul ft4 ft4 ft2.z",
				"mul ft5 ft0 ft2.w",
				
				"add ft0 ft4 ft5",
				
				//	finalColor.rgb = (c + (n*0.2)) * visionColor * m;
				"mul ft1 ft1 fc2.w",// (n*0.2)
				"add ft0 ft0 ft1", //(c + (n*0.2))
				"mul ft0 ft0 fc3.xyz", //(c + (n*0.2)) * visionColor 
				"mul ft0 ft0 ft2.x",
				
				// effect coverage
				"slt ft2.x v0.x fc1.x",
				"sub ft2.y fc1.w ft2.x",
				
				"mul ft3 ft0 ft2.x",
				"tex ft4 v0 fs0<2d,wrap,linear>",
				"mul ft4 ft4 ft2.y",
				"add ft0 ft3 ft4",
				
				"mov ft0.w fc1.w",
				
				"mov oc ft0"
				
			].join("\n")
			
		);
	}
}