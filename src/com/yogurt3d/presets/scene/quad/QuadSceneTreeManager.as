/*
* QuadSceneTreeManager.as
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

package com.yogurt3d.presets.scene.quad
{
	import com.yogurt3d.core.sceneobjects.camera.Camera3D;
	import com.yogurt3d.core.sceneobjects.lights.ELightType;
	import com.yogurt3d.core.sceneobjects.lights.Light;
	import com.yogurt3d.core.managers.SceneTreeManager;
	import com.yogurt3d.core.render.renderqueue.RenderQueue;
	import com.yogurt3d.core.Scene3D;
	import com.yogurt3d.core.sceneobjects.SceneObject;
	import com.yogurt3d.core.sceneobjects.SceneObjectRenderable;
	import com.yogurt3d.core.sceneobjects.scenetree.IRenderableManager;
	import com.yogurt3d.core.sceneobjects.transformations.Transformation;
	import com.yogurt3d.core.volumes.AxisAlignedBoundingBox;
	
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	import com.yogurt3d.YOGURT3D_INTERNAL;
	
	use namespace YOGURT3D_INTERNAL;
	
	public class QuadSceneTreeManager implements IRenderableManager
	{
		YOGURT3D_INTERNAL static var s_quadTreeByScene			:Dictionary;
		
		private static var s_staticChildrenByScene				:Dictionary;
		
		private static var s_dynamicChildrenByScene				:Dictionary;
		
		//the list for storing recursive "visibilityProcess" results for the testers like camera or light
		private static var listOfVisibilityTesterByScene		:Dictionary;
		
		private static var s_transformedDynamicChildren			:Vector.<SceneObjectRenderable> = new Vector.<SceneObjectRenderable>();
		
		private static var s_marktransformedDynamicChildren		:Dictionary = new Dictionary();
		
		public function QuadSceneTreeManager()
		{
			if( s_quadTreeByScene == null )
			{
				s_quadTreeByScene = new Dictionary(false);
				s_staticChildrenByScene = new Dictionary(true);
				s_dynamicChildrenByScene = new Dictionary(true);
				listOfVisibilityTesterByScene = new Dictionary();
			}
		}
		
		public function addChild(_child:SceneObjectRenderable, _scene:Scene3D, index:int=-1):void
		{
			//SceneTreeManager.initRenSetIlluminatorLightIndexes(_scene, _child);
			
			if( s_quadTreeByScene[_scene] == null )
			{
				if( Scene3D(_scene).YOGURT3D_INTERNAL::m_args != null && 
					"x" in Scene3D(_scene).YOGURT3D_INTERNAL::m_args && 
					"y" in Scene3D(_scene).YOGURT3D_INTERNAL::m_args && 
					"z" in Scene3D(_scene).YOGURT3D_INTERNAL::m_args && 
					"width" in Scene3D(_scene).YOGURT3D_INTERNAL::m_args && 
					"height" in Scene3D(_scene).YOGURT3D_INTERNAL::m_args &&
					"depth" in Scene3D(_scene).YOGURT3D_INTERNAL::m_args 
				)
				{
					s_quadTreeByScene[_scene] = new QuadTree( 
						new AxisAlignedBoundingBox( 
							new Vector3D(
								Scene3D(_scene).YOGURT3D_INTERNAL::m_args.x,
								Scene3D(_scene).YOGURT3D_INTERNAL::m_args.y,
								Scene3D(_scene).YOGURT3D_INTERNAL::m_args.z),
							new Vector3D(
								Scene3D(_scene).YOGURT3D_INTERNAL::m_args.width ,
								Scene3D(_scene).YOGURT3D_INTERNAL::m_args.height,
								Scene3D(_scene).YOGURT3D_INTERNAL::m_args.depth
							)
						)
					);
					Y3DCONFIG::TRACE
					{
						trace("OCTREE ",
							"x", Scene3D(_scene).YOGURT3D_INTERNAL::m_args.x,
							"y", Scene3D(_scene).YOGURT3D_INTERNAL::m_args.y,
							"z", Scene3D(_scene).YOGURT3D_INTERNAL::m_args.z,
							"width", Scene3D(_scene).YOGURT3D_INTERNAL::m_args.width ,
							"height", Scene3D(_scene).YOGURT3D_INTERNAL::m_args.height,
							"depth", Scene3D(_scene).YOGURT3D_INTERNAL::m_args.depth);
					}
				}
				else{
					s_quadTreeByScene[_scene] = new QuadTree( 
						new AxisAlignedBoundingBox(
							new Vector3D(-10000,-10000,-10000),
							new Vector3D(20000,20000,20000)
						)
					);
				}
				
			}
			
			if( listOfVisibilityTesterByScene[_scene] == null )
			{
				listOfVisibilityTesterByScene[_scene] = new Dictionary();
			}
			
			
			if( s_staticChildrenByScene[_scene] == null )
			{
				s_staticChildrenByScene[_scene] = new Vector.<SceneObjectRenderable>();
			}
			
			if( s_dynamicChildrenByScene[_scene] == null )
			{
				s_dynamicChildrenByScene[_scene] = new Vector.<SceneObjectRenderable>();
			}
				
			if( _child.isStatic )
			{
				//if( s_staticChildrenByScene[_scene] == null )
				//{
				//s_staticChildrenByScene[_scene] = new Vector.<SceneObjectRenderable>();
				//}
				s_staticChildrenByScene[_scene].push(_child);
			}
			else
			{
				/*				if( s_dynamicChildrenByScene[_scene] == null )
				{
				s_dynamicChildrenByScene[_scene] = new Vector.<SceneObjectRenderable>();
				}*/
				s_dynamicChildrenByScene[_scene].push( _child );
				
				_child.transformation.onChange.add( onChildTransChanged );
			}
			
			s_quadTreeByScene[_scene].insert(_child);
			
			_child.onStaticChanged.add(onStaticChange );
			
		}
		
		private function onChildTransChanged(tras:Transformation):void{
			if( tras.m_isAddedToSceneRefreshList == false)
			{
				s_transformedDynamicChildren[s_transformedDynamicChildren.length] = SceneObjectRenderable(tras.m_ownerSceneObject);
				tras.m_isAddedToSceneRefreshList = true;
			}
		}
		
		public function getListOfVisibilityTesterByScene():Dictionary{
			return listOfVisibilityTesterByScene;
		}
		
		private function onStaticChange( _scn:SceneObject ):void{
			var _child:SceneObjectRenderable = _scn as SceneObjectRenderable;
			
			if( _child.isStatic )
			{
				_removeChildFromDynamicList( _child, _child.scene );
				
				_child.transformation.onChange.remove( onChildTransChanged );
				
				s_staticChildrenByScene[_child.scene].push( _child );
				
				
			}else
			{
				_removeChildFromStaticList( _child, _child.scene );
				
				_child.transformation.onChange.add( onChildTransChanged );
				
				s_dynamicChildrenByScene[_child.scene].push( _child );
			}
		}
		
		private function _removeChildFromDynamicList( _child:SceneObjectRenderable, _scene:Scene3D ):void{
			if( s_dynamicChildrenByScene[_scene ] )
			{
				var _renderableObjectsByScene 	:Vector.<SceneObjectRenderable>	= s_dynamicChildrenByScene[_scene];
				var _index						:int								= _renderableObjectsByScene.indexOf(_child);
				
				if(_index != -1)
				{
					_renderableObjectsByScene.splice(_index, 1);
				}
				
				if(_renderableObjectsByScene.length == 0)
				{
					s_dynamicChildrenByScene[_scene] = null;
				}
			}
			
		}
		
		private function _removeChildFromStaticList( _child:SceneObjectRenderable, _scene:Scene3D ):void{
			if( s_dynamicChildrenByScene[_scene ] )
			{
				var _renderableObjectsByScene 	:Vector.<SceneObjectRenderable>	= s_staticChildrenByScene[_scene];
				var _index						:int								= _renderableObjectsByScene.indexOf(_child);
				
				if(_index != -1)
				{
					_renderableObjectsByScene.splice(_index, 1);
				}
				
				if(_renderableObjectsByScene.length == 0)
				{
					s_staticChildrenByScene[_scene] = null;
				}
			}
			
		}
		
		public function getSceneRenderableSet(_scene:Scene3D, _camera:Camera3D, _renderQueue:RenderQueue):void
		{
			var camera:Camera3D =  _camera;
			
			if( s_quadTreeByScene[_scene] )
			{
				s_quadTreeByScene[_scene].updateTree(s_transformedDynamicChildren );
				
				camera.frustum.extractPlanes(camera.transformation);
				
				camera.frustum.boundingSphere.YOGURT3D_INTERNAL::m_center = camera.transformation.matrixGlobal.transformVector(camera.frustum.m_bSCenterOrginal);
				
				s_quadTreeByScene[_scene].list = listOfVisibilityTesterByScene[_scene][_camera];
				
				s_quadTreeByScene[_scene].visibilityProcess( _camera, _renderQueue );
			}
		}
		
		public function getSceneRenderableSetLight(_scene:Scene3D, _light:Light, lightIndex:int, _renderQueue:RenderQueue):void
		{
			if(_light.type == ELightType.DIRECTIONAL)
			{
				if(s_staticChildrenByScene[_scene] == null)
					return;
				for(var i:int = 0; i < s_dynamicChildrenByScene[_scene].length; i++ )
				{
					_renderQueue.addRenderable(s_dynamicChildrenByScene[_scene][i]);
				}
				for(i = 0; i < s_staticChildrenByScene[_scene].length; i++ )
				{
					_renderQueue.addRenderable(s_staticChildrenByScene[_scene][i]);
				}
			}
			
			if( s_quadTreeByScene[_scene] )
			{
				
				if(_light.type != ELightType.POINT)
					_light.frustum.extractPlanes(_light.transformation);
				
				_light.frustum.boundingSphere.YOGURT3D_INTERNAL::m_center = _light.transformation.matrixGlobal.transformVector(_light.frustum.m_bSCenterOrginal);
				
				s_quadTreeByScene[_scene].visibilityProcessLight( _light, lightIndex, _scene, _renderQueue);
			}
			
			return;
		}
		
		public function removeChildFromTree(_child:SceneObjectRenderable, _scene:Scene3D):void
		{
			var _renderableObjectsByScene 	:Vector.<SceneObjectRenderable>;
			var _index						:int;
			var _dictionary                 :Dictionary;
			
			
			if(_child.isStatic)
			{
				_renderableObjectsByScene	= s_staticChildrenByScene[_scene];
				_index	= _renderableObjectsByScene.indexOf(_child);
				_dictionary = s_staticChildrenByScene;
			}
			else
			{
				_renderableObjectsByScene	= s_dynamicChildrenByScene[_scene];
				_index	= _renderableObjectsByScene.indexOf(_child);
				_dictionary = s_dynamicChildrenByScene;
				s_transformedDynamicChildren.splice(s_transformedDynamicChildren.indexOf(_child), 1);
			}
			
			if(_index != -1)
			{
				_renderableObjectsByScene.splice(_index, 1);
				SceneTreeManager.s_renSetIlluminatorLightIndexes[_scene][_child] = null;
			}
			
			if(_renderableObjectsByScene.length == 0)
			{
				_dictionary[_scene] = null;
			}
			
			s_quadTreeByScene[_scene].removeFromNode(_child);
			delete s_quadTreeByScene[_scene].sceneObjectToQuadrant[ _child ];
			
		}
		
		public function getIlluminatorLightIndexes(_scene:Scene3D, _objectRenderable:SceneObjectRenderable):Vector.<int>
		{
			return SceneTreeManager.s_renSetIlluminatorLightIndexes[_scene][_objectRenderable].concat(SceneTreeManager.s_sceneDirectionalLightIndexes[_scene]);
		}
		
		public function clearIlluminatorLightIndexes(_scene:Scene3D, _objectRenderable:SceneObjectRenderable):void
		{
			SceneTreeManager.s_renSetIlluminatorLightIndexes[_scene][_objectRenderable].length = 0;
		}	
	}
}