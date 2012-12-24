/*
* EffectLaplacian.as
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
	
	public class EffectLaplacian extends PostProcessingEffectBase
	{

		public function EffectLaplacian()
		{
			super();		
			effects.push(new FilterLaplacian());
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
import flash.utils.Dictionary;

internal class FilterLaplacian extends EffectBase
{
	private var m_offset:Dictionary;
	
	public function FilterLaplacian()
	{
		super();
		
		m_offset = new Dictionary();
		m_offset["0x"] = "fc0.z"; m_offset["0y"] = "fc0.w"; 
		m_offset["1x"] = "fc1.w"; m_offset["1y"] = "fc0.w"; 
		m_offset["2x"] = "fc0.x"; m_offset["2y"] = "fc0.w"; 
		m_offset["3x"] = "fc0.z"; m_offset["3y"] = "fc1.w";
		m_offset["4x"] = "fc1.w"; m_offset["4y"] = "fc1.w";
		m_offset["5x"] = "fc0.x"; m_offset["5y"] = "fc1.w";
		m_offset["6x"] = "fc0.z"; m_offset["6y"] = "fc0.y";
		m_offset["7x"] = "fc1.w"; m_offset["7y"] = "fc0.y";
		m_offset["8x"] = "fc0.x"; m_offset["8y"] = "fc0.y";
		
	}
	
	
	public override function setEffectParameters(_rect:Rectangle, _sampler:TextureBase):void{
		device.setTextureAt( 0, _sampler);
		
		var width:uint = MathUtils.getClosestPowerOfTwo(_rect.width);
		var height:uint = MathUtils.getClosestPowerOfTwo(_rect.height);
		
		var stepW:Number = 1/width;
		var stepH:Number = 1/height;
		
		device.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0,  Vector.<Number>([stepW, stepH, -stepW, -stepH]));
		device.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1,  Vector.<Number>([-4.0, 2.0, 1.0, 0.0]));
	}
	
	public override function clean():void{
		device.setTextureAt( 0, null);
	}
	
	private function getOffset(_index:uint):String{
		
		var code:String = [	
			"mov ft1.x "+ m_offset[_index+"x"],
			"mov ft1.y "+ m_offset[_index+"y"]+"\n"
		].join("\n");
		
		return code;
	}
	
	public override function getFragmentProgram():ByteArray{
		
		var code:String = "mov ft0 fc1.wwww\n";
		
		
		for( var i:uint = 0; i < 9; i++){
			
			code += [
				getOffset(i),
				"add ft1.xy ft1.xy v0.xy",
				"tex ft1 ft1.xy fs0<2d,wrap,linear>\n",
			].join("\n");
			
			if(i % 2 == 1)
				code += "mul ft1 ft1 fc1.z\n";
			else if(i == 4)
				code += "mul ft1 ft1 fc1.x\n";
			else
				code += "mul ft1 ft1 fc1.w\n";
			
			code += "add ft0 ft0 ft1\n"
		}
		
		code += [
			"mov ft0.w fc1.z",
			"mov oc ft0"
		].join("\n");
		return ShaderUtils.fragmentAssambler.assemble( AGALMiniAssembler.FRAGMENT, code);
	}
}