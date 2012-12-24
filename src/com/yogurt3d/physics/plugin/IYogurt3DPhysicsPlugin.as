/*
* IYogurt3DPhysicsPlugin.as
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

package com.yogurt3d.physics.plugin
{
	import com.yogurt3d.core.sceneobjects.SceneObject;
	import com.yogurt3d.physics.objects.PhysicsObjectBase;

	public interface IYogurt3DPhysicsPlugin
	{
		/**
		 * 
		 * @param sceneObject
		 * @param object
		 * 
		 */
		function registerObject( sceneObject:SceneObject, object:PhysicsObjectBase ):void;
		/**
		 * 
		 * @param sceneObject
		 * @param object
		 * 
		 */
		function deregisterObject( sceneObject:SceneObject, object:PhysicsObjectBase ):void;
		/**
		 * 
		 * 
		 */
		function step():void;
		
	}
}