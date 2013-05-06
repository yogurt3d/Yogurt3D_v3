/*
* RenderTargetBase.as
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

package com.yogurt3d.core.render.base
{
import com.yogurt3d.core.Scene3D;
    import com.yogurt3d.core.enums.EViewportAntialiasing;
    import com.yogurt3d.core.render.renderer.DefaultRenderer;
import com.yogurt3d.core.render.renderer.IRenderer;
import com.yogurt3d.core.sceneobjects.camera.Camera3D;

import flash.display3D.Context3D;
import flash.geom.Rectangle;

public class RenderTargetBase
	{
		protected var m_scene						:Scene3D;
		
		protected var m_camera						:Camera3D;
		
		protected var m_device						:Context3D;
		
		protected var m_renderer					:IRenderer;
		
		protected var m_currentBackBufferRect		:Rectangle;
		
		protected var m_newBackBufferRect			:Rectangle;
		
		public var autoUpdate						:Boolean = false;

        private var m_antiAliasing                     :EViewportAntialiasing = EViewportAntialiasing.VERY_HIGH_ALIASING;

        protected var antiAliasingDirty             :Boolean = true;

		public function RenderTargetBase()
		{
			m_renderer = new DefaultRenderer();
			m_newBackBufferRect = new Rectangle();
			m_currentBackBufferRect = new Rectangle();
		}

        public function get antiAliasing():EViewportAntialiasing {
            return m_antiAliasing;
        }

        public function set antiAliasing(value:EViewportAntialiasing):void {
            m_antiAliasing = value;
            antiAliasingDirty = true;
        }

		public function get drawRect():Rectangle{
			return m_newBackBufferRect;
		}
		
		public function set drawRect( value:Rectangle ):void{
			m_newBackBufferRect = value;
		}
		
		public function get renderer():IRenderer
		{
			return m_renderer;
		}

		public function set renderer(value:IRenderer):void
		{
			m_renderer = value;
		}

		public function get device():Context3D
		{
			return m_device;
		}

		public function set device(value:Context3D):void
		{
			m_device = value;
		}

		public function get camera():Camera3D
		{
			return m_camera;
		}

		public function set camera(value:Camera3D):void
		{
			m_camera = value;
		}

		public function get scene():Scene3D
		{
			return m_scene;
		}

		public function set scene(value:Scene3D):void
		{
			m_scene = value;
		}

		public function render():void{
			//trace("[RenderTargetBase][render] start");
			renderer.render( device, scene, camera, m_currentBackBufferRect );
			//trace("[RenderTargetBase][render] end");
			
		}


}
}