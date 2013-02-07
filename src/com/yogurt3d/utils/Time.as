/*
* Time.as
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

package com.yogurt3d.utils
{
import com.yogurt3d.YOGURT3D_INTERNAL;

public class Time
	{
		YOGURT3D_INTERNAL static var m_time				:uint = 0;
		YOGURT3D_INTERNAL static var m_timeSeconds		:Number = 0;
		
		YOGURT3D_INTERNAL static var m_deltaTime		:uint = 0;
		YOGURT3D_INTERNAL static var m_deltaTimeSeconds	:Number = 0;
		
		public static var timeScale						:Number = 1;
		
		YOGURT3D_INTERNAL static var m_frameCount		:uint = 0;
		
		
		
		public static function get time():uint
		{
			return YOGURT3D_INTERNAL::m_time;
		}
		
		public static function get timeSeconds():Number
		{
			return YOGURT3D_INTERNAL::m_timeSeconds;
		}
		
		public static function set timeSeconds(value:Number):void
		{
			YOGURT3D_INTERNAL::m_timeSeconds = value;
		}
		
		public static function get deltaTime():uint
		{
			return YOGURT3D_INTERNAL::m_deltaTime;
		}
		
		public static function get deltaTimeSeconds():Number
		{
			return YOGURT3D_INTERNAL::m_deltaTimeSeconds;
		}
		
		public static function get frameCount():uint
		{
			return YOGURT3D_INTERNAL::m_frameCount;
		}
		
		public static function toString():String{
			return "[ frame: " + YOGURT3D_INTERNAL::m_frameCount + ", timeSeconds: " + timeSeconds + ", deltaTime: "+deltaTime+" ]";
		}	
	}
}