/*
* LightFunctions.as
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

package com.yogurt3d.core.material
{
	import com.yogurt3d.core.agalgen.AGALGEN;
	import com.yogurt3d.core.agalgen.IRegister;
	import com.yogurt3d.core.material.parameters.LightInput;

	public class LightFunctions
	{
//		public static function Lambert(input:LightInput, gen:AGALGEN):String{
//			var code:String = "\n\n//****LightFunction START****/\n";
//			var NdotL:IRegister = gen.createFT("NdotL",1);
//			
//			code += "// N.L \n";
//			code += "dp3 " + NdotL + " " + input.Normal + " " + input.lightDirection + "\n";
//			code += "sat " + NdotL + " " + NdotL + "\n";
//			gen.destroyTemp( input.Normal.id );
//			gen.destroyTemp( input.lightDirection.id );
//			
//			var result:IRegister = gen.createFT("result",4);
//			code += "\n// result = color * lambert * lightColor * att \n"; 
//			code += "mul "+ result.x + " " + input.atteniation + " " + NdotL + "\n";
//			code += "mul "+ result.xyz + " " + input.lightColor + " " + result.xxx + "\n";
//			code += "mul "+ result.xyz + " " + input.Albedo + " " + result.xyz + "\n";
//			gen.destroyTemp( input.atteniation.id );
//			gen.destroyTemp( input.Albedo.id );
//			
//			code += "\n//color.a = surfaceAlpha; \n";
//			code += "mov "+ result.w + " " + input.Alpha + "\n";
//			gen.destroyTemp( input.Alpha.id );			
//			code += "//****LightFunction END****/\n";
//			
//			
//			return code;
//		}
	}
}