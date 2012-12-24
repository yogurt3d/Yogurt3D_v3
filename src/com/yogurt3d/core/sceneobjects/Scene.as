/*
* Scene.as
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

package com.yogurt3d.core.sceneobjects
{
	[Deprecated(message="Use Scene3D instead.", replacement="com.yogurt3d.core.sceneobjects.Scene3D", since="3.0")]
	public class Scene extends Scene3D
	{
		public function Scene(_sceneTreeManagerDriver:String="SimpleSceneTreeManagerDriver", args:Object=null, _initInternals:Boolean=true)
		{
			super(_sceneTreeManagerDriver, args, _initInternals);
		}
	}
}