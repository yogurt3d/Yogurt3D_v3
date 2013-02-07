/*
* ConstantFunctions.as
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
import com.yogurt3d.core.sceneobjects.camera.Camera3D;
import com.yogurt3d.core.sceneobjects.lights.Light;

import flash.geom.Matrix3D;
import flash.geom.Vector3D;

public class ConstantFunctions
	{
		
		public static function LIGHT_COLOR(_light:Light, _camera:Camera3D):Vector.<Number>{
			return _light.color.getColorVector();
		}
		
		public static function LIGHT_POSITION(_light:Light, _camera:Camera3D):Vector.<Number>{
			return _light.positionVector;
		}
		
		public static function LIGHT_ATTENUATION(_light:Light, _camera:Camera3D):Vector.<Number>{
			return _light.color.getColorVector();
		}
		
		public static function LIGHT_DIRECTION(_light:Light, _camera:Camera3D):Vector.<Number>{
			return _light.attenuation;
		}
		
		public static function LIGHT_CONE(_light:Light, _camera:Camera3D):Vector.<Number>{
			return  _light.coneAngles;
		}
		
		public static function LIGHT_PROJECTION(_light:Light, _camera:Camera3D):Matrix3D{
			return _light.frustum.projectionMatrix;
		}
		
		public static function LIGHT_VIEW(_light:Light, _camera:Camera3D):Matrix3D{
			return _light.transformation.matrixGlobal;
		}
		
		public static function CAMERA_POSITION(_light:Light, _camera:Camera3D):Vector.<Number>{
			var pos:Vector3D = _camera.transformation.matrixGlobal.position;
			return Vector.<Number>([ pos.x,pos.y,pos.z,1] );
		}
		
		public static function SKYBOX_MATRIX_TRANSPOSED(_light:Light, _camera:Camera3D):Matrix3D{
		
			var _tempMatrix		:Matrix3D				= new Matrix3D();
			_tempMatrix.copyFrom(_camera.transformation.matrixGlobal);
			_tempMatrix.position = new Vector3D(0,0,0);
			_tempMatrix.invert();
			_tempMatrix.append( _camera.frustum.projectionMatrix );
			
			return _tempMatrix;
		}
	}
}