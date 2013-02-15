/*
* Scene3D.as
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

package com.yogurt3d.core
{
import com.yogurt3d.YOGURT3D_INTERNAL;
import com.yogurt3d.core.managers.IDManager;
import com.yogurt3d.core.managers.MaterialManager;
import com.yogurt3d.core.managers.SceneTreeManager;
import com.yogurt3d.core.objects.EngineObject;
import com.yogurt3d.core.render.post.PostProcessingEffectBase;
import com.yogurt3d.core.render.renderqueue.RenderQueue;
import com.yogurt3d.core.render.renderqueue.RenderQueueNode;
import com.yogurt3d.core.render.texture.RenderDepthTexture;
import com.yogurt3d.core.render.texture.RenderSceneTexture;
import com.yogurt3d.core.render.texture.base.RenderTextureTargetBase;
import com.yogurt3d.core.sceneobjects.SceneObject;
import com.yogurt3d.core.sceneobjects.SceneObjectRenderable;
import com.yogurt3d.core.sceneobjects.SkyBox;
import com.yogurt3d.core.sceneobjects.camera.Camera3D;
import com.yogurt3d.core.sceneobjects.lights.Light;
import com.yogurt3d.utils.Color;
import com.yogurt3d.utils.PPPriorityList;
import com.yogurt3d.utils.RTTPriorityList;

import flash.geom.Matrix3D;

public class Scene3D extends EngineObject
	{
		public static const SIMPLE_SCENE		:String = "SimpleSceneTreeManagerDriver";
		public static const QUAD_SCENE			:String = "QuadSceneTreeManagerDriver";
		public static const OCTREE_SCENE		:String = "OcTreeSceneTreeManagerDriver";
		
		public var renderTargets				:RTTPriorityList;
		private var m_postProcesses				:PPPriorityList;
		
		private var m_enableDepthRendering		:Boolean;
				
		private var m_skyBox					:SkyBox;
		
		private var m_sceneColor				:Color;
				
		private var m_renderQueue				:RenderQueue;
		
		YOGURT3D_INTERNAL var m_rootObject		:SceneObject;
		
		YOGURT3D_INTERNAL var m_args			:Object;
		
		YOGURT3D_INTERNAL var m_driver			:String;
		
		use namespace YOGURT3D_INTERNAL;
		
		private var m_depthRenderer:RenderDepthTexture;
		private var m_sceneRenderer:RenderSceneTexture;
		// TODO: Render Scene
		public function Scene3D(_sceneTreeManagerDriver:String = "SimpleSceneTreeManagerDriver", args:Object = null, _initInternals:Boolean = true)
		{
			renderTargets = new RTTPriorityList();
			m_postProcesses = new PPPriorityList();
			m_driver = _sceneTreeManagerDriver;
			m_renderQueue = new RenderQueue();
			m_args = args;
			//renderTargets.add(new RenderDepthTexture());
			super(_initInternals);
		}

		public function get sceneRenderer():RenderSceneTexture
		{
			return m_sceneRenderer;
		}

		public function set sceneRenderer(value:RenderSceneTexture):void
		{
			m_sceneRenderer = value;
		}

		public function get depthRenderer():RenderDepthTexture
		{
			return m_depthRenderer;
		}

		public function set depthRenderer(value:RenderDepthTexture):void
		{
			m_depthRenderer = value;
		}
		
		public function get postEffects():PPPriorityList{
			return m_postProcesses;
		}

		public function addPostEffect(_effect:PostProcessingEffectBase):void{
			if(_effect.needsDepth)
				enableDepthRendering = true;
//			else
//				enableDepthRendering = false; // TODO
			
			if(_effect.needOriginalScene){
				if(m_sceneRenderer == null)
					renderTargets.add(m_sceneRenderer = new RenderSceneTexture());
				else{
					if(m_sceneRenderer){
						// remove depth renderer
					}
					//m_sceneRenderer = null;
				}
			}
			
			m_postProcesses.add(_effect);
		}
		
		public function removeAllPostEffects():void{
			m_postProcesses.removeAll();
		}
		
		public function removePostEffect(_effect:PostProcessingEffectBase):void{
			m_postProcesses.remove(_effect);
		}
		
		/**
		 * @inheritDoc
		 * */
		public function get objectSet():Vector.<SceneObject>
		{
			return SceneTreeManager.getSceneObjectSet(this);
		}
		
		/**
		 * @inheritDoc
		 * */
		public function getRenderableSet():RenderQueue
		{
			return m_renderQueue;
		}
		
		public function getIlluminatorLightIndexes(_scene:Scene3D, _objectRenderable:SceneObjectRenderable):Vector.<int>
		{
			return SceneTreeManager.getIlluminatorLightIndexes(this,_objectRenderable);
		}
		
		public function clearIlluminatorLightIndexes(_scene:Scene3D, _objectRenderable:SceneObjectRenderable):void
		{
			return SceneTreeManager.clearIlluminatorLightIndexes(this,_objectRenderable);
		}
		
//		public function getRenderableSetLight(_light:Light, _lightIndex:int):Vector.<SceneObjectRenderable>
//		{
//			return SceneTreeManager.getSceneRenderableSetLight(this, _light, _lightIndex);
//		}
		
		public function preRender(_activeCamera:Camera3D):void
		{
            var m:Matrix3D = _activeCamera.viewProjectionMatrix;
            m.identity();
            m.copyFrom( _activeCamera.transformation.matrixGlobal );
            m.invert();
            m.append( _activeCamera.frustum.projectionMatrix );

			SceneTreeManager.clearSceneFrameData( this, _activeCamera);
			m_renderQueue.clear();
			SceneTreeManager.getSceneRenderableSet(this,_activeCamera, m_renderQueue);
			SceneTreeManager.initIntersectedLightByCamera(this, _activeCamera);
		}
		
		public function postRender():void
		{
			MaterialManager.instance.YOGURT3D_INTERNAL::m_lastProgram = null;
		}
		
		/**
		 * @inheritDoc
		 * */
		public function get cameraSet():Vector.<Camera3D>
		{
			return SceneTreeManager.getSceneCameraSet(this);
		}
		
		public function get lightSet():Vector.<Light>
		{
			return SceneTreeManager.getSceneLightSet(this);
		}
		
		public function getIntersectedLightsByCamera(_camera:Camera3D):Vector.<Light>
		{
			return SceneTreeManager.s_intersectedLightsByCamera[_camera];
		}
		
		/**
		 * @inheritDoc
		 * */
		public function get children():Vector.<SceneObject>
		{
			return SceneTreeManager.getChildren(m_rootObject);
		}
		
		public function get triangleCount():int
		{
			var polyLen:uint = 0;
		
			if( m_renderQueue.getRenderableCount() > 0 )
			{
				var head:RenderQueueNode;
				head = m_renderQueue.getHead();
				
				while( head )
				{
					var obj:SceneObjectRenderable = head.scn;
					polyLen += obj.geometry.triangleCount;
					head = head.next;
				}
			}
			return polyLen;
		}
		
		/**
		 * @inheritDoc
		 * */
		public function addChild(_value:SceneObject):void {
			if (_value == null) {
				// if value is null exit function
				return;
			}
			//SceneTreeManager.addChild(_value, m_rootObject);
            m_rootObject.addChild( _value);
        }
		
		/**
		 * @inheritDoc
		 * */
		public function removeChild(_value:SceneObject):SceneObject
		{
			SceneTreeManager.removeChild(_value, m_rootObject);
			return _value;
		}
		
		/**
		 * @inheritDoc
		 * */
		public function removeChildBySystemID(_value:String):void
		{
			SceneTreeManager.removeChildBySystemID(_value, m_rootObject);
		}
		
		/**
		 * @inheritDoc
		 * */
		public function removeChildByUserID(_value:String):void
		{
			SceneTreeManager.removeChildByUserID(_value, m_rootObject);
		}
		
		/**
		 * @inheritDoc
		 * */
		public function getChildBySystemID(_value:String):SceneObject
		{
			return SceneTreeManager.getChildBySystemID(_value, m_rootObject);
		}
		
		/**
		 * @inheritDoc
		 * */
		public function getChildByUserID(_value:String):SceneObject
		{
			return SceneTreeManager.getChildByUserID(_value, m_rootObject);
		}
		
		/**
		 * @inheritDoc
		 * */
		public function containsChild(_child:SceneObject, _recursive:Boolean = false):Boolean
		{
			return SceneTreeManager.contains(_child, m_rootObject, _recursive); 
		}
		
		override protected function trackObject():void
		{
			IDManager.trackObject(this, Scene3D);
		}
		
		override public function dispose():void{
			if( m_rootObject )
			{
				m_rootObject.dispose();
			}
			m_rootObject = null;
			
			m_sceneColor = null;
			/*
			m_postEffects = null;*/
			if( skyBox )
			{
				skyBox.dispose();
				skyBox = null;
			}

            if(m_renderQueue)
                m_renderQueue.clear();

			super.dispose();
		}
		
		override public function disposeGPU():void{
			m_rootObject.disposeGPU();
			if( skyBox )
			{
				skyBox.disposeGPU();
			}
		}
		
		override public function disposeDeep():void{
			if( skyBox )
			{
				skyBox.dispose();
				skyBox = null;
			}
			
			m_rootObject.disposeDeep();
			
			m_rootObject = null;
			
			m_sceneColor = null;
			
			/*if( m_postEffects )
			{
			for( var i:int = 0; i < m_postEffects.length; i++ )
			{
			m_postEffects[i].dispose();
			}
			}
			m_postEffects = null;*/
			
			dispose();
		}
		
		override protected function initInternals():void
		{
			super.initInternals();
			
			m_rootObject 		= new SceneObject();
			
			m_sceneColor = new Color(1,1,1,1);
			
			SceneTreeManager.setSceneRootObject( m_rootObject, this);
		}
		
		public function get sceneColor():Color
		{
			return m_sceneColor;
		}
		
		public function set sceneColor(value:Color):void
		{
			m_sceneColor = value;
		}
		
		public function get skyBox():SkyBox
		{
			return m_skyBox;
		}
		public function set skyBox(_value:SkyBox):void
		{
			m_skyBox = _value;
		}
			
		public function get enableDepthRendering():Boolean
		{
			return m_enableDepthRendering;
		}
		
		public function set enableDepthRendering(value:Boolean):void
		{
			m_enableDepthRendering = value;
			if(value){
				if(m_depthRenderer == null)
					renderTargets.add(m_depthRenderer = new RenderDepthTexture());
			}else{
				if(m_depthRenderer){
					// remove depth renderer
				}
				m_depthRenderer = null;
			
			}
		}
		
		YOGURT3D_INTERNAL function addRenderTarget( value:RenderTextureTargetBase ):void{
			renderTargets.add( value );
		}
		YOGURT3D_INTERNAL function removeRenderTarget( value:RenderTextureTargetBase ):void{
			renderTargets.remove( value );
		}
	}
}