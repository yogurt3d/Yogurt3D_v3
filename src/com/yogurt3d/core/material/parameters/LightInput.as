/*
* LightInput.as
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
import com.yogurt3d.YOGURT3D_INTERNAL;
import com.yogurt3d.core.material.agalgen.AGALGEN;
import com.yogurt3d.core.material.agalgen.IRegister;

public class LightInput extends SurfaceOutput
	{
		use namespace YOGURT3D_INTERNAL;
		
		YOGURT3D_INTERNAL var m_lightDir		:IRegister;
		YOGURT3D_INTERNAL var m_viewDir			:IRegister;
		YOGURT3D_INTERNAL var m_atteniation		:IRegister;
		YOGURT3D_INTERNAL var m_lightColor		:IRegister;
		
		public function LightInput(gen:AGALGEN)
		{
			super(gen);
		}
		
		public function get lightColor():IRegister{
			if( m_lightColor == null )
			{
				m_lightColor = m_gen.createFC("lightColor", 1);
			}
			return m_lightColor;
		}
		
		public function get lightDirection():IRegister{
			if( m_lightDir == null )
			{
				m_lightDir = m_gen.createFT("lightDir",3);
			}
			return m_lightDir;
		}
		
		public function get viewDirection():IRegister{
			if( m_viewDir == null )
			{
				m_viewDir = m_gen.createFT("viewDir",3);
			}
			return m_viewDir;
		}
		
		public function get atteniation():IRegister{
			if( m_atteniation == null )
			{
				m_atteniation = m_gen.createFT("atteniation",1);
			}
			return m_atteniation;
		}
	}
}