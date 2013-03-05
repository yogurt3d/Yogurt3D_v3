/*
* Y3D_Parser.as
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


package com.yogurt3d.io.parsers {
import com.yogurt3d.core.geoms.Bone;
import com.yogurt3d.core.geoms.Mesh;
import com.yogurt3d.core.geoms.SkeletalAnimatedMesh;
import com.yogurt3d.core.geoms.SkeletalAnimatedMeshBase;
import com.yogurt3d.core.geoms.SkinnedSubMesh;
import com.yogurt3d.core.geoms.SubMesh;
import com.yogurt3d.core.sceneobjects.transformations.Quaternion;
import com.yogurt3d.io.parsers.interfaces.IParser;

import flash.geom.Vector3D;
import flash.utils.ByteArray;
import flash.utils.Endian;

    /**
	 * 
	 * 
	 * @author Yogurt3D Engine Core Team
	 * @company Yogurt3D Corp.
	 **/
	public class Y3D_Parser implements IParser
	{
		private static const INANIMATE_MESH_DATA	:int	= 0;
		private static const ANIMATED_MESH_DATA		:int	= 1;
		
		private static const AABB_DATA_LENGTH		:int	= 6;
		
		public function Y3D_Parser()
		{
		}
		
		/**
		 * Public interface method to parse any Y3D binary. Return the according mesh data object (Mesh or SkeletalAnimatedGPUMesh).
		 * @param _value ByteArray containing the Y3D binary file.
		 * @param verbose File header info is printed when this is set to true.
		 *
		 */	
		public function parse(_data:*, split:Boolean = true):*
		{
			if(_data is ByteArray)
			{
				return parseByteArray(_data, split);
			}
		}
		/**
		 * Parses any Y3D binary and returns the according data object.
		 * @param _value ByteArray containing the Y3D binary file.
		 * @param verbose File header info is printed when this is set to true.
		 * 
		 */				
		private function parseByteArray(_value:ByteArray, split:Boolean = true):*
		{
			var _dataType				:int;
			var _exportType				:String;	
			
			try{
				ByteArray(_value).inflate();
			}catch(_e:*)
			{
				
			}
			
			_value.position				= 0;
			_value.endian				= Endian.LITTLE_ENDIAN;
			
			_dataType					= _value.readInt();
			_value.position = 0;
			//_value.inflate();
			var len:uint = _value.readUnsignedShort();
			_exportType					= _value.readMultiByte( len, "utf-8");
			
			// new file
			if( _exportType == "Yogurt3D" )
			{
				var version:uint = _value.readShort();
				if( version == 2 )
				{
					return parseY3dFormat2( _value, split );
				}else if( version == 3){
					return parseY3dFormat3( _value, split );
				}
			}

		}
		/**
		 * 
		 * @param _value
		 * @param verbose
		 * @return 
		 * 
		 */
		private function parseY3dFormat3( _value:ByteArray, split:Boolean =  true ):*{
			
			var _verticesData			:Vector.<Number>;
			var _indicesData			:Vector.<uint>;
			var _uvtData				:Vector.<Number>;
			var _uvtData2				:Vector.<Number>;
			var _uvtData3				:Vector.<Number>;
			var _normalData				:Vector.<Number>;
			var _tangentData			:Vector.<Number>;
			
			var type:uint = _value.readShort();
			var exporter:String = _value.readMultiByte( _value.readShort(), "utf-8" );
			var upVector:uint = _value.readShort();
			var vertexCount:int = _value.readInt();
            var vertexCount3:int   = vertexCount * 3;
			var indexCount:int = _value.readInt();
			var tangentsIncluded:Boolean = _value.readBoolean();
			var uvCount:int = _value.readShort();
			var ocFactorIncluded:Boolean = _value.readBoolean();
			
			var uvC:uint;
			
			for(var aabb:int = 0; aabb < AABB_DATA_LENGTH; aabb++)
			{
				_value.readFloat();
			}
			
			if( type == INANIMATE_MESH_DATA )
			{
				
				Y3DCONFIG::TRACE
				{
					trace("[Y3D_Parser] Yogurt3D Mesh File V3");
					trace("[Y3D_Parser] Exporter:", exporter);
					trace("[Y3D_Parser] upVector:", upVector);
					trace("[Y3D_Parser] vertexCount:", vertexCount);
					trace("[Y3D_Parser] triangleCount:", indexCount / 3 );
					trace("[Y3D_Parser] normalsIncluded:", true);
					trace("[Y3D_Parser] tangentsIncluded:", tangentsIncluded);
					trace("[Y3D_Parser] uvCount:", uvCount);
					trace("[Y3D_Parser] ocFactorIncluded:", ocFactorIncluded);
				}
				
				var _verticesLoop			:int;
				var _indicesLoop			:int;
				var _uvtLoop				:int;
				
				// read vertices
				_verticesData						= new Vector.<Number>(vertexCount * 3, true);
				_uvtData							= new Vector.<Number>(vertexCount * 2);
				_uvtData2							= new Vector.<Number>(vertexCount * 2);
				_uvtData3							= new Vector.<Number>(vertexCount * 2);
				_normalData							= new Vector.<Number>(vertexCount * 3);
				// read vertex positions
				for(_verticesLoop = 0; _verticesLoop < vertexCount3; _verticesLoop++)
				{
					_verticesData[_verticesLoop]			= _value.readFloat();
				}
				// read uv data
				for( uvC = 0;uvC < uvCount; uvC++)
				{
					for(_uvtLoop = 0; _uvtLoop < vertexCount; _uvtLoop++){
						if( uvC == 0 )
						{
							_uvtData[(_uvtLoop * 2)]		= _value.readFloat();
							_uvtData[(_uvtLoop * 2) + 1]	= 1 - _value.readFloat();
						}else if ( uvC == 1 ){
							_uvtData2[(_uvtLoop * 2)] 	  = _value.readFloat();
							_uvtData2[(_uvtLoop * 2) + 1] = 1 - _value.readFloat();
						}
						else{
							_uvtData3[(_uvtLoop * 2)] 	  = _value.readFloat();
							_uvtData3[(_uvtLoop * 2) + 1] = 1 - _value.readFloat();
						}
					}
				}
				// read normal data
				for(_verticesLoop = 0; _verticesLoop < vertexCount3; _verticesLoop++){
					_normalData[_verticesLoop]			= _value.readFloat();
				}
				if( tangentsIncluded ){
					_tangentData							= new Vector.<Number>(vertexCount * 3);
					for(_verticesLoop = 0; _verticesLoop < vertexCount3; _verticesLoop++)
					{
						_tangentData[_verticesLoop]			= _value.readFloat();
					}
				}
				_indicesData						= new Vector.<uint>(indexCount);
				for(_indicesLoop = 0; _indicesLoop < indexCount; _indicesLoop++)
				{
					_indicesData[_indicesLoop]					= _value.readInt();
				}
				var _inanimateMesh	:Mesh	= new Mesh();
				var subMesh:SubMesh			= new SubMesh();
				subMesh.vertices			= _verticesData;
				subMesh.indices				= _indicesData;
				subMesh.normals 			= _normalData;
				subMesh.uvt					= _uvtData;
				subMesh.uvt2				= _uvtData2;
				subMesh.uvt3				= _uvtData3;
				subMesh.tangents			= _tangentData;
				_inanimateMesh.subMeshList.push( subMesh );
				return _inanimateMesh;
			}else if( type == ANIMATED_MESH_DATA )
			{
				var boneCount:int = _value.readShort();
				
				Y3DCONFIG::TRACE
				{
					trace("[Y3D_Parser] Yogurt3D Animated Mesh File");
					trace("[Y3D_Parser] Exporter:", exporter);
					trace("[Y3D_Parser] upVector:", upVector);
					trace("[Y3D_Parser] vertexCount:", vertexCount);
					trace("[Y3D_Parser] triangleCount:", indexCount / 3 );
					trace("[Y3D_Parser] normalsIncluded:", true);
					trace("[Y3D_Parser] tangentsIncluded:", tangentsIncluded);
					trace("[Y3D_Parser] uvCount:", uvCount);
					trace("[Y3D_Parser] ocFactorIncluded:", ocFactorIncluded);
					trace("[Y3D_Parser] boneCount:", boneCount);
				}
				
				var _bone:Bone;
				var _boneIndicesCount:int;
				var i:int;
				var bones:Vector.<Bone> = new Vector.<Bone>( boneCount, true );
				for( i = 0; i < boneCount; i++ )
				{
					_bone					= new Bone();
					_boneIndicesCount		= _value.readInt();
					_bone.indices 			= new Vector.<uint>(_boneIndicesCount);
					_bone.weights			= new Vector.<Number>(_boneIndicesCount);
					_bone.translation 		= new Vector3D(_value.readFloat(),_value.readFloat(),_value.readFloat());
					_bone.rotation 			= new Quaternion(_value.readFloat(),_value.readFloat(),_value.readFloat(),_value.readFloat());
					_bone.scale 			= new Vector3D( _value.readFloat(),_value.readFloat(),_value.readFloat());
					_bone.name 				= _value.readMultiByte( _value.readShort(), "utf-8" );
					_bone.parentName		= _value.readMultiByte( _value.readShort(), "utf-8" );
					
					for(var _boneIndicesLoop:int = 0; _boneIndicesLoop < _boneIndicesCount; _boneIndicesLoop++)
					{
						_bone.indices[_boneIndicesLoop]		= _value.readInt();
					}
					for(_boneIndicesLoop = 0; _boneIndicesLoop < _boneIndicesCount; _boneIndicesLoop++)
					{
						_bone.weights[_boneIndicesLoop]		= _value.readFloat();
					}
					bones[i] = _bone;
				}
				
				_verticesData						= new Vector.<Number>(vertexCount * 3, true);
				_uvtData							= new Vector.<Number>(vertexCount * 2);
				_uvtData2							= new Vector.<Number>(vertexCount * 2);
				_normalData							= new Vector.<Number>(vertexCount * 3);
				// read vertex positions
				for(_verticesLoop = 0; _verticesLoop < vertexCount3; _verticesLoop++)
				{
					_verticesData[_verticesLoop]			= _value.readFloat();
				}
				// read uv data
				for( uvC = 0;uvC < uvCount; uvC++)
				{
					for(_uvtLoop = 0; _uvtLoop < vertexCount; _uvtLoop++){
						if( uvC == 0 )
						{
							_uvtData[(_uvtLoop * 2)]		= _value.readFloat();
							_uvtData[(_uvtLoop * 2) + 1]	= 1 - _value.readFloat();
						}else{
							_uvtData2[(_uvtLoop * 2)] 	  = _value.readFloat();
							_uvtData2[(_uvtLoop * 2) + 1] = 1 - _value.readFloat();
						}
						//_uvtData[(_uvtLoop * 3) + 2]	= 0;
					}
				}
				// read normal data
				for(_verticesLoop = 0; _verticesLoop < vertexCount3; _verticesLoop++){
					_normalData[_verticesLoop]			= _value.readFloat();
				}
				if( tangentsIncluded ){
					_tangentData							= new Vector.<Number>(vertexCount * 3);
					for(_verticesLoop = 0; _verticesLoop < vertexCount3; _verticesLoop++)
					{
						_tangentData[_verticesLoop]			= _value.readFloat();
					}
				}
				_indicesData						= new Vector.<uint>(indexCount);
				for(_indicesLoop = 0; _indicesLoop < indexCount; _indicesLoop++)
				{
					_indicesData[_indicesLoop]					= _value.readInt();
				}
				
				var _animateMesh	:SkeletalAnimatedMeshBase			= new SkeletalAnimatedMeshBase();
				var skinnedSubMesh:SkinnedSubMesh = new SkinnedSubMesh();
				skinnedSubMesh.vertices				= _verticesData;
				skinnedSubMesh.indices				= _indicesData;
				skinnedSubMesh.normals 				= _normalData;
				skinnedSubMesh.uvt					= _uvtData;
				skinnedSubMesh.uvt2					= _uvtData2;
				skinnedSubMesh.tangents				= _tangentData;
				skinnedSubMesh.bones 				= bones;
				skinnedSubMesh.originalBoneIndex 	= new Vector.<uint>(bones.length);
				for( i = 0; i < bones.length; i++ )
				{
					skinnedSubMesh.originalBoneIndex[i] = i;
				}
				skinnedSubMesh.updateWeightTable();
				_animateMesh.subMeshList.push( skinnedSubMesh );
				_animateMesh.bones 					= bones;
				_animateMesh.setBindPose();
				
				if( bones.length > SkinnedSubMesh.MAX_BONE_COUNT && split )
				{
					_animateMesh = new SkinnedMeshSplitter().split(	_animateMesh );
				}
				
				return new SkeletalAnimatedMesh( _animateMesh );
				
			}
			return null;
		}
		/**
		 * 
		 * @param _value
		 * @param verbose
		 * @return 
		 * 
		 */
		private function parseY3dFormat2( _value:ByteArray, split:Boolean =  true ):*{
			
			var _verticesData			:Vector.<Number>;
			var _indicesData			:Vector.<uint>;
			var _uvtData				:Vector.<Number>;
			var _normalData				:Vector.<Number>;
			var _tangentData			:Vector.<Number>;
			
			var type:uint = _value.readShort();
			var exporter:String = _value.readMultiByte( _value.readShort(), "utf-8" );
			var upVector:uint = _value.readShort();
			var vertexCount:int = _value.readInt();
            var vertexCount3:int = vertexCount * 3;
			var indexCount:int = _value.readInt();
			var tangentsIncluded:Boolean = _value.readBoolean();
			
			
			
			for(var aabb:int = 0; aabb < AABB_DATA_LENGTH; aabb++)
			{
				_value.readFloat();
			}
			
			if( type == INANIMATE_MESH_DATA )
			{
				
				Y3DCONFIG::TRACE
				{
					trace("[Y3D_Parser] Yogurt3D Mesh File V2");
					trace("[Y3D_Parser] Exporter:", exporter);
					trace("[Y3D_Parser] upVector:", upVector);
					trace("[Y3D_Parser] vertexCount:", vertexCount);
					trace("[Y3D_Parser] triangleCount:", indexCount / 3 );
					trace("[Y3D_Parser] normalsIncluded:", true);
					trace("[Y3D_Parser] tangentsIncluded:", tangentsIncluded);
				}
				
				var _verticesLoop			:int;
				var _indicesLoop			:int;
				var _uvtLoop				:int;
				
				// read vertices
				_verticesData						= new Vector.<Number>(vertexCount * 3, true);
				_uvtData							= new Vector.<Number>(vertexCount * 2);
				_normalData							= new Vector.<Number>(vertexCount * 3);
				// read vertex positions
				for(_verticesLoop = 0; _verticesLoop < vertexCount3; _verticesLoop++)
				{
					_verticesData[_verticesLoop]			= _value.readFloat();
				}
				// read uv data
				for(_uvtLoop = 0; _uvtLoop < vertexCount; _uvtLoop++){
					_uvtData[(_uvtLoop * 2)]		= _value.readFloat();
					_uvtData[(_uvtLoop * 2) + 1]	= 1 - _value.readFloat();
					//_uvtData[(_uvtLoop * 3) + 2]	= 0;
				}
				// read normal data
				for(_verticesLoop = 0; _verticesLoop < vertexCount3; _verticesLoop++){
					_normalData[_verticesLoop]			= _value.readFloat();
				}
				if( tangentsIncluded ){
					_tangentData							= new Vector.<Number>(vertexCount * 3);
					for(_verticesLoop = 0; _verticesLoop < vertexCount3; _verticesLoop++)
					{
						_tangentData[_verticesLoop]			= _value.readFloat();
					}
				}
				_indicesData						= new Vector.<uint>(indexCount);
				for(_indicesLoop = 0; _indicesLoop < indexCount; _indicesLoop++)
				{
					_indicesData[_indicesLoop]					= _value.readInt();
				}
				var _inanimateMesh	:Mesh			= new Mesh();
				var subMesh:SubMesh					= new SubMesh();
				subMesh.vertices				= _verticesData;
				subMesh.indices				= _indicesData;
				subMesh.normals 				= _normalData;
				subMesh.uvt					= _uvtData;
				subMesh.tangents				= _tangentData;
				_inanimateMesh.subMeshList.push( subMesh );
				return _inanimateMesh;
			}else if( type == ANIMATED_MESH_DATA )
			{
				var boneCount:int = _value.readShort();
				
				Y3DCONFIG::TRACE
				{
					trace("[Y3D_Parser] Yogurt3D Animated Mesh File");
					trace("[Y3D_Parser] Exporter:", exporter);
					trace("[Y3D_Parser] upVector:", upVector);
					trace("[Y3D_Parser] vertexCount:", vertexCount);
					trace("[Y3D_Parser] triangleCount:", indexCount / 3 );
					trace("[Y3D_Parser] normalsIncluded:", true);
					trace("[Y3D_Parser] tangentsIncluded:", tangentsIncluded);
					trace("[Y3D_Parser] boneCount:", boneCount);
				}
				
				var _bone:Bone;
				var _boneIndicesCount:int;
				var i:int;
				var bones:Vector.<Bone> = new Vector.<Bone>( boneCount, true );
				for( i = 0; i < boneCount; i++ )
				{
					_bone					= new Bone();
					_boneIndicesCount		= _value.readInt();
					_bone.indices 			= new Vector.<uint>(_boneIndicesCount);
					_bone.weights			= new Vector.<Number>(_boneIndicesCount);
					_bone.translation 		= new Vector3D(_value.readFloat(),_value.readFloat(),_value.readFloat());
					_bone.rotation 			= new Quaternion(_value.readFloat(),_value.readFloat(),_value.readFloat(),_value.readFloat());
					_bone.scale 			= new Vector3D( _value.readFloat(),_value.readFloat(),_value.readFloat());
					_bone.name 				= _value.readMultiByte( _value.readShort(), "utf-8" );
					_bone.parentName		= _value.readMultiByte( _value.readShort(), "utf-8" );
					
					for(var _boneIndicesLoop:int = 0; _boneIndicesLoop < _boneIndicesCount; _boneIndicesLoop++)
					{
						_bone.indices[_boneIndicesLoop]		= _value.readInt();
					}
					for(_boneIndicesLoop = 0; _boneIndicesLoop < _boneIndicesCount; _boneIndicesLoop++)
					{
						_bone.weights[_boneIndicesLoop]		= _value.readFloat();
					}
					bones[i] = _bone;
				}
				
				_verticesData						= new Vector.<Number>(vertexCount * 3, true);
				_uvtData							= new Vector.<Number>(vertexCount * 2);
				_normalData							= new Vector.<Number>(vertexCount * 3);
				// read vertex positions
				for(_verticesLoop = 0; _verticesLoop < vertexCount; _verticesLoop++)
				{
					_verticesData[(_verticesLoop * 3)]			= _value.readFloat();
					_verticesData[(_verticesLoop * 3) + 1]		= _value.readFloat();
					_verticesData[(_verticesLoop * 3) + 2]		= _value.readFloat();
				}
				// read uv data
				for(_uvtLoop = 0; _uvtLoop < vertexCount; _uvtLoop++){
					_uvtData[(_uvtLoop * 2)]		= _value.readFloat();
					_uvtData[(_uvtLoop * 2) + 1]	= 1 - _value.readFloat();
				}
				// read normal data
				for(_verticesLoop = 0; _verticesLoop < vertexCount; _verticesLoop++){
					_normalData[(_verticesLoop * 3)]			= _value.readFloat();
					_normalData[(_verticesLoop * 3) + 1]		= _value.readFloat();
					_normalData[(_verticesLoop * 3) + 2]		= _value.readFloat();
				}
				if( tangentsIncluded ){
					_tangentData							= new Vector.<Number>(vertexCount * 3);
					for(_verticesLoop = 0; _verticesLoop < vertexCount; _verticesLoop++)
					{
						_tangentData[(_verticesLoop * 3)]			= _value.readFloat();
						_tangentData[(_verticesLoop * 3) + 1]		= _value.readFloat();
						_tangentData[(_verticesLoop * 3) + 2]		= _value.readFloat();
					}
				}
				_indicesData						= new Vector.<uint>(indexCount);
				for(_indicesLoop = 0; _indicesLoop < indexCount; _indicesLoop++)
				{
					_indicesData[_indicesLoop]					= _value.readInt();
				}
				
				var _animateMesh	:SkeletalAnimatedMeshBase			= new SkeletalAnimatedMeshBase();
				var skinnedSubMesh:SkinnedSubMesh = new SkinnedSubMesh();
				skinnedSubMesh.vertices				= _verticesData;
				skinnedSubMesh.indices				= _indicesData;
				skinnedSubMesh.normals 				= _normalData;
				skinnedSubMesh.uvt					= _uvtData;
				skinnedSubMesh.tangents				= _tangentData;
				skinnedSubMesh.bones 				= bones;
				skinnedSubMesh.originalBoneIndex 	= new Vector.<uint>(bones.length);
				for( i = 0; i < bones.length; i++ )
				{
					skinnedSubMesh.originalBoneIndex[i] = i;
				}
				skinnedSubMesh.updateWeightTable();
				_animateMesh.subMeshList.push( skinnedSubMesh );
				_animateMesh.bones 					= bones;
				_animateMesh.setBindPose();
				
				if( bones.length > SkinnedSubMesh.MAX_BONE_COUNT && split )
				{
					_animateMesh = new SkinnedMeshSplitter().split(	_animateMesh );
				}
				
				return new SkeletalAnimatedMesh( _animateMesh );
				
			}
			return null;
		}
	}
}
