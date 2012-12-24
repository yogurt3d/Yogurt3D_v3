/*
* EShadowType.as
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

package com.yogurt3d.core.lights
{
	import com.yogurt3d.core.utils.Enum;
	
	public class EShadowType extends Enum
	{
		{initEnum(EShadowType);}	
		
		public static const NONE				:EShadowType = new EShadowType();
		
		public static const HARD				:EShadowType = new EShadowType();
		
		public static const SOFT				:EShadowType = new EShadowType();
		
		public static function GetConstants() :Array
		{ return Enum.GetConstants(EShadowType); }
		
		public static function ParseConstant(i_constantName :String, i_caseSensitive :Boolean = false) :EShadowType
		{ return EShadowType(Enum.ParseConstant(EShadowType, i_constantName, i_caseSensitive)); }
	}
}