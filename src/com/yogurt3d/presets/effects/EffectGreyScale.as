/*
* EffectGreyScale.as
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
	
	public class EffectGreyScale extends PostProcessingEffectBase
	{
		
		public function EffectGreyScale()
		{
			super();
			effects.push(new FilterGreyScale());
		}
	}
}
import com.adobe.AGALMiniAssembler;
import com.yogurt3d.core.render.post.EffectBase;
import com.yogurt3d.core.render.post.PostProcessingEffectBase;
import com.yogurt3d.core.utils.ShaderUtils;

import flash.display3D.Context3DProgramType;
import flash.display3D.textures.TextureBase;
import flash.geom.Rectangle;
import flash.utils.ByteArray;

internal class FilterGreyScale extends EffectBase
{
	public function FilterGreyScale()
	{
		super();
	}
	
	public override function setEffectParameters(_rect:Rectangle, _sampler:TextureBase):void{
		device.setTextureAt( 0, _sampler);
		device.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0,  Vector.<Number>([0.299, 0.587, 0.114, 1.0]));
	}
	
	public override function clean():void{
		device.setTextureAt( 0, null);
	}
		
	public override function getFragmentProgram():ByteArray{
		return ShaderUtils.fragmentAssambler.assemble( AGALMiniAssembler.FRAGMENT,
			[
				"tex ft0 v0 fs0<2d,wrap,linear>",				
				"dp3 ft1.x ft0.xyz fc0.xyz",
				"mov ft1.y fc0.w",
				
				"mov oc ft1.xxxy"
				
			].join("\n")
		);
	}
}