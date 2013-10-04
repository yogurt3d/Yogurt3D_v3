package com.yogurt3d.core.sceneobjects
{
import com.yogurt3d.YOGURT3D_INTERNAL;
import com.yogurt3d.core.Scene3D;
import com.yogurt3d.core.Viewport;
import com.yogurt3d.core.geoms.IMesh;
import com.yogurt3d.core.managers.IDManager;
import com.yogurt3d.core.material.MaterialBase;
import com.yogurt3d.core.objects.IEngineObject;
import com.yogurt3d.core.render.texture.base.RenderTextureTargetBase;
import com.yogurt3d.core.sceneobjects.transformations.Transformation;
import com.yogurt3d.core.volumes.AxisAlignedBoundingBox;
import com.yogurt3d.utils.MatrixUtils;

import flash.geom.Matrix3D;
import flash.geom.Utils3D;
    import flash.geom.Vector3D;

    public class SceneObjectRenderable extends SceneObject
	{
		use namespace YOGURT3D_INTERNAL;
		
		YOGURT3D_INTERNAL var m_geometry			:IMesh;
		
	//	YOGURT3D_INTERNAL var m_culling				:String 						= Context3DTriangleFace.BACK;
		
		YOGURT3D_INTERNAL var m_isInFrustum			:Boolean 						= false;
		
		public			  var castShadows			:Boolean 						= false;
		
		public			  var receiveShadows		:Boolean 						= false;
		
		private 		  var m_drawWireFrame		:Boolean						= false;
		
		private 		  var projectedVectices		:Vector.<Number>;
		
		private 		  var projectedUV			:Vector.<Number>;
			
		private			  var m_material			:MaterialBase;
		
		
		public function SceneObjectRenderable(geometry:IMesh=null, material:MaterialBase=null, _initInternals:Boolean = true)
		{
            this.geometry = geometry;
            this.material = material;
			super(_initInternals);
		}
		

		/**********************************************************************
		 * Wireframe mode
		 * ********************************************************************/
		public function get wireframe():Boolean{
			return m_drawWireFrame;
		}
		
		public function set wireframe( _value:Boolean ):void{
			m_drawWireFrame = _value;
		}
		
		Y3DCONFIG::DEBUG
		{
			YOGURT3D_INTERNAL function drawWireFrame(_matrix:Matrix3D, _viewport:Viewport):void{
				
				if( m_drawWireFrame )
				{
					var matrix:Matrix3D = MatrixUtils.TEMP_MATRIX;
					matrix.copyFrom( _matrix );
					matrix.prepend( transformation.matrixGlobal );
					
					if( projectedVectices == null || projectedVectices.length != geometry.subMeshList[0].vertexCount * 2)
					{
						projectedVectices = new Vector.<Number>(geometry.subMeshList[0].vertexCount * 2);
					}
					
					if( projectedUV == null || projectedUV.length != geometry.subMeshList[0].vertexCount * 3)
					{
						projectedUV = new Vector.<Number>(geometry.subMeshList[0].vertexCount * 3);
					}
					
					Utils3D.projectVectors( matrix, geometry.subMeshList[0].vertices,projectedVectices,projectedUV);
					
					_viewport.graphics.lineStyle(1,0xff0000);
					
					for( var i:int = 0 ; i < geometry.subMeshList[0].triangleCount; i++ )
					{
						var i1:uint = geometry.subMeshList[0].indices[ i * 3 + 0 ];
						var i2:uint = geometry.subMeshList[0].indices[ i * 3 + 1 ];
						var i3:uint = geometry.subMeshList[0].indices[ i * 3 + 2 ];
						
						var x1:Number = projectedVectices[i1*2];
						var y1:Number = projectedVectices[i1*2+1];
						
						var x2:Number = projectedVectices[i2*2];
						var y2:Number = projectedVectices[i2*2+1];
						
						var x3:Number = projectedVectices[i3*2];
						var y3:Number = projectedVectices[i3*2+1];
						
						_viewport.graphics.moveTo( x1, y1 );
						_viewport.graphics.lineTo( x2, y2 );
						_viewport.graphics.lineTo( x3, y3 );
						_viewport.graphics.lineTo( x1, y1 );
					}
				}	
			}
		}
		/**
		 * @inheritDoc
		 * */
		public function get geometry():IMesh
		{
			return m_geometry;
		}
		
		/**
		 * @inheritDoc
		 * */
		public function set geometry(_value:IMesh):void
		{
			m_geometry = _value;
		}
		
//		public function get culling() : String {
//			return m_culling;
//		}
//		
//		public function set culling(_value : String) : void {
//			m_culling = _value;
//		}		
		
		
		override protected function trackObject():void
		{
			IDManager.trackObject(this, SceneObjectRenderable);
		}
		
		override protected function initInternals():void
		{
			super.initInternals();
			onAddedToScene.add(onAddedToSceneGraph);
			onRemovedFromScene.add(onRemovedFromSceneGraph);
		}
		
		public function get material():MaterialBase
		{
			return m_material;
		}
		
		public function set material(value:MaterialBase):void
		{
			m_material = value;
		}
		
		override public function instance():*
		{
			var _sceneObjectCopy:SceneObjectRenderable 	= new SceneObjectRenderable();
			
			_sceneObjectCopy.geometry	 				= m_geometry;
			_sceneObjectCopy.material					= m_material;
			_sceneObjectCopy.visible 					= visible;
			_sceneObjectCopy.interactive 				= interactive;
			_sceneObjectCopy.pickEnabled 				= pickEnabled;
			
			_sceneObjectCopy.castShadows 				= castShadows;
			_sceneObjectCopy.receiveShadows 			= receiveShadows;
			
			_sceneObjectCopy.m_transformation = Transformation(m_transformation.clone());
			_sceneObjectCopy.m_transformation.m_ownerSceneObject = _sceneObjectCopy;
			
			return _sceneObjectCopy;
		}
		override public function clone():IEngineObject {			
			var _sceneObjectCopy:SceneObjectRenderable 	= new SceneObjectRenderable();
			_sceneObjectCopy.geometry	 				= geometry;
			_sceneObjectCopy.material					= m_material;
			_sceneObjectCopy.visible 					= visible;
			_sceneObjectCopy.interactive 				= interactive;
			_sceneObjectCopy.pickEnabled 				= pickEnabled;
			
			_sceneObjectCopy.castShadows 				= castShadows;
			_sceneObjectCopy.receiveShadows 			= receiveShadows;
			
			_sceneObjectCopy.m_transformation = Transformation(m_transformation.clone());
			_sceneObjectCopy.m_transformation.m_ownerSceneObject = _sceneObjectCopy;
			
			return _sceneObjectCopy;
		}
		
		public override function dispose():void{
			m_geometry = null;
			m_material = null;
			
			super.dispose();
		}
		
		public override function disposeDeep():void{
			if( m_geometry )
			{
				m_geometry.disposeDeep();
				m_geometry = null;
			}

			if( m_material )
			{
				m_material.disposeDeep();
				m_material = null;
			}
			super.disposeDeep();
		}
		
		public override function disposeGPU():void{
			
			m_geometry.disposeGPU();
		//	m_material.disposeGPU();
			
			super.disposeGPU();
		}
		
		public override function get axisAlignedBoundingBox():AxisAlignedBoundingBox
		{
			if(!m_aabb)
			{
                if(geometry){
				//AxisAlignedBoundingBox(geomBox.m_minInitial, geomBox.m_maxInitial, transformation); geometry.axisAlignedBoundingBox.clone() as AxisAlignedBoundingBox
				m_aabb = new AxisAlignedBoundingBox(geometry.axisAlignedBoundingBox.m_minInitial.clone(), geometry.axisAlignedBoundingBox.m_maxInitial.clone(), transformation);;
			}else{
                    m_aabb=new AxisAlignedBoundingBox(new Vector3D(),new Vector3D());
                }
            }
			return m_aabb;
		}
		public override function get cumulativeAxisAlignedBoundingBox():AxisAlignedBoundingBox
		{
			var len:uint = (children)?children.length:0;
			
			if( len )
			{
				if(m_reinitboundingVolumes)
				{
					var geomBox:AxisAlignedBoundingBox = geometry.axisAlignedBoundingBox;
					if(!m_aabbCumulative)
					{
						m_aabbCumulative = new AxisAlignedBoundingBox(geomBox.m_minInitial.clone(), geomBox.m_maxInitial.clone(), transformation);
						//m_aabbCumulative.update();
					}
					else	
						m_aabbCumulative.setInitialMinMax(geomBox.m_minInitial.clone(), geomBox.m_maxInitial.clone(),transformation);
					
					for(var i:int; i < len; i++)
					{
						var child:SceneObject = children[i];
						
						m_aabbCumulative.merge( child.cumulativeAxisAlignedBoundingBox );	
					}
					
					m_reinitboundingVolumes = false;
					
				}
				return m_aabbCumulative;
				
			}else
			{
				if( m_reinitboundingVolumes )
				{
					if( m_aabbCumulative )
					{
						m_aabbCumulative.dispose();
					}
					m_aabbCumulative = null;
					m_reinitboundingVolumes = false;
				}
				return axisAlignedBoundingBox;	
				
			}
			
		}
		
//		public function get material():Material
//		{
//			return m_material;
//		}
//
//		public function set material(value:Material):void
//		{
//			$unregisterMaterial();
//			m_material = value;
//			// add render targets to scene
//			$registerMaterial();
//		}
		private function $unregisterMaterial():void{
//			if( m_material )
//			{
//				m_material.onRenderTargetAdded.remove( onMaterialRenderTargetAdded );
//				m_material.onRenderTargetRemoved.remove( onMaterialRenderTargetRemoved );
//				for( var i:int = 0; i < m_material.renderTargets.length; i++ )
//					if( scene )
//						scene.removeRenderTarget( m_material.renderTargets[i] );
//			}
		}
		private function $registerMaterial():void{
//			if( m_material )
//			{
//				for( var i:int = 0; i < m_material.renderTargets.length; i++ )
//					if( scene )
//						scene.addRenderTarget( m_material.renderTargets[i] );
//				
//				m_material.onRenderTargetAdded.add( onMaterialRenderTargetAdded );
//				m_material.onRenderTargetRemoved.add( onMaterialRenderTargetRemoved );
//			}
		}
		private function onMaterialRenderTargetAdded( value:RenderTextureTargetBase ):void{
			if( scene )
				scene.addRenderTarget( value );
		}
		private function onMaterialRenderTargetRemoved( value:RenderTextureTargetBase ):void{
			if( scene )
				scene.removeRenderTarget( value );
		}
		public function onAddedToSceneGraph(_child:SceneObject, _scene:Scene3D):void{
		//	$registerMaterial();
		}
		public function onRemovedFromSceneGraph(_child:SceneObject, _scene:Scene3D):void{
		//	$unregisterMaterial();
		}

	}
}