/*
* EViewportAntialiasing.as
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

package com.yogurt3d.core.enums
{
import com.yogurt3d.utils.Enum;

public class EViewportAntialiasing extends Enum
	{
		private var m_value:uint;
		
		{initEnum(EViewportAntialiasing);}		
		
		public static const NO_ALIASING 	 		 :EViewportAntialiasing = new EViewportAntialiasing( 0 );
		
		public static const MINIMAL_ALIASING   		 :EViewportAntialiasing = new EViewportAntialiasing( 2 );
		
		public static const HIGH_ALIASING   		 :EViewportAntialiasing = new EViewportAntialiasing( 4 );
		
		public static const VERY_HIGH_ALIASING   	 :EViewportAntialiasing = new EViewportAntialiasing( 16 );
		
		public function EViewportAntialiasing(value:uint){
			m_value = value;
		}
		
		public function get value():uint
		{
			return m_value;
		}

		public static function GetConstants() :Array
		{ return Enum.GetConstants(EViewportAntialiasing); }
		
		public static function ParseConstant(i_constantName :String, i_caseSensitive :Boolean = false) :EViewportAntialiasing
		{ return EViewportAntialiasing(Enum.ParseConstant(EViewportAntialiasing, i_constantName, i_caseSensitive)); }
		
		
	}
}