package com.yogurt3d.presets.material.yogurtistanv2
{
	import com.yogurt3d.core.agalgen.IRegister;
	import com.yogurt3d.core.cameras.Camera3D;
	import com.yogurt3d.core.geoms.SubMesh;
	import com.yogurt3d.core.geoms.interfaces.IMesh;
	import com.yogurt3d.core.lights.Light;
	import com.yogurt3d.core.material.Y3DProgram;
	import com.yogurt3d.core.material.enum.EBlendMode;
	import com.yogurt3d.core.material.enum.ERegisterShaderType;
	import com.yogurt3d.core.material.parameters.FragmentInput;
	import com.yogurt3d.core.material.parameters.VertexInput;
	import com.yogurt3d.core.material.parameters.VertexOutput;
	import com.yogurt3d.core.material.pass.Pass;
	import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;
	import com.yogurt3d.core.sceneobjects.SceneObjectRenderable;
	import com.yogurt3d.core.texture.CubeTextureMap;
	import com.yogurt3d.core.texture.TextureMap;
	import com.yogurt3d.core.utils.Color;
	import com.yogurt3d.core.utils.ShaderUtils;
	import com.yogurt3d.core.utils.TextureMapDefaults;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTriangleFace;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;

	public class YogurtistanPassLocationV2 extends Pass
	{
		private var m_gradient				:TextureMap;
		private var m_lightMap				:TextureMap;
		private var m_colorMap				:TextureMap;
		private var m_emmisiveMask			:TextureMap;
		private var m_specularMap			:TextureMap;
		private var m_reflectionMap			:CubeTextureMap;
		
		private var m_emmisiveAlpha			:Number;
		private var m_specColor				:Color;
		private var m_ambientUpColor		:Color;
		private var m_ambientDownColor		:Color;
		private var m_blendConstant			:Number;
		private var m_opacity				:Number;
		private var m_specular				:Number;
		private var m_shineness				:Number;
		private var m_reflectionAlpha		:Number;
		private var m_fresnelReflectance	:Number;
		private var m_fresnelPower			:Number;
		
		public function YogurtistanPassLocationV2(  _gradient:TextureMap,
													_ambientUpColor:Color,
													_ambientDownColor:Color,
													_lightMap:TextureMap=null,
													_colorMap:TextureMap=null,
													_specularMap:TextureMap=null,
													_emmisiveMask:TextureMap=null,
													_reflectionMap:CubeTextureMap=null,
													_specularColor:Color=null,
													_specular:Number=0.0,
													_blendConstant:Number=1.0,
													_shineness:Number=1.0,
													_fresnelReflectance:Number=0.028,
													_fresnelPower:Number=5,
													_opacity:Number=1.0,
													_emmisiveAlpha:Number=1.0,
													_refAlpha:Number=0.0)
													
		{
			m_surfaceParams.blendEnabled = true;
			m_surfaceParams.blendMode = EBlendMode.ALPHA;
			
			m_surfaceParams.writeDepth = true;
			m_surfaceParams.depthFunction = Context3DCompareMode.LESS;
			m_surfaceParams.culling = Context3DTriangleFace.FRONT;
	
			if(_specularColor == null)
				m_specColor = new Color(1,1,1,1);
			
			m_ambientUpColor = _ambientUpColor;
			m_ambientDownColor = _ambientDownColor;
			
			m_emmisiveAlpha = _emmisiveAlpha;
			m_blendConstant = _blendConstant;
			m_opacity = _opacity;
			m_specular = _specular;
			m_shineness = _shineness;
			m_reflectionAlpha = _refAlpha;
			m_fresnelReflectance = _fresnelReflectance;
			m_fresnelPower = _fresnelPower;
				
			m_gradient = _gradient;
			m_colorMap = (_colorMap)?_colorMap:TextureMapDefaults.WHITEMIPMAP;
			m_specularMap = (_specularMap)?_specularMap:TextureMapDefaults.BLACKMIPMAP;
			m_emmisiveMask = (_emmisiveMask)?_emmisiveMask:TextureMapDefaults.BLACK;
			m_lightMap = (_lightMap)?_lightMap:TextureMapDefaults.WHITE;
			m_reflectionMap = (_reflectionMap)?_reflectionMap:TextureMapDefaults.BLACKCUBEMAP;
			
			if(m_specularMap != TextureMapDefaults.BLACKMIPMAP)
				m_specular = 0.0;
						
			createConstantFromVector( ERegisterShaderType.FRAGMENT, "constant1", Vector.<Number>([ 0.0, 0.5, 1.0, -1 ]));
			createConstantFromVector( ERegisterShaderType.FRAGMENT, "constant2", Vector.<Number>([ m_blendConstant, m_emmisiveAlpha, 0.3, m_fresnelReflectance ]));
			createConstantFromVector( ERegisterShaderType.FRAGMENT, "constant3", Vector.<Number>([ m_shineness, m_specColor.r, m_specColor.g, m_specColor.b ]));
			createConstantFromVector( ERegisterShaderType.FRAGMENT, "constant4", Vector.<Number>([ m_specular,0.00000001, m_fresnelPower, (1-m_fresnelReflectance) ]));
			createConstantFromVector( ERegisterShaderType.FRAGMENT, "constant5", Vector.<Number>([ m_reflectionAlpha, m_ambientUpColor.r, m_ambientUpColor.g, m_ambientUpColor.b ]));
			createConstantFromVector( ERegisterShaderType.FRAGMENT, "constant6", Vector.<Number>([ m_ambientDownColor.r, m_ambientDownColor.g, m_ambientDownColor.b, m_opacity ]))
			
			createConstantFromTexture(ERegisterShaderType.FRAGMENT, "gradient", m_gradient );
			createConstantFromTexture(ERegisterShaderType.FRAGMENT, "colorMap", m_colorMap );
			createConstantFromTexture(ERegisterShaderType.FRAGMENT, "sMap", m_specularMap);
			createConstantFromTexture(ERegisterShaderType.FRAGMENT, "emmisiveMask", m_emmisiveMask);
			createConstantFromTexture(ERegisterShaderType.FRAGMENT, "lightMap", m_lightMap);
			createConstantFromTexture(ERegisterShaderType.FRAGMENT, "refMap", m_reflectionMap);
			
			//cameraPosition
			createConstantFromVectorFunction(ERegisterShaderType.FRAGMENT, 
				"cameraPos", function():Vector.<Number>{
					var pos:Vector3D = m_currentCamera.transformation.matrixGlobal.position;
					return Vector.<Number>([ pos.x,pos.y,pos.z,1]);
				});
			
			//lightDir
			createConstantFromVectorFunction(ERegisterShaderType.FRAGMENT, 
				"lightDir", function():Vector.<Number>{
					return m_currentLight.directionVector;
				});
			
			//lightColor
			createConstantFromVectorFunction(ERegisterShaderType.FRAGMENT, 
				"lightColor", function():Vector.<Number>{
					return m_currentLight.color.getColorVectorRaw();
				});
		}
		
		public override function uploadConstants(device:Context3D):void{
			
			device.setProgramConstantsFromVector( Context3DProgramType.FRAGMENT, m_constants["lightDir"].register.index, m_constants["lightDir"].callFunction() );
			device.setProgramConstantsFromVector( Context3DProgramType.FRAGMENT, m_constants["lightColor"].register.index, m_constants["lightColor"].callFunction() );
			device.setProgramConstantsFromVector( Context3DProgramType.FRAGMENT, m_constants["cameraPos"].register.index, m_constants["cameraPos"].callFunction() );
			
			device.setProgramConstantsFromVector( Context3DProgramType.FRAGMENT, m_constants["constant1"].register.index, m_constants["constant1"].vec );
			device.setProgramConstantsFromVector( Context3DProgramType.FRAGMENT, m_constants["constant2"].register.index, m_constants["constant2"].vec );
			device.setProgramConstantsFromVector( Context3DProgramType.FRAGMENT, m_constants["constant3"].register.index, m_constants["constant3"].vec );
			device.setProgramConstantsFromVector( Context3DProgramType.FRAGMENT, m_constants["constant4"].register.index, m_constants["constant4"].vec );
			device.setProgramConstantsFromVector( Context3DProgramType.FRAGMENT, m_constants["constant5"].register.index, m_constants["constant5"].vec );
			device.setProgramConstantsFromVector( Context3DProgramType.FRAGMENT, m_constants["constant6"].register.index, m_constants["constant6"].vec );
			
			m_vsManager.setTexture(device, m_constants["gradient"].register.index, m_gradient.getTextureForDevice(device) );
			m_vsManager.setTexture(device, m_constants["colorMap"].register.index, m_colorMap.getTextureForDevice(device) );
			m_vsManager.setTexture(device, m_constants["emmisiveMask"].register.index, m_emmisiveMask.getTextureForDevice(device) );
			m_vsManager.setTexture(device, m_constants["lightMap"].register.index, m_lightMap.getTextureForDevice(device) );
			m_vsManager.setTexture(device, m_constants["sMap"].register.index, m_specularMap.getTextureForDevice(device) );
			m_vsManager.setTexture(device, m_constants["refMap"].register.index, m_reflectionMap.getTextureForDevice(device) );
		
		}
		
		protected override function preRender(device:Context3D, _object:SceneObjectRenderable, _camera:Camera3D):void{
			
			m_currentCamera = _camera;
			
			var m:Matrix3D = new Matrix3D();
			m.copyFrom( _camera.transformation.matrixGlobal );
			m.invert();
			m.append( _camera.frustum.projectionMatrix );
						
			device.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, gen.VC["ViewProjection"].index, m, true );
			device.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, gen.VC["Model"].index, _object.transformation.matrixGlobal, true );
			
			m_vsManager.markTexture(device);
			uploadConstants(device);
			m_vsManager.sweepTexture(device);
		}
		
		public override function render(_object:SceneObjectRenderable, _light:Light, _device:Context3D, _camera:Camera3D):void{
			m_currentLight = _light;
			
			var program:Y3DProgram = getProgram(_device, _object, _light);
			
			if( program != m_materialManager.YOGURT3D_INTERNAL::m_lastProgram)
			{
				_device.setProgram( program.program );
				m_materialManager.YOGURT3D_INTERNAL::m_lastProgram = program;
			}
					
			_device.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			_device.setColorMask( m_surfaceParams.colorMaskR, m_surfaceParams.colorMaskG, m_surfaceParams.colorMaskB, m_surfaceParams.colorMaskA);
			_device.setDepthTest( m_surfaceParams.writeDepth, m_surfaceParams.depthFunction );
			_device.setCulling( m_surfaceParams.culling );
			
			preRender(_device, _object, _camera);
			
			var _mesh:IMesh = _object.geometry;
			
			
			for( var submeshindex:uint = 0; submeshindex < _mesh.subMeshList.length; submeshindex++ )
			{
				var subMesh:SubMesh = _mesh.subMeshList[submeshindex];
				m_vsManager.markVertex(_device);
				m_vsManager.setStream( _device,  m_vertexInput.YOGURT3D_INTERNAL::m_vertexpos.index, subMesh.getPositonBufferByContext3D(_device),0, Context3DVertexBufferFormat.FLOAT_3);
				m_vsManager.setStream( _device,  m_vertexInput.YOGURT3D_INTERNAL::m_normal.index, subMesh.getNormalBufferByContext3D(_device),0, Context3DVertexBufferFormat.FLOAT_3);
				m_vsManager.setStream( _device,  m_vertexInput.YOGURT3D_INTERNAL::m_uvMain.index, subMesh.getUVBufferByContext3D(_device),0, Context3DVertexBufferFormat.FLOAT_2);
				m_vsManager.setStream( _device,  m_vertexInput.YOGURT3D_INTERNAL::m_uvSecond.index, subMesh.getUV2BufferByContext3D(_device),0, Context3DVertexBufferFormat.FLOAT_2);
				
				m_vsManager.sweepVertex(_device);
				_device.drawTriangles(subMesh.getIndexBufferByContext3D(_device), 0, subMesh.triangleCount);
			}
			
			postRender(_device);
		}
		
		public override function getFragmentShader(_light:Light):ByteArray{
			gen.destroyAllTmp();
			m_vertexOutput = new FragmentInput(gen);
		
			var camPos:IRegister 	= gen.FC["cameraPos"];
			var lightDir:IRegister 	= gen.FC["lightDir"];
			var lightCol:IRegister 	= gen.FC["lightColor"];
			
			var worldPos:IRegister 	= m_vertexOutput.worldPos;
			var normal:IRegister 	= m_vertexOutput.normal;
			var uv:IRegister 		= m_vertexOutput.uvMain;
			var uv2:IRegister 		= m_vertexOutput.uvSecond;
			
			var zero:String 		= gen.FC["constant1"].x;
			var half:String 		= gen.FC["constant1"].y;
			var one:String 			= gen.FC["constant1"].z;
			var opacity:String 		= gen.FC["constant6"].w;
			
			var blendConst:String 	= gen.FC["constant2"].x;
			var emmAlpha:String 	= gen.FC["constant2"].y;
			
			var fresnelPower:IRegister = gen.FC["constant4"].z;
			var fresnelRef:IRegister = gen.FC["constant2"].w;
			var oneMinFres:IRegister = gen.FC["constant4"].w;
			var refalp:IRegister = gen.FC["constant5"].x;
			
			var shine:String 		= gen.FC["constant3"].x;
			var specColor:String 	= gen.FC["constant3"].yzw;
			var spec:String 		= gen.FC["constant4"].x;
			
			var up:String			= gen.FC["constant1"].xzx;
			var ambUp:String 		= gen.FC["constant5"].yzw;
			var ambDown:String 		= gen.FC["constant6"].xyz;
			var minUp:String		= gen.FC["constant1"].xwx;
			
			var view:IRegister 		= gen.createFT("view", 4);
			var temp1:IRegister 	= gen.createFT("temp1", 4);
			var temp2:IRegister 	= gen.createFT("temp2", 4);
			var temp3:IRegister 	= gen.createFT("temp3", 4);
			var temp4:IRegister 	= gen.createFT("temp4", 4);
			var temp5:IRegister 	= gen.createFT("temp5", 4);
			var result:IRegister 	= gen.createFT("result", 4);		
			var code:String = [
				// VIEW - INDEPENDENT CASE
				gen.code("mov", temp5, normal),
				gen.code("nrm", temp5.xyz, temp5.xyz),
				
				gen.code("dp3", temp1.x, temp5.xyz, up),  	//dot(n.u)
				gen.code("add", temp1.x, temp1.x, one),		//dot(n.u) + 1.0
				gen.code("mul", temp1.x, temp1.x, half),	//dot(n.u)+ 1.0)*0.5
				gen.code("mul", temp2 , temp1.x, ambUp), 	//colorUp * (dot(n.u)+ 1.0)*0.5
				
				gen.code("dp3", temp3.x, temp5.xyz, minUp), //dot(n. -u)
				gen.code("max", temp3.x, temp3.x, zero),  	//max(dot(n. -u),0)
				gen.code("mul", temp3, temp3.x, ambDown),	//max(dot(n. -u),0) * colorDown
				gen.code("add", temp2, temp2, temp3),		//colorUp * (dot(n.u)+ 1.0)*0.5 + max(dot(n. -u),0) * colorDown
//				gen.code("mov", temp1.y , one),
//				gen.tex(temp2, temp1.xy, gen.FS["gradient"], "2d", "clamp", "linear"),// a(dot(n.u))
//				
				
				
				gen.code("dp3", temp1.x, temp5.xyz, lightDir.xyz),// dot(n.l)
				gen.code("mul", temp1.x, temp1.x, half),	// 0.5 * dot(n.l)
				gen.code("add", temp1.x, temp1.x, half),    // 0.5 * dot(n.l) + 0.5
				
				gen.code("mov", temp1.y, zero),
				gen.tex(temp3, temp1.xy, gen.FS["gradient"], "2d", "clamp", "linear"),//w(0.5 * dot(n.l) + 0.5)
					
				gen.code("mul", temp3, temp3, lightCol),   // w * lightCol
				gen.code("mul", temp3, temp3, blendConst), // w * blend * lightCol
				
				gen.tex(temp4, uv2, gen.FS["lightMap"], "2d", "wrap", "linear"),
				gen.code("mul", temp3, temp3, temp4), // w * lightmap* blend * lightCol
				
				gen.tex(temp4, uv2, gen.FS["emmisiveMask"], "2d", "wrap", "linear"),
				gen.code("mul", temp4, temp4, emmAlpha), // emmisive = emmisiveMap * emmisiveAlpha
				gen.code("add", temp3, temp3, temp4), // w * lightmap* blend * lightCol + emmisive

				gen.code("add", temp3, temp3, temp2),// w * lightmap* blend * lightCol + emmisive + a(dot(n.u))
				
				gen.tex(temp4, uv, gen.FS["colorMap"], "2d", "wrap", "linear", m_colorMap.mipmap, true, true, gen.FC["constant2"].z),
				gen.code("mul", temp3, temp3, temp4), // (w * lightmap* blend * lightCol + emmisive + a(dot(n.u))) * colormap
							
				// VIEW - DEPENDENT CASE
				
				gen.reflectionVector(temp2, temp5,  lightDir),	// R = reflect vector (N.L)	
		
				gen.code("sub", view, camPos, worldPos), 
				gen.code("nrm", view.xyz, view.xyz), // view vector = V
				
				gen.code("dp3", temp4.x, view.xyz, temp2.xyz), // v.r
				
				gen.code("pow", temp1.x, temp4.x, shine),// pow (v.r, shineness)
				gen.code("max", temp1.x, temp1.x, zero), //// max (0, pow(dot(v.r), shineness))	
				gen.code("sge", temp2.y, temp4.x, gen.FC["constant4"].y),// v.r > 0.00001
				gen.code("mul", temp1.x, temp1.x, temp2.y),
				
				gen.code("mul", temp1, temp1.x, lightCol), // fs * pow (v.r, shineness) * lightColor
				gen.code("mul", temp1, temp1, specColor),// fs * pow (v.r, shineness) * lightColor * specColor
				
				gen.tex(temp2, uv, gen.FS["sMap"], "2d", "wrap", "linear", m_specularMap.mipmap),
				gen.code("add", temp2.x, temp2.x, spec),// ks or texture = KS
				gen.code("mul", temp1, temp1, temp2.x),// fs * pow (v.r, shineness) * lightColor * specColor * ks
			
				gen.code("add", result, temp1, temp3),
				gen.code("mov", result.w, opacity),
				
				// REFLECTION
				gen.code("dp3", temp3.x, view.xyz, temp5.xyz), 		// V.N
				gen.code("add", temp2.x, temp3.x, temp3.x), 		// 2(V.N)
				gen.code("mul", temp2.xyz, temp2.x, temp5.xyz), 	// 2(V.N)N
				gen.code("sub", temp2.xyz, temp2.xyz, view.xyz),	// 2(V.N)N - V
				
				gen.code("sub", temp3.x, one , temp3.x), // 1. - dot(N,V)
				gen.code("pow", temp3.x, temp3.x, fresnelPower),
				gen.code("mul", temp3.x, temp3.x, oneMinFres),
				gen.code("add", temp3.x, temp3.x, fresnelRef),
				
				gen.tex(temp4, temp2.xyz, gen.FS["refMap"], "3d", "cube", "linear"),
				gen.code("mul", temp4, temp4, refalp),
				gen.code("mul", temp4, temp4,  temp3.x),
				
				gen.code("add", result, temp4,  result),
				gen.code("mov", "oc", result),
				
			].join("\n");
			
//			trace("GENERATED FRAGMENT CODE");
//			trace(gen.printCode(code));
//			trace("****************************************************");
			return ShaderUtils.fragmentAssambler.assemble(Context3DProgramType.FRAGMENT, code, false );
		}
		
		public override function getVertexShader(isSkeletal:Boolean):ByteArray{
			var input:VertexInput = m_vertexInput = new VertexInput(gen);
			var out:VertexOutput = m_vertexOutput;
	
			var normal:IRegister = gen.createVT("normal",4);
			var worldPos:IRegister = gen.createVT("worldPos",4);
			
			gen.createVC("ViewProjection",4);
			gen.createVC("Model",4);
				
			var code:String = 
				[	"//*****VERTEX SHADER*****//",
					"//Calculate world pos",
					gen.code("m44",worldPos, input.vertexpos, gen.VC["Model"]),
					gen.code("mov", out.worldPos, worldPos),
				
					"//Calculate normals",
					gen.code("m33",normal.xyz, input.normal, gen.VC["Model"]),
					gen.code("nrm",normal.xyz, normal.xyz),
					gen.code("mov",out.normal.xyz, normal.xyz),
					gen.code("mov",out.normal.w, input.normal.w),
					
					"//UV",
					gen.code("mov", out.uvMain, input.uvMain ),
					
					"//UV2",
					gen.code("mov", out.uvSecond, input.uvSecond ),
					
					"//Screen Pos",
					gen.code("m44", "op", worldPos, gen.VC["ViewProjection"])	
				].join("\n");
			

			gen.destroyVT("normal");
			gen.destroyVT("worldPos");
			
//			trace( "VERTEX" );
//			trace( gen.printCode(code) );
//			trace( "-------------------------" );
			return ShaderUtils.vertexAssambler.assemble(Context3DProgramType.VERTEX, code, false );
		}
		
		/******************************************************************************************************
		 * Set/Get Textures
		 *****************************************************************************************************/
		public function get gradient():TextureMap{
			return m_gradient;
		}
		
		public function set gradient(value:TextureMap):void
		{
			m_gradient = value;
		}
		
		public function get lightMap():TextureMap
		{
			return m_lightMap;
		}
		
		public function set lightMap(value:TextureMap):void
		{
			if(value){
				m_lightMap = value;
			}else{
				m_lightMap = TextureMapDefaults.WHITE;
			}	
		}
		
		public function get colorMap():TextureMap
		{
			return m_colorMap;
		}
		
		public function set colorMap(value:TextureMap):void
		{
			if(value)
				m_colorMap = value;
			else
				m_colorMap = TextureMapDefaults.WHITEMIPMAP;
		}
		
		public function get specularMap():TextureMap
		{
			return m_specularMap;
		}
		
		public function set specularMap(value:TextureMap):void
		{
			if(value){
				m_specularMap = value;
			}else{
				m_specularMap = TextureMapDefaults.BLACKMIPMAP;
			}
			specular = m_specular;
		}
	
		public function get emmisiveMask():TextureMap
		{
			return m_emmisiveMask;
		}
		
		public function set emmisiveMask(value:TextureMap):void
		{
			if(value){
				m_emmisiveMask = value;
			}else{
				m_emmisiveMask = TextureMapDefaults.BLACK;
			}
		}
		
		public function get reflectionMap():CubeTextureMap
		{
			return m_reflectionMap;
		}
		
		public function set reflectionMap(value:CubeTextureMap):void
		{
			if(value){
				m_reflectionMap = value;
			}else{
				m_reflectionMap = TextureMapDefaults.BLACKCUBEMAP;
			}
		}
		
		/******************************************************************************************************
		 * Set/Get Constants
		 *****************************************************************************************************/
		public function get specColor():Color
		{
			return m_specColor;
		}
		
		public function set specColor(value:Color):void
		{
			m_specColor = value;
			getConstantVec("constant3")[1] = m_specColor.r;
			getConstantVec("constant3")[2] = m_specColor.g;
			getConstantVec("constant3")[3] = m_specColor.b;
		}
		
		public function get ambientUpColor():Color{
			return m_ambientUpColor;
		}
		
		public function set ambientUpColor(_value:Color):void{
			m_ambientUpColor = _value;
			getConstantVec("constant5")[1] = m_ambientUpColor.r;
			getConstantVec("constant5")[2] = m_ambientUpColor.g;
			getConstantVec("constant5")[3] = m_ambientUpColor.b;
		}
		
		public function get ambientDownColor():Color{
			return m_ambientDownColor;
		}
		
		public function set ambientDownColor(_value:Color):void{
			m_ambientDownColor = _value;
			getConstantVec("constant6")[0] = m_ambientDownColor.r;
			getConstantVec("constant6")[1] = m_ambientDownColor.g;
			getConstantVec("constant6")[2] = m_ambientDownColor.b;
		}
		
		public function get specular():Number
		{
			return m_specular;
		}
		
		public function set specular(value:Number):void
		{
			if(m_specularMap != TextureMapDefaults.BLACKMIPMAP){
				value = 0;
			}
			
			m_specular = value;
			getConstantVec("constant4")[0] = value;
		}
		
		public function get blendConstant():Number{
			return m_blendConstant;
		}
		
		public function set blendConstant(_value:Number):void{
			m_blendConstant = _value;
			getConstantVec("constant2")[0] = _value;
		}
		
		public function get shineness():Number
		{
			return m_shineness;
		}
		
		public function set shineness(value:Number):void
		{
			m_shineness = value;
			getConstantVec("constant3")[0] = value;
		}
				
		public function get fresnelReflectance():Number
		{
			return m_fresnelReflectance;
		}
		
		public function set fresnelReflectance(value:Number):void
		{
			m_fresnelReflectance = value;
			getConstantVec("constant2")[3] = m_fresnelReflectance;
			getConstantVec("constant4")[3] = 1-m_fresnelReflectance;
		}
		
		public function get fresnelPower():Number
		{
			return m_fresnelPower;
		}
		
		public function set fresnelPower(value:Number):void
		{
			m_fresnelPower = value;
			getConstantVec("constant4")[2] = m_fresnelPower;
		}
		
		public function get opacity():Number{
			return m_opacity;
		}
		
		public function set opacity(_value:Number):void{
			m_opacity = _value;
			getConstantVec("constant5")[3] = _value;
		}	
		
		public function get emmisiveAlpha():Number
		{
			return m_emmisiveAlpha;
		}
		
		public function set emmisiveAlpha(value:Number):void
		{
			m_emmisiveAlpha = value;
			getConstantVec("constant2")[1] = value;
		}
		
		public function get reflectionAlpha():Number
		{
			return m_reflectionAlpha;
		}
		
		public function set reflectionAlpha(value:Number):void
		{
			m_reflectionAlpha = value;
			getConstantVec("constant5")[0] = value;
		}
	}
}