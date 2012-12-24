/*
* ColliderComponent.as
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

package com.yogurt3d.physics
{
	import com.yogurt3d.Yogurt3D;
	import com.yogurt3d.core.objects.Controller;
	import com.yogurt3d.core.sceneobjects.SceneObject;
	import com.yogurt3d.physics.objects.PhysicsObjectBase;
	import com.yogurt3d.physics.plugin.IYogurt3DPhysicsPlugin;
	
	public class ColliderComponent extends Controller
	{
		[Inject]
		public var sceneObject:SceneObject;
		
		private var m_object:PhysicsObjectBase;
		
		public function ColliderComponent( object:PhysicsObjectBase )
		{
			super();
			m_object = object;
		}
		public override function initialize():void{
			var physics:IYogurt3DPhysicsPlugin = Yogurt3D.physics;
			if( physics == null ){
				Y3DCONFIG::DEBUG{
					trace("No Physics Plugin Found");
				}
				return;
			}
			physics.registerObject(sceneObject,m_object);
		}
		public override function dispose():void{
			var physics:IYogurt3DPhysicsPlugin = Yogurt3D.physics;
			if( physics == null ){
				Y3DCONFIG::DEBUG{
					trace("No Physics Plugin Found");
				}
				return;
			}
			physics.deregisterObject(sceneObject,m_object);
		}
	}
}