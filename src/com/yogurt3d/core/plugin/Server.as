/*
* Server.as
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

package com.yogurt3d.core.plugin
{
public class Server
	{
		private var m_name					:String;
		
		private var m_version				:uint;
		
		private var m_driverVec				:Vector.<Driver>;
		
		private var m_driverNameVec			:Vector.<String>;
		
		private var m_driverVersionVec		:Vector.<uint>;
		
		public function Server(_name:String, _version:uint)
		{
			m_name = _name;
			m_version = _version;
			
			m_driverVec = new Vector.<Driver>();
			m_driverNameVec = new Vector.<String>();
			m_driverVersionVec = new Vector.<uint>();
		}

		public function get name():String
		{
			return m_name;
		}
		
		public function addDriver( _driver:Driver, _version:uint ):Boolean{
			if( _version == m_version )
			{
				m_driverVec.push( _driver );
				m_driverNameVec.push( _driver.name );
				m_driverVersionVec.push( _version );
				return true;
			}
			return false;
		}
		
		public function getAllDrivers():Vector.<Driver>
		{
			return m_driverVec;
		}
		
		public function getDriverByName(_driverName:String):Vector.<Driver>
		{
			var _output:Vector.<Driver> = new Vector.<Driver>();
			var _len:uint = m_driverNameVec.length;
			for( var i:int = 0; i < _len; i++ )
			{
				if( _driverName == m_driverNameVec[i] )
				{
					_output.push( m_driverVec[i] );
				}
			}
			return _output;
		}
	}
}