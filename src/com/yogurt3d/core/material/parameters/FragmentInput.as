/*
* FragmentInput.as
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


	public class FragmentInput extends VertexOutput
	{
		
		public function FragmentInput(gen:AGALGEN)
		{
			super(gen);
		}
		
		public function get vertexPos():IRegister{
			if( m_vertexPosition == null )
			{
				m_vertexPosition = m_gen.createV("vertexPos");
			}
			return m_vertexPosition;
		}
		
		public override function get worldPos():IRegister{
			if( m_worldPosition == null )
			{
				m_worldPosition = m_gen.createV("worldPos");
			}
			return m_worldPosition;
		}
		
		public override function get normal():IRegister{
			if( m_normal == null )
			{
				m_normal = m_gen.createV("normal");
			}
			return m_normal;
		}
		
		public override function get uvMain():IRegister{
			if( m_uvMain == null )
			{
				m_uvMain = m_gen.createV("uvMain");
			}
			return m_uvMain;
		}
		
		public override function get uvSecond():IRegister{
			if( m_uvSecond == null )
			{
				m_uvSecond = m_gen.createV("uvSecond");
			}
			return m_uvSecond;
		}
	}
}