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
	
	import flash.display3D.Context3DProgramType;
	
	public class EffectDOF extends PostProcessingEffectBase
	{
		private var blur0:FilterDOFBlur0;
		private var blur1:FilterDOFBlur1;
		private var combine:FilterDOFCombine;
		public function EffectDOF()
		{
			super();
			
			needsDepth = true;
			needOriginalScene = true;
			
			effects.push(blur0 = new FilterDOFBlur0());
			effects.push(blur1 = new FilterDOFBlur1());
			effects.push(combine = new FilterDOFCombine());
				
		}
		
		public function get fstop():Number
		{
			return combine.fstop;
		}
		
		public function set fstop(value:Number):void
		{
			combine.fstop = value;
		}
		
		public function get vignfade():Number
		{
			return combine.vignfade;
		}
		
		public function set vignfade(value:Number):void
		{
			combine.vignfade = value;
		}
		
		public function get vigin():Number
		{
			return combine.vigin;
		}
		
		public function set vigin(value:Number):void
		{
			combine.vigin = value;
		}
		
		public function get vignout():Number
		{
			return combine.vignout;
		}
		
		public function set vignout(value:Number):void
		{
			combine.vignout = value;
		}
		
		public function get vignette():Boolean
		{
			return combine.vignette;
		}
		
		public function set vignette(value:Boolean):void
		{
			combine.vignette = value;
		}
		
		
		public function get focus():Number
		{
			return combine.focus;
		}
		
		public function set focus(value:Number):void
		{
			combine.focus = value;
		}
		
		public function get range():Number
		{
			return combine.range;
		}
		
		public function set range(value:Number):void
		{
			combine.range = value;
		}
		
		
		public function get sampleDist0():Number
		{
			return blur0.sampleDist0;
		}
		
		public function set sampleDist0(value:Number):void
		{
			blur0.sampleDist0 = value;
		}
		
		public function get sampleDist1():Number
		{
			return blur1.sampleDist1;
		}
		
		public function set sampleDist1(value:Number):void
		{
			blur1.sampleDist1 = value;
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
import flash.utils.Dictionary;


internal class FilterDOFCombine extends EffectBase
{
	private var m_range:Number;
	private var m_focus:Number;
	
	private var m_vignette:Boolean;
	private var m_vignout:Number = 1.3;
	private var m_vigin:Number = 0.0;
	private var m_vignfade:Number = 22.0;
	private var m_fstop:Number = 1.0;
	
	
	public function FilterDOFCombine(_range:Number=4.6, _focus:Number=0.48,_vignette:Boolean=true)
	{
		super();		
		
		m_range = _range;
		m_focus = _focus;
		m_vignette = _vignette;
	}
	
	public function get fstop():Number
	{
		return m_fstop;
	}
	
	public function set fstop(value:Number):void
	{
		m_fstop = value;
	}
	
	public function get vignfade():Number
	{
		return m_vignfade;
	}
	
	public function set vignfade(value:Number):void
	{
		m_vignfade = value;
	}
	
	public function get vigin():Number
	{
		return m_vigin;
	}
	
	public function set vigin(value:Number):void
	{
		m_vigin = value;
	}
	
	public function get vignout():Number
	{
		return m_vignout;
	}
	
	public function set vignout(value:Number):void
	{
		m_vignout = value;
	}
	
	public function get vignette():Boolean
	{
		return m_vignette;
	}
	
	public function set vignette(value:Boolean):void
	{
		m_vignette = value;
		//key = "FilterDOF"+(value?"withVignette":"");
	}
	
	public function get focus():Number
	{
		return m_focus;
	}
	
	public function set focus(value:Number):void
	{
		m_focus = value;
	}
	
	public function get range():Number
	{
		return m_range;
	}
	
	public function set range(value:Number):void
	{
		m_range = value;
	}
	
	public override function setEffectParameters(_rect:Rectangle, _sampler:TextureBase, _scene:Scene3D):void{
		device.setTextureAt( 0, _sampler);
		device.setTextureAt( 1, _scene.sceneRenderer.getTextureForDevice(device));
		device.setTextureAt( 2, _scene.depthRenderer.getTextureForDevice(device));
	
		device.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0,  Vector.<Number>([focus, range, 0.0, 1.0]));
		device.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1,  Vector.<Number>([(1.0/255.0),vignout+(fstop/vignfade), vigin+(fstop/vignfade), 0.5]));
		device.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2,  Vector.<Number>([2.0, 3.0, 0.0, 0.0]));
	}
	
	public override function clean():void{
		device.setTextureAt( 0, null);
		device.setTextureAt( 1, null);
		device.setTextureAt( 2, null);
	}
	
	public override function getFragmentProgram():ByteArray{
		var code:String = [
			"tex ft0 v0 fs0<2d,wrap,linear>", //  vec4 blur  = texture2D(Blur1, vTexCoord);			
			"tex ft1 v0 fs1<2d,wrap,linear>",// vec4 sharp = texture2D(RT,    vTexCoord);
			"tex ft5 v0 fs2<2d,wrap,linear>",
			ShaderUtils.decodeOnlyDepth("ft4.x","ft5","fc1.x"),
//			
			"sub ft2.x fc0.x ft4.x",// focus - depth	
			"abs ft2.x ft2.x",//abs(focus - depth)
			"mul ft2.x ft2.x fc0.y",//range * abs(focus - depth)
			ShaderUtils.clamp("ft2.y","ft2.x","fc0.z", "fc0.w"),
			"sub ft2.z fc0.w ft2.y",
			ShaderUtils.mix("ft3","ft4","ft1","ft0","ft2.y","ft2.z")+"\n",
			
		].join("\n");
		
		if(vignette){
			
			code += [
				
				"mov ft4.zw fc1.ww",
				ShaderUtils.distance("ft4.x","ft5","v0.xy","ft4.zw"),
				"mov ft4.y fc1.y",//vignout+(fstop/vignfade)
				"mov ft4.z fc1.z",//vigin+(fstop/vignfade)
				
				ShaderUtils.smoothstep("ft5","ft6","ft4.y","ft4.z","ft4.x","fc2.x","fc2.y"),
				ShaderUtils.clamp("ft6","ft5","fc0.z","fc0.w"),
				"mul ft3 ft6 ft3\n"
				
			].join("\n");
		}
		
		code += [
			"mov ft3.w fc0.z",
			"mov oc ft3"
		].join("\n");
		
		return ShaderUtils.fragmentAssambler.assemble( AGALMiniAssembler.FRAGMENT, code);
	}
}

internal class FilterDOFBlur0 extends EffectBase
{
	private var m_sampleDist0:Number;
	private var m_samples:Dictionary;
	
	public function FilterDOFBlur0(_sampleDist0:Number=0.01980)
	{
		super();		
		
		m_sampleDist0 = _sampleDist0;
		
		m_samples = new Dictionary();
		m_samples["0"] = "fc0.xy"; m_samples["1"] = "fc0.zw";
		m_samples["2"] = "fc1.xy"; m_samples["3"] = "fc1.zw";
		m_samples["4"] = "fc2.xy"; m_samples["5"] = "fc2.zw"; 
		m_samples["6"] = "fc3.xy"; m_samples["7"] = "fc3.zw";
		m_samples["8"] = "fc4.xy"; m_samples["9"] = "fc4.zw";
		m_samples["10"] = "fc5.xy"; m_samples["11"] = "fc5.zw";
	}
	
	public function get sampleDist0():Number
	{
		return m_sampleDist0;
	}
	
	public function set sampleDist0(value:Number):void
	{
		m_sampleDist0 = value;
	}
	
	public override function setEffectParameters(_rect:Rectangle, _sampler:TextureBase, _scene:Scene3D):void{
			device.setTextureAt( 0, _sampler);
			device.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0,  Vector.<Number>([-0.326212 * m_sampleDist0, -0.405805 * m_sampleDist0, -0.840144 * m_sampleDist0, -0.073580 * m_sampleDist0]));
			device.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1,  Vector.<Number>([-0.695914 * m_sampleDist0,  0.457137 * m_sampleDist0, -0.203345 * m_sampleDist0,  0.620716 * m_sampleDist0]));
			device.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2,  Vector.<Number>([0.962340 * m_sampleDist0, -0.194983 * m_sampleDist0, 0.473434 * m_sampleDist0, -0.480026 * m_sampleDist0]));
			device.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 3,  Vector.<Number>([0.519456 * m_sampleDist0,  0.767022 * m_sampleDist0, 0.185461 * m_sampleDist0, -0.893124 * m_sampleDist0]));
			device.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 4,  Vector.<Number>([0.507431 * m_sampleDist0,  0.064425 * m_sampleDist0, 0.896420 * m_sampleDist0,  0.412458 * m_sampleDist0]));
			device.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 5,  Vector.<Number>([-0.321940 * m_sampleDist0, -0.932615 * m_sampleDist0, -0.791559 * m_sampleDist0, -0.597705 * m_sampleDist0]));
			device.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 6,  Vector.<Number>([13.0, 0.0, 0.0, 0.0]));
	}
	
	public override function clean():void{
		device.setTextureAt( 0, null);
	}
	
	public override function getFragmentProgram():ByteArray{
		var code:String = "tex ft0 v0 fs0<2d,wrap,linear>\n";
			
		for(var i:uint = 0; i < 12; i++){
			code += [
				"add ft1.xy v0.xy "+m_samples[i+""],
				"tex ft2 ft1.xy fs0<2d,wrap,linear>",
				"add ft0 ft0 ft2\n"
			].join("\n");	
		}
		
		code += [
			"div ft0 ft0 fc6.x",
			"mov oc ft0"
		].join("\n");
		
		return ShaderUtils.fragmentAssambler.assemble( AGALMiniAssembler.FRAGMENT, code);
	}
}

internal class FilterDOFBlur1 extends EffectBase
{
	private var m_sampleDist1:Number;
	private var m_samples:Dictionary;
	
	public function FilterDOFBlur1(_sampleDist1:Number=0.019200)
	{
		super();		
		
		m_sampleDist1 = _sampleDist1;
		
		m_samples = new Dictionary();
		m_samples["0"] = "fc0.xy"; m_samples["1"] = "fc0.zw";
		m_samples["2"] = "fc1.xy"; m_samples["3"] = "fc1.zw";
		m_samples["4"] = "fc2.xy"; m_samples["5"] = "fc2.zw"; 
		m_samples["6"] = "fc3.xy"; m_samples["7"] = "fc3.zw";
		m_samples["8"] = "fc4.xy"; m_samples["9"] = "fc4.zw";
		m_samples["10"] = "fc5.xy"; m_samples["11"] = "fc5.zw";
	}
	
	public function get sampleDist1():Number
	{
		return m_sampleDist1;
	}
	
	public function set sampleDist1(value:Number):void
	{
		m_sampleDist1 = value;
	}
	
	
	public override function setEffectParameters(_rect:Rectangle, _sampler:TextureBase, _scene:Scene3D):void{
		device.setTextureAt( 0, _sampler);
		device.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0,  Vector.<Number>([-0.326212 * m_sampleDist1, -0.405805 * m_sampleDist1, -0.840144 * m_sampleDist1, -0.073580 * m_sampleDist1]));
		device.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1,  Vector.<Number>([-0.695914 * m_sampleDist1,  0.457137 * m_sampleDist1, -0.203345 * m_sampleDist1,  0.620716 * m_sampleDist1]));
		device.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2,  Vector.<Number>([0.962340 * m_sampleDist1, -0.194983 * m_sampleDist1, 0.473434 * m_sampleDist1, -0.480026 * m_sampleDist1]));
		device.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 3,  Vector.<Number>([0.519456 * m_sampleDist1,  0.767022 * m_sampleDist1, 0.185461 * m_sampleDist1, -0.893124 * m_sampleDist1]));
		device.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 4,  Vector.<Number>([0.507431 * m_sampleDist1,  0.064425 * m_sampleDist1, 0.896420 * m_sampleDist1,  0.412458 * m_sampleDist1]));
		device.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 5,  Vector.<Number>([-0.321940 * m_sampleDist1, -0.932615 * m_sampleDist1, -0.791559 * m_sampleDist1, -0.597705 * m_sampleDist1]));
		device.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 6,  Vector.<Number>([13.0, 0.0, 0.0, 0.0]));
	}
	
	public override function clean():void{
		device.setTextureAt( 0, null);
	}
	
	public override function getFragmentProgram():ByteArray{
		var code:String = "tex ft0 v0 fs0<2d,wrap,linear>\n";
		
		for(var i:uint = 0; i < 12; i++){
			code += [
				"add ft1.xy v0.xy "+m_samples[i+""],
				"tex ft2 ft1.xy fs0<2d,wrap,linear>",
				"add ft0 ft0 ft2\n"
			].join("\n");	
		}
		
		code += [
			"div ft0 ft0 fc6.x",
			"mov oc ft0"
		].join("\n");
		
		return ShaderUtils.fragmentAssambler.assemble( AGALMiniAssembler.FRAGMENT, code);
	}
}

