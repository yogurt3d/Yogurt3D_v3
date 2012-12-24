/*
* MaterialManager.as
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

package com.yogurt3d.core.managers
{
	import com.yogurt3d.core.material.MaterialBase;
	import com.yogurt3d.core.material.Y3DProgram;
	import com.yogurt3d.core.material.pass.Pass;
	
	import flash.utils.Dictionary;
	import com.yogurt3d.YOGURT3D_INTERNAL;

	public class MaterialManager
	{
		private static var m_instance			:MaterialManager;
		private var m_programDict				:Dictionary;
		YOGURT3D_INTERNAL var m_lastProgram		:Y3DProgram;
		
		public static function get instance():MaterialManager{
			if( m_instance == null )
			{
				m_instance = new MaterialManager();
			}
			return m_instance;
		}
		
		public function MaterialManager()
		{
			m_programDict = new Dictionary();
		}
		
		public function cacheProgram(material:MaterialBase, pass:Pass, meshType:String, program:Y3DProgram):void{
			var matClass:Class = Object(material).constructor;
			var passClass:Class = Object(pass).constructor;
			if( m_programDict[matClass] == null )
			{
				m_programDict[matClass] = new Dictionary();
			}
			if( m_programDict[matClass][passClass] == null )
			{
				m_programDict[matClass][passClass] = new Dictionary();
			}
			m_programDict[matClass][passClass][meshType] = program;
		}
		
		public function hasProgram(material:MaterialBase, pass:Pass, meshType:String):Boolean{
			var matClass:Class = Object(material).constructor;
			var passClass:Class = Object(pass).constructor;
			return m_programDict[matClass]!= null && m_programDict[matClass][passClass] != null && m_programDict[matClass][passClass][meshType] != null;
			
		}
		
		public function getProgram(material:MaterialBase, pass:Pass, meshType:String):Y3DProgram{
			var matClass:Class = Object(material).constructor;
			var passClass:Class = Object(pass).constructor;
			
			return m_programDict[matClass][passClass][meshType];
		}
	}
}