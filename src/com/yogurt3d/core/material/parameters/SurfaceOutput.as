/*
* SurfaceOutput.as
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
	
	public class SurfaceOutput
	{
		use namespace YOGURT3D_INTERNAL;
		
		protected var m_gen					:AGALGEN;
		YOGURT3D_INTERNAL var m_albedo		:IRegister;
		YOGURT3D_INTERNAL var m_normal		:IRegister;
		YOGURT3D_INTERNAL var m_alpha		:IRegister;
		
		public function SurfaceOutput(gen:AGALGEN)
		{
			m_gen = gen;
		}
		/**
		 * Register with size of 3 that contains color data of a fragment 
		 * @return 
		 * 
		 */		
		public function get Albedo():IRegister{
			if( m_albedo == null )
			{
				m_albedo = m_gen.createFT("albedo", 4 );
			}
			return m_albedo;
		}
		/**
		 * Register with size of 3 that contains normal data of a fragment 
		 * @return 
		 * 
		 */		
		public function get Normal():IRegister{
			if( m_normal == null )
			{
				m_normal = m_gen.createFT("normal", 3 );
			}
			return m_normal;
		}
		/**
		 * Register with size of 3 that contains normal data of a fragment 
		 * @return 
		 * 
		 */		
		public function get Alpha():IRegister{
			if( m_alpha == null )
			{
				m_alpha = m_gen.createFT("alpha", 1 );
			}
			return m_alpha;
		}
	}
}