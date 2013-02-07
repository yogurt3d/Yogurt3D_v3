/*
* Camera3D.as
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

package com.yogurt3d.core.sceneobjects.camera
{
import com.yogurt3d.YOGURT3D_INTERNAL;
import com.yogurt3d.core.managers.IDManager;
import com.yogurt3d.core.sceneobjects.SceneObject;
import com.yogurt3d.core.sceneobjects.camera.frustum.Frustum;

import flash.geom.Matrix3D;
import flash.geom.Vector3D;

public class Camera3D extends SceneObject
	{
		private var m_frustum :Frustum;
		
		use namespace YOGURT3D_INTERNAL;

        public var viewProjectionMatrix:Matrix3D;
		
		public function Camera3D(_initInternals:Boolean = true)
		{
			super(_initInternals);
            viewProjectionMatrix = new Matrix3D();
		}
		
		public function get frustum():Frustum
		{
			return m_frustum;
		}
		
		public function getRayFromMousePosition(_canvasHeight:Number ,_canvasWidth:Number , _mouseX:Number, _mouseY:Number ):Ray {
			var _ray:Ray = new Ray() ;
			
			var _endPoint:Vector3D = new Vector3D() ;
			_endPoint.x = this.frustum.m_vCornerPoints[0].x - (this.frustum.m_vCornerPoints[0].x - this.frustum.m_vCornerPoints[1].x) * (_canvasWidth-_mouseX) / _canvasWidth ;
			_endPoint.y = this.frustum.m_vCornerPoints[0].y - (this.frustum.m_vCornerPoints[0].y - this.frustum.m_vCornerPoints[3].y) * _mouseY / _canvasHeight ;
			_endPoint.z = this.frustum.m_vCornerPoints[0].z ;
			
			_endPoint = this.transformation.matrixGlobal.transformVector(_endPoint) ;
			
			_ray.startPoint = transformation.globalPosition.clone() ;
			_ray.endPoint = _endPoint ;
			
			return _ray ;
		}
		
		/**
		 * @inheritDoc
		 * 
		 */		
		override protected function initInternals():void
		{
			super.initInternals();
			
			m_frustum = new Frustum();
			
			m_frustum.setProjectionPerspective( 45.0, 4.0/3.0, 1.0, 500.0 );
		}
		
		override protected function trackObject():void
		{
			IDManager.trackObject(this, Camera3D);
		}
	}
}