/*
* ProgramManager.as
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
import com.yogurt3d.core.render.post.EffectBase;

import flash.display3D.Context3D;
import flash.display3D.Program3D;
import flash.utils.Dictionary;

public class ProgramManager
	{
		public static var registeredPrograms		:Dictionary 	= new Dictionary();
		
		public static var programDict				:Dictionary 	= new Dictionary();
		
		public static function getEffectProgram(_effect:EffectBase, _context3D:Context3D):Program3D{
			var _key:String = _effect.key;
			
			if( registeredPrograms[_key] == null )
			{
				//trace("[Y3D_WARNING] MaterialManager@geteffectProgram: Registering "+_key);	
				//	_pass.setSurfaceFuncConst(m_surfaceParams ,m_surfaceAttrib);
				registeredPrograms[_key] = {vert:_effect.getVertexProgram(), frag:_effect.getFragmentProgram()};
				
			}
			if( programDict[_key ] == null || programDict[_key][_context3D] == null )
			{
				if(registeredPrograms[_key] == null) return null;
				
				var program:Program3D = _context3D.createProgram();
				program.upload( registeredPrograms[ _key ].vert, registeredPrograms[ _key ].frag);
				
				if( programDict[_key ] == null )
				{
					programDict[_key ] = new Dictionary();
				}
				
				programDict[_key ][_context3D] = program;
			}
			
			return programDict[_key ][_context3D];
		}
	}
}