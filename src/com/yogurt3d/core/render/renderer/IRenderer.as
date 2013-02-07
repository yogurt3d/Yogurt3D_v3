/*
* IRenderer.as
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
import com.yogurt3d.core.sceneobjects.camera.Camera3D;

import flash.display3D.Context3D;
import flash.geom.Rectangle;

public interface IRenderer
	{
		function render( device:Context3D, scene:Scene3D=null, camera:Camera3D=null, rect:Rectangle=null, excludeList:Array = null ):void;
	}
}