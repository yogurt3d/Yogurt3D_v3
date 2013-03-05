/*
* Light.as
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


package com.yogurt3d.core.sceneobjects.lights
{
import com.yogurt3d.YOGURT3D_INTERNAL;
import com.yogurt3d.core.Scene3D;
import com.yogurt3d.core.render.renderqueue.RenderQueue;
import com.yogurt3d.core.sceneobjects.SceneObject;
import com.yogurt3d.core.sceneobjects.camera.frustum.Frustum;
    import com.yogurt3d.core.sceneobjects.transformations.Transformation;
    import com.yogurt3d.core.volumes.BoundingSphere;
import com.yogurt3d.utils.Color;
import com.yogurt3d.utils.MathUtils;
import com.yogurt3d.utils.MatrixUtils;

import flash.geom.Matrix3D;
import flash.geom.Vector3D;

use namespace YOGURT3D_INTERNAL;
	
	/**
	 * This class is a scene object representing a light. It is not visible but it effect the rendering process.<br/>
	 * 
	 * @author Yogurt3D Engine Core Team
	 * @company Yogurt3D Corp.
	 **/
	public class Light extends SceneObject
	{		
		/*		private static var m_depthProgram:ShaderDepthMap;*/
		
		private var m_color				:Color;		
		
		private var m_type				:ELightType;
		
		private var m_direction			:Vector3D;
		private var m_attenuation		:Vector.<Number>;
		
		private var m_range             :Number;
		
		private var m_shadows			:EShadowType					= EShadowType.NONE;
		/*private var m_shadowMap			:RenderTextureTarget;
		private var m_shadowMap2		:RenderTextureTarget;*/
		private var m_shadowColor		:Color;
		
		private var m_frustum :Frustum;
		
		private var m_innerConeAngle	: Number;
		private var m_outerConeAngle	: Number;
		private var m_coneAngles		: Vector.<Number>;

        private var m_directionVector   :Vector.<Number> = new Vector.<Number>(4,true);

        private static var negz:Vector3D = new Vector3D(0,0,-1,1);

		YOGURT3D_INTERNAL var m_renderQueue:RenderQueue;
		
		/**
		 * 
		 * @param _type
		 * @param _color
		 * @param _intensity
		 * 
		 */
		public function Light(_type:ELightType, _color:Color = null, _intensity:Number=1)
		{
			m_type 					= _type;
			
			if(_color)
				m_color 				= _color;
			else
				m_color 				= Color.WHITE;
			
			intensity 				= _intensity;
			
			m_renderQueue = new RenderQueue();



			super( true );

            transformation.onChange.add(onTransformationChange);
		}
        private function onTransformationChange(trans:Transformation):void{
            var _dir:Vector3D = transformation.matrixGlobal.deltaTransformVector( negz );
            _dir.negate();
            _dir.normalize();


            m_directionVector[0] = _dir.x;
            m_directionVector[1] = _dir.y;
            m_directionVector[2] = _dir.z;
        }
		
		public function get shadows():EShadowType
		{
			return m_shadows;
		}
		
		public function set shadows(value:EShadowType):void
		{
			m_shadows = value;
		}
		
		public function get frustum():Frustum
		{
			return m_frustum;
		}
		
		/**
		 * Changes shadow color and alpha
		 * @return 
		 * 
		 */		
		public function get shadowColor():Color
		{
			return m_shadowColor;
		}
		
		/**
		 * @private
		 */
		public function set shadowColor(value:Color):void
		{
			if( value != null )
			{
				m_shadowColor = value;
			}
		}
		
		public function get color():Color{
			return m_color;
		}
		
		public function set color( _color:Color):void
		{
			if( _color != null )
			{
				m_color = _color;
			}
		}
		
		public function get range():Number{
			return m_range;
		}
		
		public function set range( _range:Number):void
		{
			m_range = _range;
			m_coneAngles[3] = m_range;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get type():ELightType
		{
			return m_type;
		}
		/**
		 * @private 
		 * @param value
		 * 
		 */		
		public function set type(value:ELightType):void
		{
			m_type = value;
			
			/*if( m_shadowMap )
			{
			m_shadowMap.dispose();
			m_shadowMap = null;
			}
			
			if( m_shadowMap2 )
			{
			m_shadowMap2.dispose();
			m_shadowMap2 = null;
			}*/
			
			setProjection();
		}
		/**
		 * @inheritDoc
		 * 
		 */		
		public function get attenuation():Vector.<Number>{
			return m_attenuation;
		}
		
		public function set attenuation( _val:Vector.<Number>):void{
			m_attenuation = _val;
		}
		
		/**
		 * @inheritDoc
		 * @default 0.8 (36 degrees)
		 */		
		public function get innerConeAngle():Number{
			return m_innerConeAngle * 2;
		}
		
		public function set innerConeAngle( _val:Number):void{
			m_innerConeAngle = _val / 2;
			m_coneAngles[0] = Math.cos(m_innerConeAngle*MathUtils.DEG_TO_RAD);
			m_coneAngles[2] = 1 / m_coneAngles[0] - m_coneAngles[1];
		}
		/**
		 * @inheritDoc
		 * @default 0.8 (36 degrees)
		 */		
		public function get outerConeAngle():Number{
			
			return m_outerConeAngle * 2;
		}
		
		public function set outerConeAngle( _val:Number):void{
			m_outerConeAngle = _val / 2;
			m_coneAngles[1] = Math.cos(m_outerConeAngle*MathUtils.DEG_TO_RAD);
			m_coneAngles[2] = 1 / (m_coneAngles[0] - m_coneAngles[1]);
			
			setProjection();
		}
		/**
		 * Intensity of the light. Allowed values are between 0-1, from dark to light sequentially. 
		 * @return Intensity of the light source.
		 * 
		 */		
		public function get intensity():Number
		{
			return m_color.a;
		}
		/**
		 * @private 
		 * @param value
		 * 
		 */		
		public function set intensity(value:Number):void
		{
			m_color.a  = value;
		}
		/**
		 * @inheritDoc
		 * 
		 */		
		public function get positionVector():Vector.<Number> 
		{
			var _pos:Vector3D = transformation.globalPosition;
			return Vector.<Number>([_pos.x, _pos.y, _pos.z, 1]);
		}
		/**
		 * 
		 * @return 
		 * 
		 */		
		public function get directionVector():Vector.<Number>
		{
			return m_directionVector
		}
		/**
		 * @inheritDoc
		 * 
		 * @return 
		 * 
		 */
		/*public function get shadowMap():RenderTextureTarget
		{
		if(!m_shadowMap)
		{
		m_shadowMap = new RenderTextureTarget(Y3DCONFIG::SHADOWMAP_SIZE,Y3DCONFIG::SHADOWMAP_SIZE);
		}
		return m_shadowMap;
		}
		
		public function get shadowMap2():RenderTextureTarget
		{
		if(!m_shadowMap2 && m_type == ELightType.POINT )
		{
		m_shadowMap2 = new RenderTextureTarget(Y3DCONFIG::SHADOWMAP_SIZE,Y3DCONFIG::SHADOWMAP_SIZE);
		}
		return m_shadowMap2;
		}*/
		
		
		/*
		public function set shadowMap(value:RenderTextureTarget):void
		{
		m_shadowMap = value;
		}
		
		public function set shadowMap2(value:RenderTextureTarget):void
		{
		m_shadowMap2 = value;
		}*/
		
		/**
		 * sets the projection matrix of the light according to light type and the outer angle 
		 * is used for shadow map generation
		 */
		public function setProjection():void{
			if (m_type == ELightType.SPOT){
				frustum.setProjectionPerspective( outerConeAngle, 1.0, 1, m_range );
			}else if( m_type == ELightType.DIRECTIONAL && scene) {
				updateProjectionDirectional();
			}else if( m_type == ELightType.POINT )
			{
				frustum.m_bSCenterOrginal = new Vector3D();
				frustum.boundingSphere = new BoundingSphere(m_range*m_range, frustum.m_bSCenterOrginal);
			}
		}
		
		
		public function updateProjectionDirectional():void{
			
			//if( m_type == ELightType.DIRECTIONAL && scene) {
			var temp:Matrix3D = MatrixUtils.TEMP_MATRIX;
			temp.identity();
			temp.copyFrom( transformation.matrixGlobal );
			temp.position = new Vector3D(0,0,0);
			temp.invert();
			
			//var _x :Vector.<Number> = this.directionVector;
			
			var _min :Vector3D = new Vector3D(Number.MAX_VALUE, Number.MAX_VALUE, Number.MAX_VALUE);
			var _max :Vector3D = new Vector3D(Number.MIN_VALUE, Number.MIN_VALUE, Number.MIN_VALUE);
			var corner:Vector3D;
			
			var corners:Vector.<Vector3D> = Scene3D(scene).m_rootObject.cumulativeAxisAlignedBoundingBox.cornersGlobal;
			
			for(var i:int = 0 ; i < 8; i++)
			{
				corner = temp.transformVector(corners[i]);
				
				if(corner.x > _max.x) _max.x = corner.x;
				if(corner.x < _min.x) _min.x = corner.x;
				if(corner.y > _max.y) _max.y = corner.y;
				if(corner.y < _min.y) _min.y = corner.y;
				if(corner.z > _max.z) _max.z = corner.z;
				if(corner.z < _min.z) _min.z = corner.z;
				
			}
			frustum.setProjectionOrthoAsymmetric(_min.x, _max.x, _min.y, _max.y, -_max.z, -_min.z );
			
		}
		
		/**
		 * @inheritDoc 
		 * 
		 */		
		override protected function initInternals():void
		{
			super.initInternals();
			
			m_frustum = new Frustum();
			
			if(type == ELightType.POINT)
				m_frustum.sphereCheck = true;
			
			m_attenuation 			= new Vector.<Number>(4,true);
			m_attenuation[0] 		= 1;
			m_attenuation[1] 		= 0;
			m_attenuation[2] 		= 0;
			m_attenuation[3] 		= 1;
			
			m_innerConeAngle 		= 20;
			m_outerConeAngle 		= 30;
			
			m_coneAngles 			= new Vector.<Number>(4,true);
			m_coneAngles[0] 		= m_innerConeAngle;
			m_coneAngles[1] 		= m_outerConeAngle;
			
			innerConeAngle 			= 40;
			outerConeAngle 			= 60;
			range 					= 100;
			
			m_shadowColor 			= new Color(0,0,0,1);
			
			m_direction 			= new Vector3D();
			
			setProjection();
		}
		/**
		 * @inheritDoc 
		 * @return 
		 * 
		 */		
		public override function toString():String{
			return "[Light (type:" + m_type + ", id:"+super.toString()+", position:"+positionVector+", direction:"+directionVector+")]";
		}
		
		public function get coneAngles():Vector.<Number>
		{
			return m_coneAngles;
		}		
	}
}
