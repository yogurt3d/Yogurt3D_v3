/*
 * PickRenderer.as
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
import com.yogurt3d.YOGURT3D_INTERNAL;
import com.yogurt3d.core.Scene3D;
import com.yogurt3d.core.Viewport;
import com.yogurt3d.core.geoms.IMesh;
import com.yogurt3d.core.geoms.SkeletalAnimatedMesh;
import com.yogurt3d.core.geoms.SkinnedSubMesh;
import com.yogurt3d.core.geoms.SubMesh;
import com.yogurt3d.core.managers.DeviceStreamManager;
import com.yogurt3d.core.managers.MaterialManager;
import com.yogurt3d.core.material.Y3DProgram;
import com.yogurt3d.core.material.enum.EBlendMode;
import com.yogurt3d.core.objects.EngineObject;
import com.yogurt3d.core.render.renderqueue.RenderQueue;
import com.yogurt3d.core.render.renderqueue.RenderQueueNode;
import com.yogurt3d.core.sceneobjects.SceneObjectRenderable;
import com.yogurt3d.core.sceneobjects.camera.Camera3D;
    import com.yogurt3d.core.sceneobjects.camera.Ray;
    import com.yogurt3d.core.volumes.AxisAlignedBoundingBox;
import com.yogurt3d.utils.MatrixUtils;

import flash.display.BitmapData;
import flash.display3D.Context3D;
import flash.display3D.Context3DClearMask;
import flash.display3D.Context3DCompareMode;
import flash.display3D.Context3DProgramType;
import flash.display3D.Context3DTriangleFace;
import flash.display3D.Context3DVertexBufferFormat;
import flash.display3D.VertexBuffer3D;
import flash.events.Event;
import flash.geom.Matrix3D;
import flash.geom.Rectangle;
    import flash.geom.Vector3D;
    import flash.geom.Vector3D;

/**
	 * 
	 * 
 	 * @author Yogurt3D Engine Core Team
 	 * @company Yogurt3D Corp.
 	 **/
	public class SoftwarePickRenderer extends EngineObject implements IRenderer, IPickRenderer
	{
		
		private var m_initialized					:Boolean 		= false;
	
		private var m_bitmapData					:BitmapData;
		
		private var m_mouseCoordX					:Number;
		private var m_mouseCoordY					:Number;
		
		private var m_lastHit						:SceneObjectRenderable;
		private var m_localHitPosition				:Vector3D;
		private var m_viewport						:Viewport;
		
		public function SoftwarePickRenderer(_viewport:Viewport, _initInternals:Boolean=true)
		{
			super(_initInternals);
			m_viewport = _viewport;
		}
		
		public function get localHitPosition():Vector3D
		{
			return m_localHitPosition;
		}
		
		public function set localHitPosition(value:Vector3D):void
		{
			m_localHitPosition = value;
		}
		
		public function get lastHit():SceneObjectRenderable
		{
			return m_lastHit;
		}
		
		public function set lastHit(value:SceneObjectRenderable):void
		{
			m_lastHit = value;
		}
		
		public function get mouseCoordY():Number
		{
			return m_mouseCoordY;
		}
		
		public function set mouseCoordY(value:Number):void
		{
			m_mouseCoordY = value;
		}
		
		public function get mouseCoordX():Number
		{
			return m_mouseCoordX;
		}
		
		public function set mouseCoordX(value:Number):void
		{
			m_mouseCoordX = value;
		}
		
		private function initHandler( _e:Event ):void{
			m_initialized = false;
		}
		
		protected override function initInternals():void{
			
			m_bitmapData = new BitmapData( 1, 1, false, 0x00000000 );
		}
	
		public function render( device:Context3D, _scene:Scene3D=null, _camera:Camera3D=null, rect:Rectangle=null, excludeList:Array = null ):void
		{
            var vec:Vector.<Number> = MatrixUtils.RAW_DATA;

			var _renderableObject:SceneObjectRenderable;

			var _renderableSet:RenderQueue = _scene.getRenderableSet();
					
			m_lastHit = null;
            m_localHitPosition = null;

			var ray:Ray = Ray.getRayFromMousePosition(_camera,m_viewport,m_mouseCoordX,m_mouseCoordY);
            var cameraPos:Vector3D = _camera.transformation.position;
            var dist:Number = Number.MAX_VALUE;


			var head:RenderQueueNode = _renderableSet.getHead();
			for(var i:int = 0;  head != null; i++, head = head.next )
			{
				_renderableObject = head.scn;
		
				if( !_renderableObject.interactive ) continue;
			
				if( _renderableObject.geometry == null ) continue;

                if(ray.intersectBoundingSphere(_renderableObject.boundingSphere))
                {
                    var point:Vector3D = ray.getIntersectPoint(_renderableObject);
                    if(point){
                        var newDist:Number = Vector3D.distance(point,cameraPos);
                        if( newDist<dist){
                            m_lastHit = _renderableObject;
                            m_localHitPosition = point;
                        }
                    }
                }
            }
        }
	
	}
}