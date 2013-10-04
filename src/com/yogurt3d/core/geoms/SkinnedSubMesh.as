/*
* SkinnedSubMesh.as
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

package com.yogurt3d.core.geoms
{
import com.yogurt3d.YOGURT3D_INTERNAL;
import com.yogurt3d.core.managers.IDManager;
import com.yogurt3d.utils.MeshUtils;

import flash.display3D.Context3D;
import flash.display3D.VertexBuffer3D;
import flash.utils.Dictionary;

use namespace YOGURT3D_INTERNAL;
	/**
	 * 
	 * 
	 * @author Yogurt3D Engine Core Team
	 * @company Yogurt3D Corp.
	 **/
	public class SkinnedSubMesh extends SubMesh
	{
		public static const MAX_BONE_COUNT					:uint = 38;
		
		YOGURT3D_INTERNAL var m_boneDataBuffersByContext3D 	:Dictionary;
		// maps the index of an un-partitioned vertex to that same vertex if it has been added to this particular partition. 
		// speeds up checking for duplicate vertices so we don't add the same vertex more than once.  
		private var m_indicesMap							:Dictionary;
		public var vertexList								:Vector.<uint>;
		public var originalBoneIndex						:Vector.<uint>;
		
		public var bones									:Vector.<Bone>;
		public var boneIndies								:Vector.<Number>;
		public var boneWeights								:Vector.<Number>;
			
		public function SkinnedSubMesh()
		{
			clear();
			m_boneDataBuffersByContext3D = new Dictionary();
		}
		
		public function get indicesMap():Dictionary
		{
			return m_indicesMap;
		}
		
		public function set indicesMap(value:Dictionary):void
		{
			m_indicesMap = value;
		}
		
		public override function disposeGPU():void{
			super.disposeGPU();
			
			if( m_boneDataBuffersByContext3D )	
			{
				for each (var inBuf:VertexBuffer3D in m_boneDataBuffersByContext3D) {inBuf.dispose();}		
				m_boneDataBuffersByContext3D = new Dictionary();
			}
		}
		
		public override function get type():String{
			return "SkinnedMesh";
		}
		
		/**
		 * clears _Vertices, _Indices, and _IndicesMap, so we can start building another mesh subset with the same set of bones. 
		 * 
		 */
		public function clear():void{
			
			vertices = new Vector.<Number>();
			indices = new Vector.<uint>();
			indicesMap = new Dictionary();
			bones = new Vector.<Bone>();
			vertexList = new Vector.<uint>;
			originalBoneIndex = new Vector.<uint>;	
		}
		
		public function printBones():void{
			
			Y3DCONFIG::TRACE
			{
				trace("*******************************************");
				
				trace("Orig Bone Index ", this.originalBoneIndex.length," = ",this.originalBoneIndex);
				trace("Bone Weights",this.boneWeights.length ," = ",this.boneWeights);
				trace("Bone Indices", this.boneIndies.length," = ",this.boneIndies);
				trace("Mesh Indices ",this.indices.length ," = ",this.indices);
				trace("Bones:", this.bones.length);
				
				trace("*******************************************");
			}
		}

		public function updateWeightTable():void{

			boneWeights = new Vector.<Number>(vertexCount*8,true);
			boneIndies = new Vector.<Number>(vertexCount*8,true);

            for(var i:int = 0; i < boneIndies.length; i++){
                boneIndies[i] = -1;
            }

			var vertexIndex:int, index:uint, boneIndex:int;
			var boneIndiceIndex:int, bone:Bone;
			var vLen:uint = vertexList.length;
			var bLen:uint = bones.length;
            var nIndex:uint;

			if( vLen != 0 )
			{
				for( vertexIndex = 0; vertexIndex < vLen; vertexIndex++ ){
					index = 0;
					for( boneIndex = 0; boneIndex < bLen; boneIndex++ ){
						bone = bones[boneIndex];
						boneIndiceIndex = bone.indices.indexOf( vertexList[vertexIndex] );

						if( boneIndiceIndex > -1 ){
                            nIndex = vertexIndex*8 + index;
                            boneIndies[nIndex] = boneIndex * 3 ;
                            boneWeights[nIndex] = bone.weights[ boneIndiceIndex ];
                            index++;
						}
					}
				}

                vertexList = null;
			}else{

				for( vertexIndex = 0; vertexIndex < vertexCount; vertexIndex++ )
				{
					index = 0;
					for( boneIndex = 0; boneIndex < bLen; boneIndex++ )
					{
						bone = bones[boneIndex];
						boneIndiceIndex = bone.indices.indexOf( vertexIndex );
						if( boneIndiceIndex > -1 )
						{
                            nIndex = vertexIndex*8 + index;
                            boneIndies[nIndex] = boneIndex * 3 ;
                            boneWeights[nIndex] = bone.weights[ boneIndiceIndex ];
							index++;
						}
					}
				}
			}
		}
		
		override protected function trackObject():void
		{
			IDManager.trackObject(this, SkinnedSubMesh);
		}
		
		/**
		 * @inheritDoc
		 **/
		public function getBoneDataBufferByContext3D(_context3D:Context3D):VertexBuffer3D {
			if (m_boneDataBuffersByContext3D[_context3D]) {
				return m_boneDataBuffersByContext3D[_context3D];
			}			
			var _bufferData	:Vector.<Number>			= MeshUtils.createVertexBufferDataAsVector( m_vertexCount, boneIndies, boneWeights );
			
			m_boneDataBuffersByContext3D[_context3D] = _context3D.createVertexBuffer( m_vertexCount, 16);			
			m_boneDataBuffersByContext3D[_context3D].uploadFromVector( _bufferData, 0, m_vertexCount );
			
			return m_boneDataBuffersByContext3D[_context3D];
		}	
	}
}
