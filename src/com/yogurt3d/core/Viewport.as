/*
* Viewport.as
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


import com.yogurt3d.Yogurt3D;
import com.yogurt3d.core.managers.InputManager;
import com.yogurt3d.core.managers.PickManager;
import com.yogurt3d.core.objects.IEngineObject;
import com.yogurt3d.core.render.BackBufferRenderTarget;
import com.yogurt3d.core.render.base.RenderTargetBase;
import com.yogurt3d.core.sceneobjects.camera.Camera3D;

    import flash.display.DisplayObject;

    import flash.display.Sprite;
import flash.display3D.Context3D;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.geom.Matrix3D;
import flash.geom.Point;
import flash.text.TextField;

import org.osflash.signals.PrioritySignal;

import com.yogurt3d.YOGURT3D_INTERNAL;

public class Viewport extends Sprite implements IEngineObject
	{
		use namespace YOGURT3D_INTERNAL;
		
		public  var autoUpdate							:Boolean = true;
		
		private static var viewports					:Vector.<uint> = Vector.<uint>([0,1,2]);
		
		private var m_device							:Context3D;
			
		private var m_currentRenderTarget				:RenderTargetBase;
		
		private var m_viewportID						:uint;
		
		private var m_width								:uint;
		
		private var m_height							:uint;
		
		private var m_renderingEnabled					:Boolean = true;
		
		private var m_matrix							:Matrix3D;
		
		private var m_onPositionChange					:PrioritySignal;
		
		private var m_onSizeChange						:PrioritySignal;
		
		private var m_onDeviceCreated					:PrioritySignal;
		
		private var m_autoResize						:Boolean = false;
		
		private var m_pickingEnabled					:Boolean = false;
		
		YOGURT3D_INTERNAL var m_pickManager				:PickManager;
	
		YOGURT3D_INTERNAL static  var m_pickDevice		:Context3D;

        public var orientationEnabled                   :Boolean = false;
        private var m_orientation                          :String = "default";

		public function Viewport( _width:uint = 800, _height:uint = 600)
		{
			super();

			m_onPositionChange = new PrioritySignal(Viewport);
			m_onSizeChange = new PrioritySignal(Viewport);
			m_onDeviceCreated = new PrioritySignal(Viewport);
			
			m_currentRenderTarget = new BackBufferRenderTarget();
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage );
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage );
			height = _height;
			width = _width;

            trackObject();
            YOGURT3D_INTERNAL::m_injector = new Injector();
            injector.parentInjector = DependencyManager.injector;
            m_controllerDict = new Dictionary();
		}
		
		public function get device():Context3D
		{
			return m_device;
		}
		
		public function get currentRenderTarget():RenderTargetBase
		{
			return m_currentRenderTarget;
		}
		
		public function set currentRenderTarget(value:RenderTargetBase):void
		{
			m_currentRenderTarget = value;
		}
		
		public function get autoResize():Boolean
		{
			return m_autoResize;
		}
		
		public function set autoResize(value:Boolean):void
		{
			m_autoResize = value;
			if( isDeviceCreated )
			{
				stage.addEventListener( Event.RESIZE, onParentResize );
				onParentResize( null );
			}
		}

        protected function trackObject():void
        {
            IDManager.trackObject(this, Viewport);
        }
		
		private function onParentResize( event:Event ):void{

            if (stage == null || parent == null) {
                return;
            }
            var _parentWidth:Number;
            var _parentHeight:Number;
//            trace( "stage", stage.stageWidth, stage.stageHeight );
//            trace( "stage", stage.width, stage.height );
//            trace( "parent", parent.width, parent.height );
            if( orientationEnabled && (orientation == "default"|| orientation == "upsideDown") ){
                _parentWidth = (stage == parent.parent )? stage.stageWidth : parent.width;
                _parentHeight = (stage == parent.parent )? stage.stageHeight : parent.height;
                //trace("O", _parentWidth,_parentHeight,stage == parent );
            }else{
                _parentWidth = (stage == parent.parent )? stage.stageWidth : parent.width;
                _parentHeight = (stage == parent.parent )? stage.stageHeight : parent.height;
                //trace("D", _parentWidth,_parentHeight,stage == parent );
            }
            if(_parentWidth < 50 )
            {
                width = 50;
            }else{
                width = _parentWidth;
            }
            if(parent.height < 50 )
            {
                height = 50;
            }else{
                height = _parentHeight;
            }


            if( camera )
                camera.frustum.setProjectionPerspective( camera.frustum.fov, width/height, camera.frustum.near, camera.frustum.far );


        }
		
		public function get onSizeChange():PrioritySignal
		{
			return m_onSizeChange;
		}
		
		public function get onPositionChange():PrioritySignal
		{
			return m_onPositionChange;
		}
		
		public function get scene():Scene3D{
			return m_currentRenderTarget.scene;
		}
		
		public function set scene(value:Scene3D):void{
			m_currentRenderTarget.scene = value;
		}
		
		public function get camera():Camera3D{
			return m_currentRenderTarget.camera;
		}
		
		public function set camera(value:Camera3D):void{
			m_currentRenderTarget.camera = value;
			if( value && value.scene != scene )
			{
				scene.addChild( camera );
			}
		}
		
		public override function set x( value:Number ):void{
			super.x = value;
			if( stage )
			{
				var global:Point = this.localToGlobal(new Point());
				stage.stage3Ds[ m_viewportID ].x = global.x;
			}
			calculateMatrix();
			m_onPositionChange.dispatch(this);
		}
		
		public override function set y( value:Number ):void{
			super.y = value;
			if( stage )
			{
				var global:Point = this.localToGlobal(new Point());
				stage.stage3Ds[ m_viewportID ].y = global.y;
			}
			calculateMatrix();
			m_onPositionChange.dispatch(this);
		}
		
		public override function set width( value:Number ):void{
            if( value < 50 ) value = 50;
			m_currentRenderTarget.drawRect.width = value;
			m_width = value;
			calculateMatrix();
			drawBackground();
			m_onSizeChange.dispatch(this);
		}
		
		public override function set height( value:Number ):void{
            if( value < 50 ) value = 50;
			m_currentRenderTarget.drawRect.height = value;
			m_height = value;
			calculateMatrix();
			drawBackground();
			m_onSizeChange.dispatch(this);
		}
		
		public function get matrix():Matrix3D
		{
			return m_matrix;
		}
		
		YOGURT3D_INTERNAL function calculateMatrix():void{
			m_matrix = new Matrix3D(Vector.<Number>([
				m_width / 2, 0, 0, 0,
				0,  -m_height / 2, 0, 0,
				0,  0, 1, 0,
				x + m_width / 2, y + m_height / 2, 0, 1]));
		}
		
		protected function onAddedToStage( _event:Event ):void{
			
			if( viewports.length > 0 )
			{
				// get an empty stage3d index
				m_viewportID = viewports.shift();
			}else{
				throw new Error("Maximum 3 viewports are supported. You must dispose before creating a new one.");
			}
			
			// create context
			stage.stage3Ds[m_viewportID].addEventListener(Event.CONTEXT3D_CREATE, onContextCreated );
			stage.stage3Ds[m_viewportID].addEventListener(ErrorEvent.ERROR, onError );
			stage.stage3Ds[m_viewportID].requestContext3D();
			if( m_pickDevice == null &&stage.stage3Ds.length>1 )
			{
				stage.stage3Ds[3].addEventListener(Event.CONTEXT3D_CREATE, onPickContextCreated );
				//stage.stage3Ds[3].addEventListener(ErrorEvent.ERROR, onError );
				stage.stage3Ds[3].requestContext3D();
			}
			
			InputManager.YOGURT3D_INTERNAL::setStage( stage );
			
			Yogurt3D.YOGURT3D_INTERNAL::registerViewport( this );
			drawBackground();
			
			if( m_autoResize )
			{
				parent.addEventListener( Event.RESIZE, onParentResize );
				onParentResize( null );
			}
		}
		
		protected function onRemovedFromStage( _event:Event ):void{
			Yogurt3D.YOGURT3D_INTERNAL::deregisterViewport( this );
		}
		
		private function onError( _event:Event ):void{
			stage.stage3Ds[m_viewportID].removeEventListener(ErrorEvent.ERROR, arguments.callee );
			
			viewports.push(m_viewportID);
			trace("Context Error");

            m_device = null;

			var text:TextField = new TextField();
			text.text = "Add wmode=\"direct\" to params. Or Decive has become unavailable";
			text.width = 600;
			addChild( text );
		}
		
		private function onPickContextCreated( _event:Event ):void{
			m_pickDevice = stage.stage3Ds[3].context3D;
            m_pickManager = new PickManager(this);
            trace("onPickContextCreated");
		}
		
		private function onContextCreated( _event:Event ):void{
            trace("onContextCreated");
			if( stage )
			{
				m_device = stage.stage3Ds[m_viewportID].context3D;
				m_currentRenderTarget.device = m_device;
                width += 0.1;
				m_onDeviceCreated.dispatch(this);
			}else{
				m_device = null;
				viewports.push(m_viewportID);
			}
		}
		
		YOGURT3D_INTERNAL function drawBackground():void{
			if( m_width > 0 && m_height > 0 )
			{
				graphics.clear();
				graphics.beginFill(0xFF0000,0);
				graphics.drawRect(0,0,m_width,m_height);
				graphics.endFill();
				super.width = m_width;
				super.height = m_height;
				
				Y3DCONFIG::DEBUG{
					trace("[Viewport][drawBackground] ", m_width,m_height);
				}				
			}
		}
		
		public function get isDeviceCreated():Boolean
		{
			return m_device != null;
		}
		
		public function update():void{
			if( !isDeviceCreated || !m_renderingEnabled ) return;

			Y3DCONFIG::RENDER_LOOP_TRACE{
				trace("\t[Viewport][update] start [w:", width, ", h:", height, "]");
			}
			
			var global:Point = this.localToGlobal(new Point());
			
			if( stage.stage3Ds[ m_viewportID ].y != global.y || stage.stage3Ds[ m_viewportID ].x != global.x )
			{
				stage.stage3Ds[ m_viewportID ].x = global.x;
				stage.stage3Ds[ m_viewportID ].y = global.y;
			}
			
			Y3DCONFIG::DEBUG{
				m_device.enableErrorChecking = true;
			}
			scene.preRender( camera );
			
			if( m_pickingEnabled )
			{
				m_pickManager.update( scene, camera );
			}
			
			m_currentRenderTarget.render();
			scene.postRender();

			Y3DCONFIG::RENDER_LOOP_TRACE{
				trace("\t[Viewport][update] end");
			}
		}
		
		public function pause():void{
			m_renderingEnabled = false;
		}
		
		public function play():void{
			m_renderingEnabled = true;
		}
		
		public function get pickingEnabled():Boolean
		{
			return m_pickingEnabled;
		}
		
		public function set pickingEnabled(value:Boolean):void
		{
			
			m_pickingEnabled = value;
			if( value && !m_pickManager )
			{
				m_pickManager = new PickManager( this );
			}
		}
		
		////////////////////////////
		// IIdentifiableObject	  //
		////////////////////////////
		include "../../../../includes/IdentifiableObject.as"
		
		////////////////////////////
		// IControllableObject	  //
		////////////////////////////
		include "../../../../includes/ControllableObject.as"
		
		////////////////////////////
		// IReconstructibleObject //
		////////////////////////////
		public function instance():*{
			throw new Error("Viewports are not be initantialized");
		}
		
		public function clone():IEngineObject{
			throw new Error("Viewports are not clonable");
		}
		
		public function renew():void{
			throw new Error("Not implemented!");
		}
		
		public function dispose():void{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage );
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage );
			
			IDManager.removeObject(this);	
			
			Yogurt3D.deregisterViewport(this);
			
		}
		
		public function disposeDeep():void{
			scene.disposeDeep();
			dispose();
		}
		
		public function disposeGPU():void{
			scene.disposeGPU();
		}

    public function get orientation():String {
        return m_orientation;
    }

    public function set orientation(value:String):void {
        m_orientation = value;
        onParentResize(null);
    }
}
}