/*
* VertexInput.as
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
	import com.yogurt3d.core.material.agalgen.AGALGEN;
	import com.yogurt3d.core.material.agalgen.IRegister;
	import com.yogurt3d.YOGURT3D_INTERNAL;
	
	public class VertexInput
	{
		use namespace YOGURT3D_INTERNAL;
		
		protected var m_gen					:AGALGEN;
		
		YOGURT3D_INTERNAL var m_vertexpos	:IRegister;
		YOGURT3D_INTERNAL var m_worldpos	:IRegister;
		YOGURT3D_INTERNAL var m_normal		:IRegister;
		YOGURT3D_INTERNAL var m_tangent		:IRegister;
		YOGURT3D_INTERNAL var m_uvMain		:IRegister;
		YOGURT3D_INTERNAL var m_uvSecond	:IRegister;
		YOGURT3D_INTERNAL var m_boneData	:IRegister;
		
		public function VertexInput( gen:AGALGEN ):void{
			m_gen = gen;
		}
		
		public function get vertexpos():IRegister{
			if( m_vertexpos == null )
			{
				m_vertexpos = m_gen.createVA("vertexPos");
			}
			return m_vertexpos;
		}
		
		public function get boneData():IRegister{
			if( m_boneData == null )
			{
				m_boneData = m_gen.createVA("boneData");
				m_gen.createVA("boneData1");
				m_gen.createVA("boneData2");
				m_gen.createVA("boneData3");
			}
			return m_boneData;
		}
		
		public function get worldpos():IRegister{
			if( m_worldpos == null )
			{
				m_worldpos = m_gen.createVT("worldPos",3);
			}
			return m_worldpos;
		}
		
		public function get normal():IRegister{
			if( m_normal == null )
			{
				m_normal = m_gen.createVA("normal");
			}
			return m_normal;
		}
		
		public function get tangent():IRegister{
			if( m_tangent == null )
			{
				m_tangent = m_gen.createVA("tangent");
			}
			return m_tangent;
		}
		
		public function get uvMain():IRegister{
			if( m_uvMain == null )
			{
				m_uvMain = m_gen.createVA("uvMain");
			}
			return m_uvMain;
		}
		
		public function get uvSecond():IRegister{
			if( m_uvSecond == null )
			{
				m_uvSecond = m_gen.createVA("uvSecond");
			}
			return m_uvSecond;
		}
	}
}