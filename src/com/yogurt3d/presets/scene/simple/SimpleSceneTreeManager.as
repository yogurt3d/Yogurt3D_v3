/*
* SimpleSceneTreeManager.as
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

package com.yogurt3d.presets.scene.simple
{
import com.yogurt3d.core.Scene3D;
import com.yogurt3d.core.managers.SceneTreeManager;
import com.yogurt3d.core.render.renderqueue.RenderQueue;
import com.yogurt3d.core.sceneobjects.SceneObjectRenderable;
import com.yogurt3d.core.sceneobjects.camera.Camera3D;
import com.yogurt3d.core.sceneobjects.lights.Light;
import com.yogurt3d.core.sceneobjects.scenetree.IRenderableManager;

import flash.utils.Dictionary;

public class SimpleSceneTreeManager implements IRenderableManager
	{
		private static var s_renderableObjectsByScene		:Dictionary;
		
		public function SimpleSceneTreeManager()
		{
			if( s_renderableObjectsByScene == null )
			{
				s_renderableObjectsByScene = new Dictionary(true);
			}
		}
		
		public function addChild(_child:SceneObjectRenderable, _scene:Scene3D, index:int=-1):void
		{
			var _renderableObjectsByScene :Vector.<SceneObjectRenderable> = s_renderableObjectsByScene[_scene];
			
			if(!_renderableObjectsByScene)
			{
				_renderableObjectsByScene			= new Vector.<SceneObjectRenderable>();
				s_renderableObjectsByScene[_scene]	= _renderableObjectsByScene;
				
			}
			if( index == -1 )
			{
				_renderableObjectsByScene[_renderableObjectsByScene.length] = _child;
			}else{
				_renderableObjectsByScene.splice( index, 0, _child );
			}
		}
		
		public function removeChildFromTree(_child:SceneObjectRenderable, _scene:Scene3D):void
		{
			var _renderableObjectsByScene 	:Vector.<SceneObjectRenderable>	= s_renderableObjectsByScene[_scene];
			var _index						:int								= _renderableObjectsByScene.indexOf(_child);
			
			if(_index != -1)
			{
				_renderableObjectsByScene.splice(_index, 1);
			}
			
			if(_renderableObjectsByScene.length == 0)
			{
				s_renderableObjectsByScene[_scene] = null;
			}
		}
		
		public function getSceneRenderableSet(_scene:Scene3D, _camera:Camera3D, _renderQueue:RenderQueue):void
		{
			if( s_renderableObjectsByScene[_scene] )
			{
				var len:uint = s_renderableObjectsByScene[_scene].length;
				for( var i:int = 0; i < len; i++ )
				{
					_renderQueue.addRenderable(s_renderableObjectsByScene[_scene][i]);
				}
			}
		}
		
		public function getSceneRenderableSetLight(_scene:Scene3D, _light:Light, lightIndex:int, _renderQueue:RenderQueue):void
		{
			var len:uint = s_renderableObjectsByScene[_scene].length;
			
			for( var i:int = 0; i < len; i++ )
			{
				_renderQueue.addRenderable(s_renderableObjectsByScene[_scene][i]);
			}
		}
			
		public function getIlluminatorLightIndexes(_scene:Scene3D, _objectRenderable:SceneObjectRenderable):Vector.<int>
		{
			return SceneTreeManager.s_sceneLightIndexes[_scene];
		}
		
		public function clearIlluminatorLightIndexes(_scene:Scene3D, _objectRenderable:SceneObjectRenderable):void
		{
		}
		
		public function getListOfVisibilityTesterByScene():Dictionary{
			return null;
		}
	}
}