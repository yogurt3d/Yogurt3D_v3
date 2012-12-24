/*
* ERegisterType.as
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
	import com.yogurt3d.core.utils.Enum;

	public class ERegisterType extends Enum
	{
		{initEnum(ERegisterType);}		
		
		private var m_value:String;
		
		public static const VERTEX_TEMP 	 	:ERegisterType = new ERegisterType("vt");
		public static const FRAGMENT_TEMP    	:ERegisterType = new ERegisterType("ft");
		
		public static const VERTEX_OUTPUT    	:ERegisterType = new ERegisterType("op");
		public static const FRAGMENT_OUTPUT    	:ERegisterType = new ERegisterType("oc");
		
		public static const VARYING    			:ERegisterType = new ERegisterType("v");
		
		public static const VERTEX_ATTRIBUTE	:ERegisterType = new ERegisterType("va");
		
		public static const VERTEX_CONST		:ERegisterType = new ERegisterType("vc");
		public static const FRAGMENT_CONST		:ERegisterType = new ERegisterType("fc");
		
		public static const TEXTURE				:ERegisterType = new ERegisterType("fs");
		
		public function ERegisterType( _val:String):void{
			m_value = _val;
		}
		
		public function get value():String
		{
			return m_value;
		}

		public static function GetConstants() :Array
		{ 
			return Enum.GetConstants(ERegisterType); 
		}
		
		public static function ParseConstant(i_constantName :String, i_caseSensitive :Boolean = false) :ERegisterType
		{ 
			return ERegisterType(Enum.ParseConstant(ERegisterType, i_constantName, i_caseSensitive)); 
		}
	}
}