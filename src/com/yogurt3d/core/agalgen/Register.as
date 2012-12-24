/*
* Register.as
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

package com.yogurt3d.core.agalgen
{
	import com.yogurt3d.core.material.enum.ERegisterShaderType;
	import com.yogurt3d.core.material.enum.ERegisterType;

	public class Register implements IRegister
	{
		private var m_read				:Boolean = true;
		private var m_write				:Boolean = true;
		
		private var m_shaderType		:ERegisterShaderType = ERegisterShaderType.BOTH;
		private var m_val				:ERegisterType;
		private var m_index				:int;
		private var m_components		:String;
		private var m_id				:String;
		
		public function Register(val:ERegisterType, id:String, index:int = 0, components:String = "xyzw", read:Boolean = true, write:Boolean = true)
		{
			m_val = val;
			m_read = read;
			m_write = write;
			m_index = index;
			m_id = id;
			
			if( components == "" ){
				components = "xyzw";
			}else if(components == "fs"){
				components = "";
			}
			
			m_components = components;
		}

		public function get id():String
		{
			return m_id;
		}

		public function set id(value:String):void
		{
			m_id = value;
		}

		public function get components():String
		{
			return m_components;
		}

		public function get index():int
		{
			return m_index;
		}

		public function get read():Boolean{
			return m_read;
		}
		
		public function get write():Boolean{
			return m_write;
		}
		
		public function get shaderType():ERegisterShaderType{
			return m_shaderType;
		}
		
		public function toString():String{
			return m_val.value + (m_index>-1?""+m_index:"") + ((m_components!=""&&m_components!="xyzw")?"."+m_components:"");
		}
		
		private function get _x():String{
			return m_components.substr(0,1);
		}
		
		private function get _y():String{
			return m_components.substr(1,1);
		}
		
		private function get _z():String{
			return m_components.substr(2,1);
		}
		
		private function get _w():String{
			return m_components.substr(3,1);
		}
		
		public function get x():IRegister{
			if( m_components.length >= 1 )
			{
				return new Register(m_val, m_id, m_index, _x );
			}
			throw new Error("[Y3D_ERROR] IRegister: x does not exist");	
		}
		
		public function get xx():IRegister{
			if( m_components.length >= 1 )
			{
				return new Register(m_val, m_id, m_index, _x+_x );
			}	
			throw new Error("[Y3D_ERROR] IRegister: x does not exist");
		}
		
		public function get xxx():IRegister{
			if( m_components.length >= 1 )
			{
				return new Register(m_val, m_id, m_index, _x+_x+_x);
			}
			throw new Error("[Y3D_ERROR] IRegister: x does not exist");
		}
		
		public function get xxxx():IRegister{
			if( m_components.length >= 1 )
			{
				return new Register(m_val, m_id, m_index, _x+_x+_x+_x);
			}
			throw new Error("[Y3D_ERROR] IRegister: x does not exist");
		}
		
		public function get y():IRegister{
			if( m_components.length >= 2 )
			{
				return new Register(m_val, m_id, m_index, _y );
			}
			throw new Error("[Y3D_ERROR] IRegister: y does not exist");	
		}
		
		public function get yy():IRegister{
			if( m_components.length >= 2 )
			{
				return new Register(m_val, m_id, m_index, _y+_y );
			}
			throw new Error("[Y3D_ERROR] IRegister: y does not exist");
		}
		
		public function get yyy():IRegister{
			if( m_components.length >= 2 )
			{
				return new Register(m_val, m_id, m_index, _y+_y+_y );
			}
			throw new Error("[Y3D_ERROR] IRegister: y does not exist");
		}	
		
		public function get yyyy():IRegister{
			if( m_components.length >= 2 )
			{
				return new Register(m_val, m_id, m_index, _y+_y+_y+_y);
			}
			throw new Error("[Y3D_ERROR] IRegister: y does not exist");
		}
			
		public function get z():IRegister{
			if( m_components.length >= 3 )
			{
				return new Register(m_val, m_id, m_index, _z );
			}
			throw new Error("[Y3D_ERROR] IRegister: z does not exist");
		}
		
		public function get zz():IRegister{
			if( m_components.length >= 3 )
			{
				return new Register(m_val, m_id, m_index, _z+_z );
			}
			throw new Error("[Y3D_ERROR] IRegister: z does not exist");
		}
		
		public function get zzz():IRegister{
			if( m_components.length >= 3 )
			{
				return new Register(m_val, m_id, m_index, _z+_z+_z );
			}
			throw new Error("[Y3D_ERROR] IRegister: z does not exist");
		}
		
		public function get zzzz():IRegister{
			if( m_components.length >= 3 )
			{
				return new Register(m_val, m_id, m_index, _z+_z+_z+_z );
			}
			throw new Error("[Y3D_ERROR] IRegister: z does not exist");
		}
		
		public function get w():IRegister{
			if( m_components.length == 4 )
			{
				return new Register(m_val, m_id, m_index, _w );
			}
				
			throw new Error("[Y3D_ERROR] IRegister: w does not exist");
			
		}
		
		public function get ww():IRegister{
			if( m_components.length == 4 )
			{
				return new Register(m_val, m_id, m_index, _w+_w );
			}
			
			throw new Error("[Y3D_ERROR] IRegister: w does not exist");
			
		}
		
		public function get www():IRegister{
			if( m_components.length == 4 )
			{
				return new Register(m_val, m_id, m_index, _w+_w+_w );
			}
			
			throw new Error("[Y3D_ERROR] IRegister: w does not exist");
		}
		
		public function get wwww():IRegister{
			if( m_components.length == 4 )
			{
				return new Register(m_val, m_id, m_index, _w+_w+_w+_w );
			}
			
			throw new Error("[Y3D_ERROR] IRegister: w does not exist");
		}
		
		public function get xy():IRegister{
			if( m_components.length >= 2 )
			{
				return new Register(m_val, m_id, m_index, _x+_y);
			}
			throw new Error("[Y3D_ERROR] IRegister: xy does not exist");
		}
		
		public function get xz():IRegister{
			if( m_components.length >= 3 )
			{
				return new Register(m_val, m_id, m_index, _x+_z);
			}
			throw new Error("[Y3D_ERROR] IRegister: xz does not exist");
		}
		
		public function get xw():IRegister{
			if( m_components.length == 4 )
			{
				return new Register(m_val, m_id, m_index, _x+_w);
			}
			throw new Error("[Y3D_ERROR] IRegister: xw does not exist");
		}
		
		public function get yx():IRegister{
			if( m_components.length >= 2 )
			{
				return new Register(m_val, m_id, m_index, _y+_x);
			}
			throw new Error("[Y3D_ERROR] IRegister: yx does not exist");
		}
		
		public function get yz():IRegister{
			if( m_components.length >= 3 )
			{
				return new Register(m_val, m_id, m_index, _y+_z);
			}
			throw new Error("[Y3D_ERROR] IRegister: yz does not exist");
		}
		
		public function get yw():IRegister{
			if( m_components.length == 4 )
			{
				return new Register(m_val, m_id, m_index, _y+_w);
			}
			throw new Error("[Y3D_ERROR] IRegister: yw does not exist");
		}
		
		public function get zx():IRegister{
			if( m_components.length >= 3 )
			{
				return new Register(m_val, m_id, m_index, _z+_x);
			}
			throw new Error("[Y3D_ERROR] IRegister: zx does not exist");
		}
		
		public function get zy():IRegister{
			if( m_components.length >= 3 )
			{
				return new Register(m_val, m_id, m_index, _z+_y);
			}
			throw new Error("[Y3D_ERROR] IRegister: zy does not exist");
		}
		
		public function get zw():IRegister{
			if( m_components.length == 4 )
			{
				return new Register(m_val, m_id, m_index, _z+_w);
			}
			throw new Error("[Y3D_ERROR] IRegister: zw does not exist");
		}
		
		public function get wx():IRegister{
			if( m_components.length == 4 )
			{
				return new Register(m_val, m_id, m_index, _w+_x);
			}
			throw new Error("[Y3D_ERROR] IRegister: wx does not exist");
		}
		
		public function get wy():IRegister{
			if( m_components.length == 4 )
			{
				return new Register(m_val, m_id, m_index, _w+_y);
			}
			throw new Error("[Y3D_ERROR] IRegister: wy does not exist");
		}
		
		public function get wz():IRegister{
			if( m_components.length == 4 )
			{
				return new Register(m_val, m_id, m_index, _w+_z);
			}
			throw new Error("[Y3D_ERROR] IRegister: wz does not exist");
		}
		
		public function get xxy():IRegister{
			if( m_components.length >=2 )
			{
				return new Register(m_val, m_id, m_index, _x+_x+_y);
			}
			throw new Error("[Y3D_ERROR] IRegister: xxy does not exist");
		}
		
		public function get xxz():IRegister{
			if( m_components.length >=3 )
			{
				return new Register(m_val, m_id, m_index, _x+_x+_z);
			}
			throw new Error("[Y3D_ERROR] IRegister: xxz does not exist");
		
		}
		
		public function get xxw():IRegister{
			if( m_components.length == 4 )
			{
				return new Register(m_val, m_id, m_index, _x+_x+_w);
			}
			throw new Error("[Y3D_ERROR] IRegister: xxw does not exist");
		}
		
		public function get xyx():IRegister{
			if( m_components.length >=2 )
			{
				return new Register(m_val, m_id, m_index, _x+_y+_x);
			}
			throw new Error("[Y3D_ERROR] IRegister: xyx does not exist");
		}
		
		public function get xyy():IRegister{
			if( m_components.length >=2 )
			{
				return new Register(m_val, m_id, m_index, _x+_y+_y);
			}
			throw new Error("[Y3D_ERROR] IRegister: xyy does not exist");
		}
		
		public function get xyz():IRegister{
			if( m_components.length >=3 )
			{
				return new Register(m_val, m_id, m_index, _x+_y+_z);
			}
			throw new Error("[Y3D_ERROR] IRegister: xyz does not exist");
		}
		
		public function get xyw():IRegister{
			if( m_components.length == 4 )
			{
				return new Register(m_val, m_id, m_index, _x+_y+_w);
			}
			throw new Error("[Y3D_ERROR] IRegister: xyw does not exist");
		
		}
		
		public function get xzx():IRegister{
			if( m_components.length >=3 )
			{
				return new Register(m_val, m_id, m_index, _x+_z+_x);
			}
			throw new Error("[Y3D_ERROR] IRegister: xzx does not exist");
		}
		
		public function get xzy():IRegister{
			if( m_components.length >=3 )
			{
				return new Register(m_val, m_id, m_index, _x+_z+_y);
			}
			throw new Error("[Y3D_ERROR] IRegister: xzy does not exist");
		}
		
		public function get xzz():IRegister{
			if( m_components.length >=3 )
			{
				return new Register(m_val, m_id, m_index, _x+_z+_z);
			}
			throw new Error("[Y3D_ERROR] IRegister: xzz does not exist");
		}
		
		public function get xzw():IRegister{
			if( m_components.length == 4 )
			{
				return new Register(m_val, m_id, m_index, _x+_z+_w);
			}
			throw new Error("[Y3D_ERROR] IRegister: xzw does not exist");
		}
		
		public function get xwx():IRegister{
			if( m_components.length == 4 )
			{
				return new Register(m_val, m_id, m_index, _x+_w+_x);
			}
			throw new Error("[Y3D_ERROR] IRegister: xwx does not exist");
		}
		
		public function get xwy():IRegister{
			if( m_components.length == 4 )
			{
				return new Register(m_val, m_id, m_index, _x+_w+_y);
			}
			throw new Error("[Y3D_ERROR] IRegister: xwy does not exist");
		}
		
		public function get xwz():IRegister{
			if( m_components.length == 4 )
			{
				return new Register(m_val, m_id, m_index, _x+_w+_z);
			}
			throw new Error("[Y3D_ERROR] IRegister: xwz does not exist");
		}
		
		public function get xww():IRegister{
			if( m_components.length == 4 )
			{
				return new Register(m_val, m_id, m_index, _x+_w+_w);
			}
			throw new Error("[Y3D_ERROR] IRegister: xww does not exist");
		
		}
		
		public function get yxx():IRegister{
			if( m_components.length >= 2 )
			{
				return new Register(m_val, m_id, m_index, _y+_x+_x);
			}
			throw new Error("[Y3D_ERROR] IRegister: yxx does not exist");
		}
		
		public function get yxy():IRegister{
			if( m_components.length >= 2 )
			{
				return new Register(m_val, m_id, m_index, _y+_x+_y);
			}
			throw new Error("[Y3D_ERROR] IRegister: yxy does not exist");
		}
		
		public function get yxz():IRegister{
			if( m_components.length >= 3 )
			{
				return new Register(m_val, m_id, m_index, _y+_x+_z);
			}
			throw new Error("[Y3D_ERROR] IRegister: yxz does not exist");
		}
		
		public function get yxw():IRegister{
			if( m_components.length == 4 )
			{
				return new Register(m_val, m_id, m_index, _y+_x+_w);
			}
			throw new Error("[Y3D_ERROR] IRegister: yxw does not exist");
		}
		
		public function get yyx():IRegister{
			if( m_components.length >= 2 )
			{
				return new Register(m_val, m_id, m_index, _y+_y+_x);
			}
			throw new Error("[Y3D_ERROR] IRegister: yyx does not exist");
		}
		
		public function get yyz():IRegister{
			if( m_components.length >= 3 )
			{
				return new Register(m_val, m_id, m_index, _y+_y+_z);
			}
			throw new Error("[Y3D_ERROR] IRegister: yyz does not exist");
		}
		
		public function get yyw():IRegister{
			if( m_components.length == 4 )
			{
				return new Register(m_val, m_id, m_index, _y+_y+_w);
			}
			throw new Error("[Y3D_ERROR] IRegister: yyw does not exist");
		}
		
		public function get yzx():IRegister{
			if( m_components.length >= 3 )
			{
				return new Register(m_val, m_id, m_index, _y+_z+_w);
			}
			throw new Error("[Y3D_ERROR] IRegister: yzx does not exist");
		}
		
		public function get yzy():IRegister{
			if( m_components.length >= 3 )
			{
				return new Register(m_val, m_id, m_index, _y+_z+_y);
			}
			throw new Error("[Y3D_ERROR] IRegister: yzy does not exist");
		}
		
		public function get yzz():IRegister{
			if( m_components.length >= 3 )
			{
				return new Register(m_val, m_id, m_index, _y+_z+_z);
			}
			throw new Error("[Y3D_ERROR] IRegister: yzz does not exist");
		}
		
		public function get yzw():IRegister{
			if( m_components.length == 4 )
			{
				return new Register(m_val, m_id, m_index, _y+_z+_w);
			}
			throw new Error("[Y3D_ERROR] IRegister: yzw does not exist");
		}
		
		public function get ywx():IRegister{
			if( m_components.length == 4 )
			{
				return new Register(m_val, m_id, m_index, _y+_w+_x);
			}
			throw new Error("[Y3D_ERROR] IRegister: ywx does not exist");
		}
		
		public function get ywy():IRegister{
			if( m_components.length == 4 )
			{
				return new Register(m_val, m_id, m_index, _y+_w+_y);
			}
			throw new Error("[Y3D_ERROR] IRegister: ywy does not exist");
		}
		
		public function get ywz():IRegister{
			if( m_components.length == 4 )
			{
				return new Register(m_val, m_id, m_index, _y+_w+_z);
			}
			throw new Error("[Y3D_ERROR] IRegister: ywz does not exist");
		}
		
		public function get yww():IRegister{
			if( m_components.length == 4 )
			{
				return new Register(m_val, m_id, m_index, _y+_w+_w);
			}
			throw new Error("[Y3D_ERROR] IRegister: yww does not exist");
		}
		
		public function get zxx():IRegister{
			if( m_components.length >= 3 )
			{
				return new Register(m_val, m_id, m_index, _z+_x+_x);
			}
			throw new Error("[Y3D_ERROR] IRegister: zxx does not exist");
		}
		
		public function get zxy():IRegister{
			if( m_components.length >= 3 )
			{
				return new Register(m_val, m_id, m_index, _z+_x+_y);
			}
			throw new Error("[Y3D_ERROR] IRegister: zxy does not exist");
		}
		
		public function get zxz():IRegister{
			if( m_components.length >= 3 )
			{
				return new Register(m_val, m_id, m_index, _z+_x+_z);
			}
			throw new Error("[Y3D_ERROR] IRegister: zxz does not exist");
		}
		
		public function get zxw():IRegister{
			if( m_components.length == 4 )
			{
				return new Register(m_val, m_id, m_index, _z+_x+_w);
			}
			throw new Error("[Y3D_ERROR] IRegister: zxw does not exist");
		}
		
		public function get zyx():IRegister{
			if( m_components.length >= 3 )
			{
				return new Register(m_val, m_id, m_index, _z+_y+_x);
			}
			throw new Error("[Y3D_ERROR] IRegister: zyx does not exist");
		}
		
		public function get zyy():IRegister{
			if( m_components.length >= 3 )
			{
				return new Register(m_val, m_id, m_index, _z+_y+_y);
			}
			throw new Error("[Y3D_ERROR] IRegister: zyy does not exist");
		}
		
		public function get zyz():IRegister{
			if( m_components.length >= 3 )
			{
				return new Register(m_val, m_id, m_index, _z+_y+_z);
			}
			throw new Error("[Y3D_ERROR] IRegister: zyz does not exist");
		}
		
		public function get zyw():IRegister{
			if( m_components.length == 4 )
			{
				return new Register(m_val, m_id, m_index, _z+_y+_w);
			}
			throw new Error("[Y3D_ERROR] IRegister: zyw does not exist");
		}
		
		public function get zzx():IRegister{
			if( m_components.length >= 3 )
			{
				return new Register(m_val, m_id, m_index, _z+_z+_x);
			}
			throw new Error("[Y3D_ERROR] IRegister: zzx does not exist");
		}
		
		public function get zzy():IRegister{
			if( m_components.length >= 3 )
			{
				return new Register(m_val, m_id, m_index, _z+_z+_y);
			}
			throw new Error("[Y3D_ERROR] IRegister: zzy does not exist");
		}
		
		public function get zzw():IRegister{
			if( m_components.length == 4 )
			{
				return new Register(m_val, m_id, m_index, _z+_z+_w);
			}
			throw new Error("[Y3D_ERROR] IRegister: zzw does not exist");
		}
		
		public function get zwx():IRegister{
			if( m_components.length == 4 )
			{
				return new Register(m_val, m_id, m_index, _z+_w+_x);
			}
			throw new Error("[Y3D_ERROR] IRegister: zwx does not exist");
		}
		
		public function get zwy():IRegister{
			if( m_components.length == 4 )
			{
				return new Register(m_val, m_id, m_index, _z+_w+_y);
			}
			throw new Error("[Y3D_ERROR] IRegister: zwy does not exist");
		}
		
		public function get zwz():IRegister{
			if( m_components.length == 4 )
			{
				return new Register(m_val, m_id, m_index, _z+_w+_z);
			}
			throw new Error("[Y3D_ERROR] IRegister: zwz does not exist");
		}
		
		public function get zww():IRegister{
			if( m_components.length == 4 )
			{
				return new Register(m_val, m_id, m_index, _z+_w+_w);
			}
			throw new Error("[Y3D_ERROR] IRegister: zww does not exist");
		}
		
		public function get wxx():IRegister{
			if( m_components.length == 4 )
			{
				return new Register(m_val, m_id, m_index, _w+_x+_x);
			}
			throw new Error("[Y3D_ERROR] IRegister: wxx does not exist");
		}
		
		public function get wxy():IRegister{
			if( m_components.length == 4 )
			{
				return new Register(m_val, m_id, m_index, _w+_x+_y);
			}
			throw new Error("[Y3D_ERROR] IRegister: wxy does not exist");
		}
		
		public function get wxz():IRegister{
			if( m_components.length == 4 )
			{
				return new Register(m_val, m_id, m_index, _w+_x+_z);
			}
			throw new Error("[Y3D_ERROR] IRegister: wxz does not exist");
		}
		
		public function get wxw():IRegister{
			if( m_components.length == 4 )
			{
				return new Register(m_val, m_id, m_index, _w+_x+_w);
			}
			throw new Error("[Y3D_ERROR] IRegister: wxw does not exist");
		}
		
		public function get wyx():IRegister{
			if( m_components.length == 4 )
			{
				return new Register(m_val, m_id, m_index, _w+_y+_x);
			}
			throw new Error("[Y3D_ERROR] IRegister: wyx does not exist");
		}
		
		public function get wyy():IRegister{
			if( m_components.length == 4 )
			{
				return new Register(m_val, m_id, m_index, _w+_y+_y);
			}
			throw new Error("[Y3D_ERROR] IRegister: wyy does not exist");
		}
		
		public function get wyz():IRegister{
			if( m_components.length == 4 )
			{
				return new Register(m_val, m_id, m_index, _w+_y+_z);
			}
			throw new Error("[Y3D_ERROR] IRegister: wyz does not exist");
		}
		
		public function get wyw():IRegister{
			if( m_components.length == 4 )
			{
				return new Register(m_val, m_id, m_index, _w+_y+_w);
			}
			throw new Error("[Y3D_ERROR] IRegister: wyw does not exist");
		}
		
		public function get wzx():IRegister{
			if( m_components.length == 4 )
			{
				return new Register(m_val, m_id, m_index, _w+_z+_x);
			}
			throw new Error("[Y3D_ERROR] IRegister: wzx does not exist");
		}
		
		public function get wzy():IRegister{
			if( m_components.length == 4 )
			{
				return new Register(m_val, m_id, m_index, _w+_z+_y);
			}
			throw new Error("[Y3D_ERROR] IRegister: wzy does not exist");
		}
		
		public function get wzz():IRegister{
			if( m_components.length == 4 )
			{
				return new Register(m_val, m_id, m_index, _w+_z+_z);
			}
			throw new Error("[Y3D_ERROR] IRegister: wzz does not exist");
		}
		
		public function get wzw():IRegister{
			if( m_components.length == 4 )
			{
				return new Register(m_val, m_id, m_index, _w+_z+_w);
			}
			throw new Error("[Y3D_ERROR] IRegister: wzw does not exist");
		}
		
		public function get wwx():IRegister{
			if( m_components.length == 4 )
			{
				return new Register(m_val, m_id, m_index, _w+_w+_x);
			}
			throw new Error("[Y3D_ERROR] IRegister: wwx does not exist");
		}
		
		public function get wwy():IRegister{
			if( m_components.length == 4 )
			{
				return new Register(m_val, m_id, m_index, _w+_w+_y);
			}
			throw new Error("[Y3D_ERROR] IRegister: wwy does not exist");
		}
		
		public function get wwz():IRegister{
			if( m_components.length == 4 )
			{
				return new Register(m_val, m_id, m_index, _w+_w+_z);
			}
			throw new Error("[Y3D_ERROR] IRegister: wwz does not exist");
		}
		
		public function get xyzw():IRegister{
			if( m_components.length == 4 )
			{
				return new Register(m_val, m_id, m_index, _x+_y+_z+w);
			}
			throw new Error("[Y3D_ERROR] IRegister: xyzw does not exist");
		}

		public function _( att:String ):IRegister{
			var comp:String="";
			for( var i:int = 0; i < att.length; i++ )
			{
				if( att.charAt(i) == "x" )
				{
					comp += m_components.substr(0,1);
				}else if( att.charAt(i) == "y" )
				{
					comp += m_components.substr(1,1);
				}else if( att.charAt(i) == "z" )
				{
					comp += m_components.substr(2,1);
				}else if( att.charAt(i) == "w" )
				{
					comp += m_components.substr(3,1);
				}
				
			}
			return new Register(m_val, m_id, m_index, comp );
		}	
	}
}