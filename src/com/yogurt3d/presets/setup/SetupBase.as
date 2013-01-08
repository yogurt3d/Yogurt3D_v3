/*
* SetupBase.as
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

package com.yogurt3d.presets.setup
{
	import com.yogurt3d.YOGURT3D_INTERNAL;
	import com.yogurt3d.core.Scene3D;
	import com.yogurt3d.core.Viewport;
	import com.yogurt3d.core.sceneobjects.camera.Camera3D;
	
	import flash.display.DisplayObjectContainer;
	
	public class SetupBase
	{
		private var m_viewport			:Viewport;
		
		private var m_parent			:DisplayObjectContainer;
		
		public function SetupBase(_parent:DisplayObjectContainer)
		{			
			m_parent = _parent;
			
			viewport = new Viewport();
		}
		
		protected function ready():void{
		}
		
		YOGURT3D_INTERNAL function get scene():Scene3D
		{
			return m_viewport.scene;
		}
		
		YOGURT3D_INTERNAL function set scene(value:Scene3D):void
		{
			m_viewport.scene = value;
			if( m_viewport.scene && m_viewport.camera &&
				(!m_viewport.scene.cameraSet || 
					m_viewport.scene.cameraSet.indexOf( m_viewport.camera ) == -1)
			)
			{
				m_viewport.scene.addChild( m_viewport.camera );
			}
		}
		
		YOGURT3D_INTERNAL function get camera():Camera3D
		{
			return m_viewport.camera;
		}
		
		YOGURT3D_INTERNAL function set camera(value:Camera3D):void
		{
			m_viewport.camera = value;
			if( m_viewport.scene && 
				(!m_viewport.scene.cameraSet || 
					m_viewport.scene.cameraSet.indexOf( value ) == -1)
			)
			{
				m_viewport.scene.addChild( value );
			}
		}
		
		public function get viewport():Viewport
		{
			return m_viewport;
		}
		
		public function set viewport(value:Viewport):void
		{
			if( m_viewport )
			{
				try{m_parent.removeChild( m_viewport );}catch(_e:* ){}
			}
			m_viewport = value;
			m_parent.addChildAt( m_viewport, 0 );
		}
		
		public function setArea( x:uint, y:uint, width:uint, height:uint):void{
			m_viewport.x = x;
			m_viewport.y = y;
			m_viewport.width = width;
			m_viewport.height = height;
		}
	}
}