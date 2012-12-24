/*
* SceneTreePlugins.as
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

package com.yogurt3d.core.sceneobjects.scenetree
{
	import com.yogurt3d.core.plugin.Kernel;
	import com.yogurt3d.core.plugin.Plugin;
	import com.yogurt3d.core.plugin.Server;
	import com.yogurt3d.core.sceneobjects.scenetree.octree.OcTreeSceneTreeManagerDriver;
	import com.yogurt3d.core.sceneobjects.scenetree.quad.QuadSceneTreeManagerDriver;
	import com.yogurt3d.core.sceneobjects.scenetree.simple.SimpleSceneTreeManagerDriver;

	[Plugin]
	public class SceneTreePlugins extends Plugin
	{
		public static const SERVERNAME:String = "sceneTreeManagerServer";
		public static const SERVERVERSION:uint = 1;
		
		public override function registerPlugin(_kernel:Kernel):Boolean{
			var server:Server = _kernel.getServer( SERVERNAME );
			if( server )
			{
				var drivers:Array = [SimpleSceneTreeManagerDriver, QuadSceneTreeManagerDriver, OcTreeSceneTreeManagerDriver];
				
				var success:uint = drivers.length;
				
				for( var i:int = 0; i < drivers.length; i++)
				{
					if( server.addDriver( new drivers[i](), SERVERVERSION ) )
					{
						success--;
					}
				}
					
				return (success == 0);
			}
			return false;
		}
	}
}