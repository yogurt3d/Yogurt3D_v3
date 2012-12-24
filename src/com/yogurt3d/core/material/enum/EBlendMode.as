/*
* EBlendMode.as
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
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	
	public class EBlendMode extends Enum
	{
		{initEnum(EBlendMode);}		
		
		private var m_blendSource			:String;
		private var m_blendDestination		:String;
		
		public static const NORMAL	 	 	:EBlendMode = new EBlendMode(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
		public static const MULTIPLY   		:EBlendMode = new EBlendMode(Context3DBlendFactor.ZERO, Context3DBlendFactor.SOURCE_COLOR);
		public static const ADD   		 	:EBlendMode = new EBlendMode(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE);
		public static const ALPHA        	:EBlendMode = new EBlendMode(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
		
		public function EBlendMode(source:String, destination:String ){
			m_blendSource = source;
			m_blendDestination = destination;
		}
		
		public function setToDevice(device:Context3D):Boolean{
			if( m_blendSource != "" )
			{
				device.setBlendFactors( m_blendSource, m_blendDestination );
				return true;
			}
			return false;
		}
		
		public static function GetConstants() :Array
		{ return Enum.GetConstants(EBlendMode); }
		
		public static function ParseConstant(i_constantName :String, i_caseSensitive :Boolean = false) :EBlendMode
		{ return EBlendMode(Enum.ParseConstant(EBlendMode, i_constantName, i_caseSensitive)); }
		
	}
}