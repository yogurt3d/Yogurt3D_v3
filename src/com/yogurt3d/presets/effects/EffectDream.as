/*
* EffectDream.as
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

public class EffectDream extends PostProcessingEffectBase
	{
		
		public function EffectDream()
		{
			super();
			effects.push(new FilterDream());
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

internal class FilterDream extends EffectBase
{
	public function FilterDream()
	{
		super();		
	}
	
	public override function setEffectParameters(_rect:Rectangle, _sampler:TextureBase, _scene:Scene3D):void{
			device.setTextureAt( 0, _sampler);
			device.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0,  Vector.<Number>([0.001, 0.003, 0.005, 0.007]));
			device.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1,  Vector.<Number>([0.009, 0.011, 3.0, 9.5]));
	}
	
	public override function clean():void{
		device.setTextureAt( 0, null);
	}
	
	public override function getFragmentProgram():ByteArray{
		return ShaderUtils.fragmentAssambler.assemble( AGALMiniAssembler.FRAGMENT,
			[
				
				"tex ft0 v0 fs0<2d,wrap,linear>",
				"add ft1 v0 fc0.x",// uv+0.001
				"tex ft1 ft1 fs0<2d,wrap,linear>",//texture2D(sceneTex, uv+0.001);
				"add ft0 ft0 ft1",
				
				"add ft1 v0 fc0.y",// uv+0.003
				"tex ft1 ft1 fs0<2d,wrap,linear>",//texture2D(sceneTex, uv+0.003);
				"add ft0 ft0 ft1",
				
				"add ft1 v0 fc0.z",// uv+0.005
				"tex ft1 ft1 fs0<2d,wrap,linear>",//texture2D(sceneTex, uv+0.005);
				"add ft0 ft0 ft1",
				
				"add ft1 v0 fc0.w",// uv+0.007
				"tex ft1 ft1 fs0<2d,wrap,linear>",//texture2D(sceneTex, uv+0.007);
				"add ft0 ft0 ft1",
				
				"add ft1 v0 fc1.x",// uv+0.009
				"tex ft1 ft1 fs0<2d,wrap,linear>",//texture2D(sceneTex, uv+0.009);
				"add ft0 ft0 ft1",
				
				"add ft1 v0 fc1.y",// uv+0.011
				"tex ft1 ft1 fs0<2d,wrap,linear>",//texture2D(sceneTex, uv+0.011);
				"add ft0 ft0 ft1",
				
				"sub ft1 v0 fc0.x",// uv-0.001
				"tex ft1 ft1 fs0<2d,wrap,linear>",//texture2D(sceneTex, uv-0.001);
				"add ft0 ft0 ft1",
				
				"sub ft1 v0 fc0.y",// uv-0.003
				"tex ft1 ft1 fs0<2d,wrap,linear>",//texture2D(sceneTex, uv-0.003);
				"add ft0 ft0 ft1",
				
				"sub ft1 v0 fc0.z",// uv-0.005
				"tex ft1 ft1 fs0<2d,wrap,linear>",//texture2D(sceneTex, uv-0.005);
				"add ft0 ft0 ft1",
				
				"sub ft1 v0 fc0.w",// uv-0.007
				"tex ft1 ft1 fs0<2d,wrap,linear>",//texture2D(sceneTex, uv-0.007);
				"add ft0 ft0 ft1",
				
				"sub ft1 v0 fc1.x",// uv-0.009
				"tex ft1 ft1 fs0<2d,wrap,linear>",//texture2D(sceneTex, uv-0.009);
				"add ft0 ft0 ft1",
				
				"sub ft1 v0 fc1.y",// uv-0.011
				"tex ft1 ft1 fs0<2d,wrap,linear>",//texture2D(sceneTex, uv-0.011);
				"add ft0 ft0 ft1",
				
				"mov ft2 ft0.x",
				"add ft2 ft2 ft0.y",
				"add ft2 ft2 ft0.z",
				"div ft0.xyz ft2.xyz fc1.z",// vec3((c.r+c.g+c.b)/3.0);
				"div ft0 ft0 fc1.w",// c = c / 9.5;
				"mov oc ft0"
				
			].join("\n")
		);
	}
}
