/*
* Y3DProgram.as
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
import flash.display3D.Context3D;
import flash.display3D.Program3D;
import flash.utils.ByteArray;
import flash.utils.Dictionary;

public class Y3DProgram
	{
		public var vertex		:ByteArray;
		public var fragment		:ByteArray;
		
		private var m_program		:Dictionary;
		
		public function Y3DProgram(){
            m_program = new Dictionary(true);
        }
        public function getDeviceProgram(device:Context3D):Program3D{
            if( m_program[device] == null)
            {
                m_program[device] = device.createProgram();
                m_program[device].upload(vertex,fragment);
            }

            return  m_program[device];
        }
	}
}