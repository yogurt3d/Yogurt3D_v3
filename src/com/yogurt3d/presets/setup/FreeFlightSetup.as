/*
* FreeFlightSetup.as
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
	import com.yogurt3d.core.Scene;
	import com.yogurt3d.core.Scene3D;
	import com.yogurt3d.core.Viewport;
	import com.yogurt3d.presets.cameras.FreeFlightCamera;
	
	import flash.display.DisplayObjectContainer;
	import com.yogurt3d.YOGURT3D_INTERNAL;

	public class FreeFlightSetup extends SetupBase
	{
		public function FreeFlightSetup(_parent:DisplayObjectContainer)
		{
			super( _parent );
			
			viewport = new Viewport();
			if( _parent.stage )
			{
				viewport = new Viewport();
				viewport.x = 0;
				viewport.y= 0;
				viewport.width = _parent.stage.stageWidth;
				viewport.height = _parent.stage.stageHeight;
			}else{
				viewport = new Viewport();
				viewport.x = 0;
				viewport.y= 0;
				viewport.width = _parent.width;
				viewport.height = _parent.height;
			}
			
			YOGURT3D_INTERNAL::scene = new Scene();
			
			YOGURT3D_INTERNAL::camera = new FreeFlightCamera(viewport);
			
			ready();
		}
		
		public function get scene():Scene3D{
			return YOGURT3D_INTERNAL::scene as Scene3D;
		}
		public function set scene(value:Scene3D):void{
			YOGURT3D_INTERNAL::scene = value;
		}
		
		public function get camera():FreeFlightCamera{
			return YOGURT3D_INTERNAL::camera as FreeFlightCamera;
		}
		
		public function set camera(value:FreeFlightCamera):void{
			YOGURT3D_INTERNAL::camera = value;
		}
	}
}