/*
* IRegister.as
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

package com.yogurt3d.core.material.agalgen
{
	import com.yogurt3d.core.material.enum.ERegisterShaderType;

	public interface IRegister
	{
		function get index()			:int;
		function get id()				:String;
		function get read()				:Boolean;
		function get write()			:Boolean;
		function get shaderType()		:ERegisterShaderType;
		function toString()				:String;
	
		function get x()				:IRegister;
		function get xx()				:IRegister;
		function get xxx()				:IRegister;
		function get xxxx()				:IRegister;
			
		function get y()				:IRegister;
		function get yy()				:IRegister;
		function get yyy()				:IRegister;
		function get yyyy()				:IRegister;
		
		function get z()				:IRegister;
		function get zz()				:IRegister;
		function get zzz()				:IRegister;
		function get zzzz()				:IRegister;
		
		function get w()				:IRegister;
		function get ww()				:IRegister;
		function get www()				:IRegister;
		function get wwww()				:IRegister;
		
		function get xy()				:IRegister;
		function get xz()				:IRegister;
		function get xw()				:IRegister;
		
		function get yx()				:IRegister;
		function get yz()				:IRegister;
		function get yw()				:IRegister;
		
		function get zx()				:IRegister;
		function get zy()				:IRegister;
		function get zw()				:IRegister;
		
		function get wx()				:IRegister;
		function get wy()				:IRegister;
		function get wz()				:IRegister;
		
		function get xxy()				:IRegister;
		function get xxz()				:IRegister;
		function get xxw()				:IRegister;
		
		function get xyx()				:IRegister;
		function get xyy()				:IRegister;
		function get xyz()				:IRegister;
		function get xyw()				:IRegister;
		
		function get xzx()				:IRegister;
		function get xzy()				:IRegister;
		function get xzz()				:IRegister;
		function get xzw()				:IRegister;
		
		function get xwx()				:IRegister;
		function get xwy()				:IRegister;
		function get xwz()				:IRegister;
		function get xww()				:IRegister;
		
		function get yxx()				:IRegister;
		function get yxy()				:IRegister;
		function get yxz()				:IRegister;
		function get yxw()				:IRegister;
		
		function get yyx()				:IRegister;
		function get yyz()				:IRegister;
		function get yyw()				:IRegister;
		
		function get yzx()				:IRegister;
		function get yzy()				:IRegister;
		function get yzz()				:IRegister;
		function get yzw()				:IRegister;
		
		function get ywx()				:IRegister;
		function get ywy()				:IRegister;
		function get ywz()				:IRegister;
		function get yww()				:IRegister;
		
		function get zxx()				:IRegister;
		function get zxy()				:IRegister;
		function get zxz()				:IRegister;
		function get zxw()				:IRegister;
		
		function get zyx()				:IRegister;
		function get zyy()				:IRegister;
		function get zyz()				:IRegister;
		function get zyw()				:IRegister;
		
		function get zzx()				:IRegister;
		function get zzy()				:IRegister;
		function get zzw()				:IRegister;
		
		function get zwx()				:IRegister;
		function get zwy()				:IRegister;
		function get zwz()				:IRegister;
		function get zww()				:IRegister;
		
		function get wxx()				:IRegister;
		function get wxy()				:IRegister;
		function get wxz()				:IRegister;
		function get wxw()				:IRegister;
		
		function get wyx()				:IRegister;
		function get wyy()				:IRegister;
		function get wyz()				:IRegister;
		function get wyw()				:IRegister;
		
		function get wzx()				:IRegister;
		function get wzy()				:IRegister;
		function get wzz()				:IRegister;
		function get wzw()				:IRegister;
		
		function get wwx()				:IRegister;
		function get wwy()				:IRegister;
		function get wwz()				:IRegister;
	
		function get xyzw()				:IRegister;
		
		
		function _( att:String )		:IRegister;
	}
}