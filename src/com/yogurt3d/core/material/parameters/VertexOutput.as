/*
* VertexOutput.as
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

package com.yogurt3d.core.material.parameters
{
	import com.yogurt3d.core.agalgen.AGALGEN;
	import com.yogurt3d.core.agalgen.IRegister;
	
	import flash.utils.Dictionary;
	
	public class VertexOutput
	{
		private var m_customvarying					:Dictionary;
		
		protected var m_gen							:AGALGEN;
		
		protected var m_vertexPosition				:IRegister;
		protected var m_worldPosition				:IRegister;
		protected var m_normal						:IRegister;
		protected var m_uvMain						:IRegister;
		protected var m_uvSecond					:IRegister;
		
		public function VertexOutput(gen:AGALGEN)
		{
			m_gen = gen;
			m_customvarying = new Dictionary();
		}

		public function get uvSecond():IRegister
		{
			return m_uvSecond;
		}

		public function get uvMain():IRegister
		{
			return m_uvMain;
		}

		public function get normal():IRegister
		{
			return m_normal;
		}

		public function get worldPos():IRegister
		{
			return m_worldPosition;
		}

		public function get vertexPosition():IRegister
		{
			return m_vertexPosition;
		}

		public function create(name:String):IRegister{
			if( m_customvarying[name] == null )
			{
				m_customvarying[name] = m_gen.createV(name);
			}
			return m_customvarying[name];
		}
		
		public function getVarying(name:String ):IRegister{
			return create(name);
		}
	}
}