/*
 * IMesh.as
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
 
 
package com.yogurt3d.core.geoms {
	import com.yogurt3d.core.objects.IEngineObject;
	import com.yogurt3d.core.volumes.AxisAlignedBoundingBox;
	import com.yogurt3d.core.volumes.BoundingSphere;
	
	/**
	 * 
	 * 
 	 * @author Yogurt3D Engine Core Team
 	 * @company Yogurt3D Corp.
 	 **/
	public interface IMesh extends IEngineObject
	{
		
		function get subMeshList()				:Vector.<SubMesh>;
	
		function get type()						:String;
		
		function get triangleCount()			:int;
		
		function get axisAlignedBoundingBox()	:AxisAlignedBoundingBox;
		
		function get boundingSphere()			:BoundingSphere;
	
	}
}
