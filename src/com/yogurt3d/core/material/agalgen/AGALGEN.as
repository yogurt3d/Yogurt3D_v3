/*
* AGALGEN.as
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

package com.yogurt3d.core.material.agalgen
{
	import com.yogurt3d.core.material.enum.ERegisterType;
	
	import flash.utils.Dictionary;

	public class AGALGEN
	{
		private static const REGCOUNT				:uint 			= 128;
		
		private static const TEXCOUNT				:uint 			= 8;
		
		private static const FCOUNT					:uint			= 28;
						
		private var emptyVertexAttributes			:Array 			= [];
		
		private var emptyVertexVaryings				:Array 			= [];
		
		private var emptyVertexConstants			:Array 			= [];
				
		private var emptyFragConstants				:Array 			= [];
		
		private var emptyTextures					:Array 			= [];
		
		private var emptyFragTemps					:Array 			= [
																		["x","y","z","w"],
																		["x","y","z","w"],
																		["x","y","z","w"],
																		["x","y","z","w"],
																		["x","y","z","w"],
																		["x","y","z","w"],
																		["x","y","z","w"],
																		["x","y","z","w"]
																	];
		
		private var emptyVertexTemps				:Array 			= [
																		["x","y","z","w"],
																		["x","y","z","w"],
																		["x","y","z","w"],
																		["x","y","z","w"],
																		["x","y","z","w"],
																		["x","y","z","w"],
																		["x","y","z","w"],
																		["x","y","z","w"]
																	];
		
		private var m_tempFrag						:Dictionary;
		private var m_tempVert						:Dictionary;
		
		private var m_varying						:Dictionary;
		
		private var m_vertexConstant				:Dictionary;
		
		private var m_fragmentConstant				:Dictionary;
		
		private var m_VA							:Dictionary;
		
		private var m_textures						:Dictionary;
		
		private var m_debugMode						:Boolean = false;
		
		private var m_VALookUp						:Dictionary;
		
		public function AGALGEN(){
			
			m_tempFrag 				= new Dictionary();
			m_tempVert 				= new Dictionary();
			m_varying 				= new Dictionary();
			m_vertexConstant 		= new Dictionary();
			m_fragmentConstant 		= new Dictionary();
			m_textures 				= new Dictionary();
			m_VA 					= new Dictionary();
			
			m_VALookUp				= new Dictionary();
			
			for( var i:int = 0; i < TEXCOUNT; i++ )
				emptyTextures.push( new Register( ERegisterType.TEXTURE,"", i, "fs", true, false ) );
			
			for( i = 0; i < TEXCOUNT; i++ )
				emptyVertexAttributes.push( new Register( ERegisterType.VERTEX_ATTRIBUTE,"", i, "xyzw", true, false ) );
			
			for( i = 0; i < TEXCOUNT; i++ )
				emptyVertexVaryings.push( new Register( ERegisterType.VARYING,"", i, "xyzw", true, false ) );
					
			for( i = 0; i < FCOUNT; i++ )
				emptyFragConstants.push( new Register( ERegisterType.FRAGMENT_CONST,"", i, "xyzw", true, false ) );
			
			for( i = 0; i < REGCOUNT; i++ )
				emptyVertexConstants.push( new Register( ERegisterType.VERTEX_CONST,"", i, "xyzw", true, false ) );
			
			for( i = 0; i < TEXCOUNT; i++ )
				m_VALookUp[i] = null;
		
		}
		
		public function get VA():Dictionary{
			return m_VA;
		}
		
		public function get FT():Dictionary{
			return m_tempFrag;
		}
		
		public function get VT():Dictionary{
			return m_tempVert;
		}
		
		public function get V():Dictionary{
			return m_varying;
		}
		
		public function set V(value:Dictionary):void
		{
			m_varying = value;
		}
		
		public function get FC():Dictionary{
			return m_fragmentConstant;
		}
		
		public function get VC():Dictionary{
			return m_vertexConstant;
		}
		
		public function get FS():Dictionary{
			return m_textures;
		}
		
		/**************************************************************************
		 * Create fragment sample
		 **************************************************************************/
		public function createFS( _id:String ):IRegister{
			if( m_textures[_id] == null )
			{
				if( emptyTextures.length == 0 )
					throw new Error("[Y3D ERROR] AGALGEN@createFS: No more  texture registers left");
				m_textures[_id] = emptyTextures.shift();
				if(m_debugMode) trace("[Y3D WARNING] AGALGEN@createFS: ",_id, "is created...: FS", Register(m_textures[_id]).index, "Empty Textures:",emptyTextures.length);
			}
			else{
				//trace("[Y3D WARNING] AGALGEN@createFS: ",_id, "is same...: FS", Register(m_textures[_id]).index);
			}
			return m_textures[_id];
		}
		
		/**************************************************************************
		 * Destroy fragment sample
		 **************************************************************************/
		public function destroyFS( _id:String ):void{
			
			if(m_debugMode) trace("[Y3D WARNING] AGALGEN@destroyFS: ",_id, "will be destroyed...");
			
			if( m_textures[_id] != null )
			{
				emptyTextures.push( new Register( ERegisterType.TEXTURE,_id, m_textures[_id].index, "fs", true, false ) );
				delete m_textures[_id];
			}
		}
		
		/**************************************************************************
		 * Destroy all fragment samples
		 **************************************************************************/
		
		public function destroyAllFS():void{
			
			if(m_debugMode) trace("[Y3D WARNING] AGALGEN@destroyAllFS: all FS will be destroyed...");
			
			for (var key:String in m_textures) {
				destroyFS(key);
			}
		}
		
	
		/**************************************************************************
		 * Creates vertex attributes (Special Case)
		 **************************************************************************/
		
		private function findVAIndex():int{
			
			for (var key:String in m_VALookUp) {
				if(m_VALookUp[key] == null){
					return int(key);
				}
			}
			
			return -1;
		}
		
		public function createVA( _id:String):IRegister{
			if( m_VA[_id] != null )
				destroyVA(_id);
			if( m_VA[_id] == null )
			{
				var index:int = findVAIndex();
				
				if(index == -1)
					throw new Error("[Y3D ERROR] AGALGEN@createVA: No more varying registers left");
				
				m_VA[_id] = new Register( ERegisterType.VERTEX_ATTRIBUTE,_id, index, "xyzw", true, false );
				m_VALookUp[index] = m_VA[_id];
				
				if(m_debugMode) trace("[Y3D WARNING] AGALGEN@createVA: ",_id, "is created...: VA", m_VA[_id]);
					
			}else{
				//trace("[Y3D WARNING] AGALGEN@createVA: ",_id, "is same...: VA", Register(m_VA[_id]).index);
			}
			return m_VA[_id];
		}
		
		/**************************************************************************
		 * Destroy Vertex attribute
		 **************************************************************************/
		public function destroyVA( _id:String ):void{
			
			if(m_debugMode) trace("[Y3D WARNING] AGALGEN@destroyVA: ",_id, "will be destroyed...");
			
			if( m_VA[_id] != null )
			{
				m_VALookUp[m_VA[_id].index] = null;
				//emptyVertexAttributes.push( new Register( ERegisterType.VERTEX_ATTRIBUTE, m_VA[_id].index, "xyzw", true, false ) );
				delete m_VA[_id];
			}
			
		}
		
		/**************************************************************************
		 * Destroy all Vertex attributes
		 **************************************************************************/
		public function destroyAllVA():void{
			if(m_debugMode) trace("[Y3D WARNING] AGALGEN@destroyAllVA: all VA will be destroyed...");
			
			for (var key:String in m_VA) {
				destroyVA(key);
			}
		}
						
		/**************************************************************************
		 * Creates vertex varying V (vertex output for fragment shader)
		 **************************************************************************/
		public function createV( _id:String ):IRegister{
			if( m_varying[_id] == null )
			{
				if( emptyVertexVaryings.length == 0 )
					throw new Error("[Y3D ERROR] AGALGEN@createV: No more varying registers left");
				
				m_varying[_id] = emptyVertexVaryings.shift();
				
				if(m_debugMode) trace("[Y3D WARNING] AGALGEN@createV: ",_id, "is created...: V",m_varying[_id], "Empty V:",emptyVertexVaryings.length);
			}else{
				//trace("[Y3D WARNING] AGALGEN@createV: ",_id, "is same...: V", Register(m_varying[_id]).index);
			}
			return m_varying[_id];
		}
		
		
		/**************************************************************************
		 * Destroy vertex varying V (vertex output for fragment shader)
		 **************************************************************************/
		public function destroyV( _id:String ):void{
			
			if(m_debugMode) trace("[Y3D WARNING] AGALGEN@destroyV: ",_id, "will be destroyed...");
			
			if( m_varying[_id] != null )
			{
				emptyVertexVaryings.push( new Register( ERegisterType.VARYING,"", m_varying[_id].index, "xyzw", true, false ) );
				delete m_varying[_id];
			}
		}
		
		/**************************************************************************
		 * Destroy all vertex varying V (vertex output for fragment shader)
		 **************************************************************************/
		public function destroyAllV():void{
			if(m_debugMode) trace("[Y3D WARNING] AGALGEN@destroyAllV: all V will be destroyed...");
			
			for (var key:String in m_varying) {
				destroyV(key);
			}
		}
		
		/**************************************************************************
		 * Creates fragment constant FC
		 **************************************************************************/
		public function createFC( _id:String, _size:uint = 1 ):IRegister{
			if( m_fragmentConstant[_id] == null )
			{
				if( emptyFragConstants.length == 0 )
					throw new Error("[Y3D ERROR] AGALGEN@createFC: No more constant registers left");
				
				m_fragmentConstant[_id] = emptyFragConstants.shift();
				
				for(var i:uint = 0; i < _size-1; i++){
					emptyFragConstants.shift();
				}
				
			//	trace("[Y3D WARNING] AGALGEN@createFC: ",_id, "is created...: FC", m_fragmentConstant[_id], "Empty FC:", emptyFragConstants.length);
			}else{
				//trace("[Y3D WARNING] AGALGEN@createFC: ",_id, "is same...: FC", Register(m_fragmentConstant[_id]).index);
			}
			return m_fragmentConstant[_id];
		}
		
		/**************************************************************************
		 * Destroy fragment constant FC
		 **************************************************************************/
	
		public function destroyFC(_id:String , _size:uint=1):void{
			if(m_debugMode) trace("[Y3D WARNING] AGALGEN@destroyFC: ",_id, "will be destroyed...");
			
			if( m_fragmentConstant[_id] != null ){
				emptyFragConstants.push( new Register( ERegisterType.FRAGMENT_CONST,"", m_fragmentConstant[_id].index, "xyzw", true, false ) );
				
				for(var i:uint = m_fragmentConstant[_id].index; i < _size-1; i++){
					emptyFragConstants.push( new Register( ERegisterType.FRAGMENT_CONST,"", i+1, "xyzw", true, false ) );
				}
				
				delete m_fragmentConstant[_id];
			}
		
		}
		
		/**************************************************************************
		 * Destroy all fragment constant FC
		 **************************************************************************/
		public function destroyAllFC():void{
			
			if(m_debugMode) trace("[Y3D WARNING] AGALGEN@destroyAllFC: all FC will be destroyed...");
			
			for (var key:String in m_fragmentConstant) {
				delete m_fragmentConstant[key];
			}
		
			for(var i:uint = 0; i < FCOUNT; i++){
				emptyFragConstants.push( new Register( ERegisterType.FRAGMENT_CONST,"", i, "xyzw", true, false ) );
			}
		
		}
		
		/**************************************************************************
		 * Creates vertex constant VC
		 **************************************************************************/
		public function createVC( _id:String, _size:int ):IRegister{
			if( m_vertexConstant[_id] == null )
			{
				if( emptyVertexConstants.length == 0 )
					throw new Error("[Y3D ERROR] AGALGEN@createVC: No more constant registers left");
				
				m_vertexConstant[_id] = emptyVertexConstants.shift();
				
				if(m_debugMode) trace("[Y3D WARNING] AGALGEN@createVC: ", _id, "is created...: VC",m_vertexConstant[_id], "Empty VC:",emptyVertexConstants.length);
				
				for(var i:uint = 0; i < _size-1; i++){
					emptyVertexConstants.shift();
				}
				
			}else{
				//trace("[Y3D WARNING] AGALGEN@createVC: ",_id, "is same...: VC", Register(m_vertexConstant[_id]).index);
			}
			m_vertexConstant[_id].id = _id;
			return m_vertexConstant[_id];
		}
		
		/**************************************************************************
		 * Destroy vertex constant VC
		 **************************************************************************/
		public function destroyVC( _id:String, _size:uint=1 ):void{
			if(m_debugMode) trace("[Y3D WARNING] AGALGEN@destroyVC: ",_id, "will be destroyed...");
			
			if( m_vertexConstant[_id] != null ){
				emptyVertexConstants.push( new Register( ERegisterType.VERTEX_CONST, "", m_vertexConstant[_id].index, "xyzw", true, false ) );
				
				for(var i:uint = m_vertexConstant[_id].index; i < _size-1; i++){
					emptyVertexConstants.push( new Register( ERegisterType.VERTEX_CONST, "", i+1, "xyzw", true, false ) );
				}
				
				delete m_vertexConstant[_id];
			}
		}
		
		/**************************************************************************
		 * Destroy  all vertex constant VC
		 **************************************************************************/
		public function destroyAllVC():void{
			
			if(m_debugMode) trace("[Y3D WARNING] AGALGEN@destroyAllVC: all VC will be destroyed...");
			
			for (var key:String in m_vertexConstant) {
				delete m_vertexConstant[key];
			}
			
			for(var i:uint = 0; i < REGCOUNT; i++){
				emptyVertexConstants.push( new Register( ERegisterType.VERTEX_CONST, "", i, "xyzw", true, false ) );
			}
			
		}
		
		/**************************************************************************
		 * Creates temp fragment register FT
		 **************************************************************************/
		public function createFT( _id:String, _size:uint):IRegister{
			if(m_tempFrag[ _id ]){
				//trace("[Y3D WARNING] AGALGEN@createFT: ",_id, "is same...: FT", Register(m_temp[_id]).index);
				return m_tempFrag[ _id ];
			}
				
			for( var i:int = 0; i < emptyFragTemps.length; i++ )
			{
				if( _size <= emptyFragTemps[i].length )
				{
					var ext:String = "";
					for( var s:uint = 0; s < _size; s++ )
					{
						ext += emptyFragTemps[i].shift();
					}
				
					m_tempFrag[ _id ] = new Register( ERegisterType.FRAGMENT_TEMP, _id, i, ext );
					
					if(m_debugMode) trace("[Y3D WARNING] AGALGEN@createFT: ",_id, "is created...: FT",m_tempFrag[_id]);
					return m_tempFrag[ _id ];
				}
			}	
			return null;
		}
		
		/**************************************************************************
		 * Creates temp vertex register VT
		 **************************************************************************/
		public function createVT( _id:String, _size:uint):IRegister{
			if(m_tempVert[ _id ]){
			//	trace("[Y3D WARNING] AGALGEN@createVT: ",_id, "is same...: VT", Register(m_tempVert[_id]).index);
				return m_tempVert[ _id ];
			}
			for( var i:int = 0; i < emptyVertexTemps.length; i++ )
			{
				if( _size <= emptyVertexTemps[i].length )
				{
					var ext:String = "";
					for( var s:uint = 0; s < _size; s++ )
					{
						ext += emptyVertexTemps[i].shift();
					}

					m_tempVert[ _id ] = new Register( ERegisterType.VERTEX_TEMP, _id, i, ext );
//					if(m_debugMode)
			//		trace("[Y3D WARNING] AGALGEN@createVT: ",_id, "is created...: VT", m_tempVert[_id]);
					return m_tempVert[ _id ];
				}
			}	
		//	trace("[Y3D WARNING] AGALGEN@createVT: ",_id, "is not created...: VT",emptyVertexTemps.length);
			return null;
		}
		
		/**************************************************************************
		 * Destroy temp registers VT and FT
		 **************************************************************************/
		
		public function destroyAllTmp():void{
			
			for (var key:String in emptyVertexTemps) 
				destroyVT(key);
			
			for (key in emptyFragTemps) 
				destroyFT(key);

		}
		
		public function destroyTmpExcept(... args ):void{
			var check:Boolean = false;
			for (var key:String in m_tempFrag) {
				
				for (var i:uint = 0; i < args.length; i++) 
				{ 
					if(key == args[i])
						check = true;		
				} 
				if(!check){
					//trace("[Y3D WARNING] AGALGEN@destroyTempExcept: ", key);
					destroyFT(key);
				}
				
				check = false;
			}
			
			check = false;
			
			for (key in m_tempVert) {
				
				for (i = 0; i < args.length; i++) 
				{ 
					if(key == args[i])
						check = true;		
				} 
				if(!check){
					//trace("[Y3D WARNING] AGALGEN@destroyTempExcept: ", key);
					destroyVT(key);
				}
				
				check = false;
			}
		}
			
		public function destroyVT( _id:String ):String{
			if(m_debugMode) trace("[Y3D WARNING] AGALGEN@destroyTemp: ",_id, "will be destroyed...");
			if( m_tempVert[ _id ] != null )
			{
				var reg:Register = m_tempVert[_id];
				var len:uint = reg.components.length;
				for( var i:int = 0; i < len; i++ )
				{
					emptyVertexTemps[reg.index].push( reg.components.charAt(i) );
				}
				emptyVertexTemps[reg.index].sort( function( str1:String, str2:String ):int {
					var w1:int = str1=="x"?0:(str1=="y"?1:(str1=="z"?2:3))
					var w2:int = str2=="x"?0:(str2=="y"?1:(str2=="z"?2:3))
					if( w1 < w2 )
					{
						return -1;
					}else {
						return 1;
					}
				});
				delete m_tempVert[_id];
			}
			return "";
		}
		
		public function destroyFT( _id:String ):String{
			if(m_debugMode) trace("[Y3D WARNING] AGALGEN@destroyTemp: ",_id, "will be destroyed...");
			if( m_tempFrag[ _id ] != null )
			{
				var reg:Register = m_tempFrag[_id];
				var len:uint = reg.components.length;
				for( var i:int = 0; i < len; i++ )
				{
					emptyFragTemps[reg.index].push( reg.components.charAt(i) );
				}
				emptyFragTemps[reg.index].sort( function( str1:String, str2:String ):int {
					var w1:int = str1=="x"?0:(str1=="y"?1:(str1=="z"?2:3))
					var w2:int = str2=="x"?0:(str2=="y"?1:(str2=="z"?2:3))
					if( w1 < w2 )
					{
						return -1;
					}else {
						return 1;
					}
				});
				delete m_tempFrag[_id];
			}
			return "";
		}
		
		public function destroy():void{
			destroyAllFC();
			destroyAllFS();
			destroyAllTmp();
			destroyAllV();
			destroyAllVA();
			destroyAllVC();
		}
		
		/***************************************************************************************
		 * 
		 * Generating CODE
		 * 
		 ***************************************************************************************/
		
		public function printCode(_code:String):String{
			var result:String = "0 ";
			var lineNum:uint = 1;
			
			for(var i:uint = 0; i < _code.length; i++){
				
				if(_code.charAt(i) == '\n' && (i+1) < _code.length){
					result = result.concat(_code.charAt(i)+""+lineNum+" ");
					lineNum++;
				}else
					result = result.concat(_code.charAt(i));
			}
			
			return result;
		}
		
		/****************************************************************************************
		 * Creates AGAL code
		 * opcode: add, mul, div, m33 etc..
		 * target: target register that holds result
		 * op1: operator 1 of the desired function
		 * op2: operator 2 of the desired function
		 ****************************************************************************************/
		public function code(_opCode:String, _targetReg:*, _op1Reg:*=null, _op2Reg:*=null):String{
			var _target:String, _op1:String, _op2:String;
			
			if(_targetReg is IRegister)
				_target = _targetReg.toString();
			else if(_targetReg)
				_target = _targetReg;
			
			if(_op1Reg && _op1Reg is IRegister)
				_op1 = _op1Reg.toString();
			else if(_op1Reg)
				_op1 = _op1Reg;
			
			if(_op2Reg && _op2Reg is IRegister)
				_op2 = _op2Reg.toString();
			else if(_op2Reg)
				_op2 = _op2Reg;
			
			if(_op1 && _op2)
				return _opCode+" "+_target+" "+_op1+" "+_op2;
			else if(_op1)
				return _opCode+" "+_target+" "+_op1;
			
			return _opCode+" "+_target;
		}
		
		
		/**************************************************************************
		 * Creates texture code
		 **************************************************************************/
		public function tex(_targetReg:*,_uvReg:*, _sampler:*,  _name:String="2d", _flag:String="wrap",
							_mask:String="linear", 
							_mipMap:Boolean=false, 
							_checkTransParent:Boolean=false, 
							_isTransparent:Boolean=false, _alphaApp:String=null) :String{
			var _target:String, _samp:String, _uv:String;
			
			if(_targetReg is IRegister)
				_target = _targetReg.toString();
			else if(_targetReg)
				_target = _targetReg;
			
			if(_sampler && _sampler is IRegister)
				_samp = _sampler.toString();
			else if(_sampler)
				_samp = _sampler;
			
			if(_uvReg && _uvReg is IRegister)
				_uv = _uvReg.toString();
			else if(_sampler)
				_uv = _uvReg;
			
			
			var _tmp:String;
			if(!_mipMap)
				_tmp = "tex "+_target+" "+_uv+" "+_samp+"<"+_name+","+_flag+","+_mask+">";
			else
				_tmp = "tex "+_target+" "+_uv+" "+_samp+"<"+_name+","+_flag+","+_mask+",miplinear>";
			
			if(!_checkTransParent || !_isTransparent)
				return _tmp;
				
			
			var tReg:IRegister = this.createFT("alpTest",1);
			
			_tmp = [
				_tmp,
				code("sub", tReg, _targetReg.w, _alphaApp),
				code("kill",tReg)
			].join("\n");
			
			this.destroyFT("alpTest");
			return _tmp;
		}
		
		/**************************************************************************
		 *	COMPARISION FUNCTIONS
		 **************************************************************************/
		
		/**************************************************************************
		 *	ifEqual: returns 1 if source1 == source2, otherwise 0
		 ***************************************************************************/
		public function ifEqual(_target:*, _source1:*, _source2:*, _temp:*):String{
			
			var result:String = [
				code("sge", _target, _source1, _source2),
				code("sge",_temp, _source2, _source1),
				code("min",_target, _target, _temp),
				
			].join("\n");
			
			return result;
		}
		
		/**************************************************************************
		 *	ifNotEqual: returns 1 if source1 != source2, otherwise 0
		 ***************************************************************************/
		public function ifNotEqual(_target:*, _source1:*, _source2:*, _temp:*):String{
			
			var result:String = [
				code("slt", _target, _source1, _source2),
				code("slt",_temp, _source2, _source1),
				code("max",_target, _target, _temp),
				
			].join("\n");
			
			return result;
		}
		
		/**************************************************************************
		 *	lessThan: returns 1 if source1 < source2, otherwise 0
		 ***************************************************************************/
		public function lessThan(_target:*, _source1:*, _source2:*):String{
			var result:String = [
				code("slt", _target, _source1, _source2),
			].join("\n");
			
			return result;
		}
		
		/**************************************************************************
		 *	greaterEqual: returns 1 if source1 >= source2, otherwise 0
		 ***************************************************************************/
		public function greaterEqual(_target:*, _source1:*, _source2:*):String{
			var result:String = [
				code("sge", _target, _source1, _source2),
			].join("\n");
			
			return result;
		}
		
		/**************************************************************************
		 *	lessEqual: returns 1 if source1 <= source2, otherwise 0
		 ***************************************************************************/
		public function lessEqual(_target:*, _source1:*, _source2:*, _temp:*):String{
			var result:String = [
				ifEqual(_target, _source1, _source2, _temp),
				lessThan(_temp, _source1, _source2),
				code("max",_target, _target, _temp)
			].join("\n");
			
			return result;
		}
		
		/**************************************************************************
		 *	greaterThan: returns 1 if source1 > source2, otherwise 0
		 ***************************************************************************/
		public function greaterThan(_target:*, _source1:*, _source2:*, _temp:*):String{
			var result:String = [
				ifNotEqual(_target, _source1, _source2, _temp),
				greaterEqual(_temp, _source1, _source2),
				code("min",_target, _target, _temp)
			].join("\n");
			
			return result;
		}
		
		/**************************************************************************
		 *	GLSL FUNCTIONS
		 **************************************************************************/
		
		/**************************************************************************
		 *	GLSL: CLAMP function min(max(x, minVal), maxVal)
		 ***************************************************************************/
		public function clamp(_target:*, _x:*, _minVal:*, _maxVal:*):String{
			var result:String = [
				code("max",_target,_x, _minVal),// max(x, minVal)
				code("min",_target,_target,_maxVal)// min(max(x, minVal), maxVal)
			].join("\n");
			
			return result;
		}
		
		/**************************************************************************
		 *	GLSL: SMOOTHSTEP function
		 *  t = clamp((x - edge0)/(edge1 - edge0), 0, 1)
		 *  return t * t * (3 - 2*t)
		 ***************************************************************************/
		public function smoothstep(_target:*, _temp:*, _min:*, _max:*, _x:*, _two:*, _three:*):String{
			var result:String = [
				
				code("sub", _target, _max, _min),		// (edge1 - edge0)
				code("sub", _temp, _x, _min),			//(x - edge0)
				code("div", _target, _temp, _target),	// (x - edge0)/ (edge1 - edge0)
				code("sat", _target, _target),
				
				code("mul",_temp, _two, _target),
				code("sub",_temp, _three, _temp),
				
				code("mul",_target, _target, _target),
				code("mul",_target, _target, _temp)
				
			].join("\n");
			
			return result;
		}
		
		/**************************************************************************
		 *	GLSL: LENGTH function 
		 **************************************************************************/
		public function length(_target:*, _source:*):String{
			var result:String = [
				code("dp3",_target,_source, _source),
				code("sqt",_target,_target)
			].join("\n");
			return result;
		}
		
		/**************************************************************************
		 *	GLSL: DISTANCE function 
		 **************************************************************************/
		public function distance(_target:*, _temp:*, _vec1:*, _vec2:*):String{
			var result:String = [
				code("sub",_temp,_vec1, _vec2),
				length(_target, _temp)
			].join("\n");
			
			return result;
		}
		
		/**************************************************************************
		 *	GLSL: REFLECT FUNC : I – 2 * dot(N, I) * N
		 **************************************************************************/
		public function reflect(_target:*, _incidence:*, _normal:*):String{
			var result:String = [
				code("dp3",_target,_normal, _incidence),		// dot(N, I) 
				code("add",_target,_target,_target),			// 2 * dot(N, I) 
				code("mul",_target, _target, _normal),			// 2 * dot(N, I) * N
				code("sub",_target,_incidence,_target)			// I – 2 * dot(N, I) * N
				
			].join("\n");
			return result;
		}
		
		/**************************************************************************
		 *	GLSL: REFLECT FUNC vers2: 2 * dot(N, L) * N - L
		 **************************************************************************/
		public function reflectionVector(_target:*, _normal:*, _light:*):String{
			var result:String = [
				code("dp3",_target.x,_normal, _light),			// dot(V, N) 
				code("add",_target.x,_target.x,_target.x),		// 2 * dot(V, N) 
				code("mul",_target, _target.x, _normal),		// 2 * dot(N, N) * N
				code("sub",_target, _target, _light)			// 2 * dot(N, V) * N - V
				
			].join("\n");
			return result;
		}
		
		/**************************************************************************
		 *	GLSL: MIX FUNC : x*(1 - a) + y*a
		 **************************************************************************/
		public function mix(_target:*,_temp:*, _x:*, _y:*, _a:*,_oneMina:*):String{	
			var result:String = [
				code("mul",_target, _x, _oneMina),//x*(1 - a)
				code("mul",_temp, _y, _a),//y*a
				code("add",_target, _target, _temp)////x*(1 - a) + y*a
				
			].join("\n");
			return result;
		}
		
		/**************************************************************************
		 *	GLSL: STEP FUNC : returns 0.0 if x<edge else 1.0 
		 **************************************************************************/
		public function step(_target:*, _edge:*, _x:*):String{
			return greaterEqual(_target, _x, _edge);
		}
		
		/*******************************************************************************
		 * Refract Function: incidence, normal, eta
		 * parameters(vec3 i, vec3 n, float eta)
		 * float cosi = dot(-i, n);
		 * float cost2 = 1.0 - eta * eta * (1.0 - cosi*cosi);
		 * vec3 t = eta*i + ((eta*cosi - sqrt(abs(cost2))) * n);
		 * return t * vec3(cost2 > 0.0);
		 *******************************************************************************/
		public function refract(_target:*, _incidence:*, _normal:*, _eta:*,	_one:String, _zero:*, _temp:*, _temp2:*):String{
			
			var result:String = [
				code("neg", _incidence, _incidence+".xyz"), 		// i = -i
				code("dp3", _target, _incidence, _normal),			//cosi = dot(-i, n)
				
				code("mul", _temp, _target, _target),				// cosi * cosi
				code("sub", _temp, _one, _temp),					// 1.0 - cosi*cosi
				code("mul", _temp, _temp, _eta),					//(1.0 - cosi*cosi)*eta
				code("mul", _temp, _temp, _eta),					//(1.0 - cosi*cosi)*eta*eta
				code("sub", _temp, _one, _temp),					//cost2 = 1.0 - eta * eta * (1.0 - cosi*cosi);
				
				code("neg", _incidence, _incidence+".xyz"), 		// -i = i
				code("mul", _target, _target, _eta),				//eta*cosi
				
				code("abs", _temp2, _temp),							//abs(cost2)
				code("sqt", _temp2, _temp2),						//sqrt(abs(cost2)
				code("sub", _temp2, _target, _temp2),				//(eta*cosi - sqrt(abs(cost2))
				code("mul", _temp2, _temp2, _normal), 				//((eta*cosi - sqrt(abs(cost2))) * n)
				
				code("mul", _target, _eta, _incidence),				//eta*i 
				code("add", _target, _target, _temp2),				// t = eta*i + ((eta*cosi - sqrt(abs(cost2))) * n); 
				
				code("sge", _temp, _temp, _zero),					// if cost2 > 0 temp = 0 else 1
				code("mul", _target, _target, _temp)
				
			].join("\n");
			return result;
		}
		
		
		/**************************************************************************
		 *	USEFUL FUNCTIONS
		 **************************************************************************/
		
		public function one(_target:*, _dest:*):String{
			
			return greaterEqual(_target, _dest, _dest);
		}
		
		public function zero(_target:*, _dest:*):String{
			
			return code("sub", _target, _dest, _dest);
		}
		
		public function two(_target:*, _dest:*):String{
			var result:String = [
				one(_target, _dest),
				code("add", _target, _target, _target),
				
			].join("\n");
			
			return result;
		}
		
		public function minusOne(_target:*, _dest:*):String{
			var result:String = [
				one(_target+".x", _dest),
				zero(_target+".y", _dest),
				code("sub", _target, _target+".y", _target+".x"),
				
			].join("\n");
			
			return result;
		}
		
		/**************************************************************************
		 *	UNSUPPORTED MOLEHILL  FUNCTIONS
		 **************************************************************************/
		
		/**************************************************************************
		 *	SIGN FUNC : returns 1.0 if x>0, 0.0 if x=0, -1.0 if x<0
		 *  target should be vec4
		 *  returns result in target.x
		 **************************************************************************/
		public function signAGAL(_target:*, _source:*,_minusOne:*):String{
			var result:String = [
				zero(_target+".x", _source),
				greaterThan(_target+".y", _source, _target+".x", _target+".w"),
				lessThan(_target+".z", _source, _target+".x"),
				code("mul", _target+".z", _target+".z", _minusOne),
				code("add", _target+".x", _target+".y", _target+".z")
				
			].join("\n");
			
			return result;	
		}
		
		/**************************************************************************
		 *	FLOOR AGAL FUNC : a - b*floor(a/b)
		 **************************************************************************/
		public function floorAGAL(_target:*, _source:*):String{
			
			var result:String = [
				code("frc",_target,_source),				// z = source - floor(source)
				code("sub",_target,_source,_target)			//floor(source) = source + z
			].join("\n");
			
			return result;
		}
		
		/**************************************************************************
		 *	MOD FUNC : a - b*floor(a/b)
		 **************************************************************************/
		public function modAGAL(_target:*, _temp:*,_a:*, _b:*):String{
			
			var result:String = [
				code("div",_temp,_a, _b),				// a/b
				floorAGAL(_target, _temp),				//floor(a/b)
				code("mul",_target,_target, _b),		//b*floor(a/b)
				code("sub",_target,_a, _target)			//a - floor(a/b)
			].join("\n");
			
			return result;
		}
		
		/**************************************************************************
		 *	EXTRA FUNCTIONS
		 **************************************************************************/
		/****************************************************************************
		 * Fresnel Approximation
		 * F(a) = F(0) + (1- cos(a))^5 * (1- F(0))	
		 *
		 *		float fast_fresnel(vec3 I, vec3 N, vec3 fresnelValues)
		 *		{
		 *			float bias = fresnelValues.x;
		 *			float power = fresnelValues.y;
		 *			float scale = 1.0 - bias;
		 *			
		 *			return bias + pow(1.0 - dot(I, N), power) * scale;
		 *		}
		 ******************************************************************************/
		
		public function fastFresnel(_target:*, _normal:*, _incidence:*, _fresnelValues:*, _one:*, _temp:*):String{
			
			var result:String = [
				code("dp3",_temp, _incidence, _normal), 					//dot(I, N)
				code("sub", _temp, _one, _temp),							//1.0 - dot(I, N)
				code("pow", _temp, _temp, _fresnelValues+".y"),				//pow(1.0 - dot(I, N), fresnelValues.y)
				
				code("mov",_target, _fresnelValues+".x"),
				code("sub", _target, _one, _target),						// scale = 1.0 - fresnelValues.x;
				code("mul", _target, _target, _temp),						//pow(1.0 - dot(I, N), power) * scale
				code("add", _target, _target, _fresnelValues+".x")			// fresnelValues.x + pow(1.0 - dot(I, N), fresnelValues.y) * scale
			].join("\n");
			return result;
		}
		
		public  function fresnel(_target:*, _normal:*, _incidence:*, _power:*, _one:*):String{
			
			var result:String = [
				code("dp3",_target, _incidence, _normal), //dot(I, N)
				code("sub",_target, _one, _target),//1.0 - dot(I, N)
				code("pow",_target, _target, _power),//pow(1.0 - dot(I, N), power)	
			].join("\n");
			
			return result;
			
		}
		
	}
}
