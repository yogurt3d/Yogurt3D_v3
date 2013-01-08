/*
* IRenderableManager.as
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
	import com.yogurt3d.core.Scene3D;
	import com.yogurt3d.core.render.renderqueue.RenderQueue;
	import com.yogurt3d.core.sceneobjects.SceneObjectRenderable;
	import com.yogurt3d.core.sceneobjects.camera.Camera3D;
	import com.yogurt3d.core.sceneobjects.lights.Light;
	
	import flash.utils.Dictionary;
	
	public interface IRenderableManager
	{
		function addChild(_child:SceneObjectRenderable, _scene:Scene3D, index:int = -1):void;
		function removeChildFromTree(_child:SceneObjectRenderable, _scene:Scene3D):void;
		function getSceneRenderableSet(_scene:Scene3D, _camera:Camera3D, m_renderQueue:RenderQueue):void;
		function getSceneRenderableSetLight(_scene:Scene3D, _light:Light, lightIndex:int, m_renderQueue:RenderQueue):void;
		function getIlluminatorLightIndexes(_scene:Scene3D, _objectRenderable:SceneObjectRenderable):Vector.<int>;
		function clearIlluminatorLightIndexes(_scene:Scene3D, _objectRenderable:SceneObjectRenderable):void;
		function getListOfVisibilityTesterByScene():Dictionary;
	}
}