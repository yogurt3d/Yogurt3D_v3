/*
* ERegisterShaderType.as
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

package com.yogurt3d.core.material.enum
{
	import com.yogurt3d.utils.Enum;
	
	import flash.display3D.Context3DProgramType;

	public class ERegisterShaderType extends Enum
	{
		{initEnum(ERegisterShaderType);}		
		
		private var m_value:String;
		
		public static const VERTEX 	 	:ERegisterShaderType = new ERegisterShaderType(Context3DProgramType.VERTEX);
		public static const FRAGMENT    :ERegisterShaderType = new ERegisterShaderType(Context3DProgramType.FRAGMENT);
		public static const BOTH   		:ERegisterShaderType = new ERegisterShaderType("");
		
		public function ERegisterShaderType( value:String ):void{
			m_value = value;
		}
		
		public function get value():String
		{
			return m_value;
		}

		public static function GetConstants() :Array
		{ 
			return Enum.GetConstants(ERegisterShaderType); 
		}
		
		public static function ParseConstant(i_constantName :String, i_caseSensitive :Boolean = false) :ERegisterShaderType
		{ 
			return ERegisterShaderType(Enum.ParseConstant(ERegisterShaderType, i_constantName, i_caseSensitive)); 
		}
		
	}
}