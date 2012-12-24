/*
* CompressedFile.as
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

package com.yogurt3d.io.loaders
{
	import com.yogurt3d.io.parsers.TextureMap_Parser;
	import com.yogurt3d.io.parsers.Y3D_Parser;
	import com.yogurt3d.io.parsers.YOA_Parser;
	
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.IDataInput;
	
	import nochump.util.zip.ZipEntry;
	import nochump.util.zip.ZipFile;

	public class CompressedFile extends ZipFile
	{
		private var m_internalCache:Dictionary;
		
		public function CompressedFile(data:IDataInput)
		{
			super(data);
			m_internalCache = new Dictionary();
		}
		/**
		 * 
		 * @param name of file. Could include directory
		 * @param asyncFunction Not implemented
		 * @return 
		 * 
		 */		
		public function getContent(name:String, asyncFunction:Function = null):*{
			if( m_internalCache[name] != null )
			{
				return m_internalCache[name];
			}
			var entry:ZipEntry = getEntry( name );
			var dotIndex:int = entry.name.lastIndexOf(".");
			
			var byteArray:ByteArray = getInput(entry);
			
			
			if( dotIndex == -1 )
			{
				return byteArray;
			}
			var extension:String = name.substring(dotIndex+1, name.length ).toLowerCase();
			
			if( extension == "y3d")
			{
				m_internalCache[name] = new Y3D_Parser().parse( byteArray );
				return m_internalCache[name];
			}else if( extension == "yoa")
			{
				m_internalCache[name] = new YOA_Parser().parse( byteArray );
				return m_internalCache[name];
			}else if( extension == "atf")
			{
				m_internalCache[name] = new TextureMap_Parser().parse( byteArray );
				return m_internalCache[name];
			}else if( extension == "jpg" || extension == "png" || extension == "bmp" || extension == "gif")
			{
				m_internalCache[name] = new TextureMap_Parser().parse( byteArray );
				return m_internalCache[name];
			}
			return null;
		}
	}
}