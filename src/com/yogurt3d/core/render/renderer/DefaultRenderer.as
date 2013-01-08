/*
* DefaultRenderer.as
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

package com.yogurt3d.core.render.renderer
{
	import com.yogurt3d.core.Scene3D;
	import com.yogurt3d.core.material.MaterialBase;
	import com.yogurt3d.core.render.renderqueue.RenderQueue;
	import com.yogurt3d.core.render.renderqueue.RenderQueueNode;
	import com.yogurt3d.core.sceneobjects.SceneObjectRenderable;
	import com.yogurt3d.core.sceneobjects.camera.Camera3D;
	
	import flash.display3D.Context3D;
	import flash.geom.Rectangle;
	
	public class DefaultRenderer implements IRenderer
	{
		
		public function DefaultRenderer(){}
		
		public function render( device:Context3D, scene:Scene3D=null, camera:Camera3D=null, rect:Rectangle=null , excludeList:Array = null ):void{
			
			scene.preRender(camera);
			
			if(scene.skyBox){scene.skyBox.material.render(scene.skyBox, null , device, camera );}
			
			var _renderableSet:RenderQueue = scene.getRenderableSet();
			if( _renderableSet.getRenderableCount()>0 )
			{
				var head:RenderQueueNode;
				head = _renderableSet.getHead();
				while( head )
				{
					if( excludeList )
					{
						for( var i:int = 0; i < excludeList.length;i++)
						{
							if( excludeList[i] == head.scn )
							{
								head = head.next;
								continue;
							}
						}
					}
					var obj:SceneObjectRenderable = head.scn;			
					var _material:MaterialBase = obj.material;
		
					if (!_material) { trace("[Y3D DefaultRenderer]@render: Renderable object with no material");	continue;}	
					
					_material.render(obj, scene.getIntersectedLightsByCamera(camera), device, camera );
					head = head.next;
				}
			}
			scene.postRender();
			
		}
	}
}