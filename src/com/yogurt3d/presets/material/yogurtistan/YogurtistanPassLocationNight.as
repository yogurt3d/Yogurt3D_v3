package com.yogurt3d.presets.material.yogurtistan
{
	import com.yogurt3d.YOGURT3D_INTERNAL;
	import com.yogurt3d.core.geoms.IMesh;
	import com.yogurt3d.core.geoms.SubMesh;
	import com.yogurt3d.core.material.Y3DProgram;
	import com.yogurt3d.core.material.agalgen.IRegister;
	import com.yogurt3d.core.material.enum.EBlendMode;
	import com.yogurt3d.core.material.enum.ERegisterShaderType;
	import com.yogurt3d.core.material.parameters.FragmentInput;
	import com.yogurt3d.core.material.parameters.VertexInput;
	import com.yogurt3d.core.material.parameters.VertexOutput;
	import com.yogurt3d.core.material.pass.Pass;
	import com.yogurt3d.core.sceneobjects.SceneObjectRenderable;
	import com.yogurt3d.core.sceneobjects.camera.Camera3D;
	import com.yogurt3d.core.sceneobjects.lights.Light;
	import com.yogurt3d.core.texture.CubeTextureMap;
	import com.yogurt3d.core.texture.TextureMap;
	import com.yogurt3d.utils.Color;
	import com.yogurt3d.utils.ShaderUtils;
	import com.yogurt3d.utils.TextureMapDefaults;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTriangleFace;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;

	public class YogurtistanPassLocationNight  extends Pass
	{
		private var m_gradient				:TextureMap;
		private var m_lightMap				:TextureMap;
		private var m_colorMap				:TextureMap;
		private var m_specularMap			:TextureMap;
		private var m_emmisiveMask			:TextureMap;
		private var m_specularMask			:TextureMap;
		private var m_reflectionMap			:CubeTextureMap;
		
		private var m_color					:Color;
		private var m_specColor				:Color;
		private var m_emmisiveAlpha			:Number;
		private var m_ksColor				:Number;
		private var m_krColor				:Number;
		private var m_blendConstant			:Number;
		private var m_fspecPower			:Number;
		private var m_fRimPower				:Number;
		private var m_kRim					:Number;
		private var m_kSpec					:Number;
		private var m_opacity				:Number;	
		private var m_reflectionAlpha		:Number;
		private var m_fresnelReflectance	:Number;
		private var m_fresnelPower			:Number;
		
		public function YogurtistanPassLocationNight(_gradient:TextureMap,
													 _lightMap:TextureMap=null,
													 _colorMap:TextureMap=null,
													 _specularMap:TextureMap=null,
													 _emmisiveMask:TextureMap=null,
													 _specularMask:TextureMap=null,
													 _reflectionMap:CubeTextureMap=null, 
													 _color:Color=null,
													 _specularColor:Color=null,
													 _emmisiveAlpha:Number=0.0,
													 _ks:Number=1.0,
													 _kr:Number=1.0,
													 _blendConstant:Number=1.5,
													 _fspecPower:Number=1.0,
													 _fRimPower:Number=2.0,
													 _kRim:Number=1.0, 
													 _kSpec:Number=1.0,
													 _opacity:Number=1.0, 	
													 _refAlpha:Number=1.0,
													 _fresnelReflectance:Number=0.028,
													 _fresnelPower:Number=5)
		{
			
			m_surfaceParams.blendEnabled = true;
			m_surfaceParams.blendMode = EBlendMode.ALPHA;
			
			m_surfaceParams.writeDepth = true;
			m_surfaceParams.depthFunction = Context3DCompareMode.LESS;
			m_surfaceParams.culling = Context3DTriangleFace.FRONT;
			
			m_color = _color;
			if(_color == null)
				m_color = new Color(1,1,1,1);
			if(_specularColor == null)
				m_specColor = new Color(1,1,1,1);
			
			m_emmisiveAlpha = _emmisiveAlpha;
			m_ksColor = _ks;
			m_krColor = _kr;
			m_blendConstant = _blendConstant;
			m_fspecPower = _fspecPower;
			m_fRimPower = _fRimPower;
			m_kRim	= _kRim;
			m_kSpec = _kSpec;
			m_opacity = _opacity;
			
			m_reflectionAlpha = _refAlpha;
			m_fresnelReflectance = _fresnelReflectance;
			m_fresnelPower = _fresnelPower;
			
			m_gradient = _gradient;
			m_colorMap = (_colorMap)?_colorMap:TextureMapDefaults.WHITE;
			m_specularMap = (_specularMap)?_specularMap:TextureMapDefaults.BLACK;
			m_specularMask = (_specularMask)?_specularMask:TextureMapDefaults.BLACK;
			m_emmisiveMask = (_emmisiveMask)?_emmisiveMask:TextureMapDefaults.BLACK;
			m_lightMap = (_lightMap)?_lightMap:TextureMapDefaults.WHITE;
			m_reflectionMap = (_reflectionMap)?_reflectionMap:TextureMapDefaults.BLACKCUBEMAP;
			
			if(m_specularMask != TextureMapDefaults.BLACK)
				m_ksColor = 0.0;
				
			if(m_specularMap != TextureMapDefaults.BLACK)
				m_kSpec = 0;
			
			createConstantFromVector( ERegisterShaderType.FRAGMENT, "constant1", Vector.<Number>([ 0.0, 0.5, 1.0, m_reflectionAlpha ]));
			createConstantFromVector( ERegisterShaderType.FRAGMENT, "constant2", Vector.<Number>([ m_blendConstant, 0.1, 200, m_kSpec ]));
			createConstantFromVector( ERegisterShaderType.FRAGMENT, "constant3", Vector.<Number>([ m_color.r, m_color.g, m_color.b, 0.00000001 ]));
			createConstantFromVector( ERegisterShaderType.FRAGMENT, "constant4", Vector.<Number>([ m_fspecPower, m_kRim, m_ksColor, m_krColor ]));
			createConstantFromVector( ERegisterShaderType.FRAGMENT, "constant5", Vector.<Number>([ m_fRimPower, m_reflectionAlpha, m_emmisiveAlpha, m_fresnelReflectance]));
			createConstantFromVector( ERegisterShaderType.FRAGMENT, "constant6", Vector.<Number>([ m_fresnelPower, (1-m_fresnelReflectance), m_opacity, 0]));
			createConstantFromVector( ERegisterShaderType.FRAGMENT, "constant7", Vector.<Number>([ m_specColor.r, m_specColor.g, m_specColor.b, 0]));
				
			createConstantFromTexture(ERegisterShaderType.FRAGMENT, "gradient", m_gradient );
			createConstantFromTexture(ERegisterShaderType.FRAGMENT, "colorMap", m_colorMap );
			createConstantFromTexture(ERegisterShaderType.FRAGMENT, "specMap", m_specularMap);
			createConstantFromTexture(ERegisterShaderType.FRAGMENT, "specMask", m_specularMask );
			createConstantFromTexture(ERegisterShaderType.FRAGMENT, "emmisiveMask", m_emmisiveMask);
			createConstantFromTexture(ERegisterShaderType.FRAGMENT, "refMap", m_reflectionMap);
			createConstantFromTexture(ERegisterShaderType.FRAGMENT, "lightMap", m_lightMap);
			
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
			// set vectorConstants
			device.setProgramConstantsFromVector( Context3DProgramType.FRAGMENT, m_constants["constant1"].register.index, m_constants["constant1"].vec );
			device.setProgramConstantsFromVector( Context3DProgramType.FRAGMENT, m_constants["constant2"].register.index, m_constants["constant2"].vec );
			device.setProgramConstantsFromVector( Context3DProgramType.FRAGMENT, m_constants["constant3"].register.index, m_constants["constant3"].vec );
			device.setProgramConstantsFromVector( Context3DProgramType.FRAGMENT, m_constants["constant4"].register.index, m_constants["constant4"].vec );
			device.setProgramConstantsFromVector( Context3DProgramType.FRAGMENT, m_constants["constant5"].register.index, m_constants["constant5"].vec );
			device.setProgramConstantsFromVector( Context3DProgramType.FRAGMENT, m_constants["constant6"].register.index, m_constants["constant6"].vec );
			device.setProgramConstantsFromVector( Context3DProgramType.FRAGMENT, m_constants["constant7"].register.index, m_constants["constant7"].vec );
			
			// set vectorFunctionsConstants
			
			device.setProgramConstantsFromVector( Context3DProgramType.FRAGMENT, m_constants["lightDir"].register.index, m_constants["lightDir"].callFunction() );
			device.setProgramConstantsFromVector( Context3DProgramType.FRAGMENT, m_constants["lightColor"].register.index, m_constants["lightColor"].callFunction() );
			device.setProgramConstantsFromVector( Context3DProgramType.FRAGMENT, m_constants["cameraPos"].register.index, m_constants["cameraPos"].callFunction() );
			
			// set textureConstants
				
			//var texConst:TextureConstant = value as TextureConstant;
			//m_vsManager.setTexture(device, texConst.register.index, texConst.texture.getTextureForDevice(device) );
			//device.setTextureAt(texConst.register.index, texConst.texture.getTextureForDevice(device) );
			
			m_vsManager.setTexture(device, m_constants["gradient"].register.index, m_gradient.getTextureForDevice(device) );
			m_vsManager.setTexture(device, m_constants["colorMap"].register.index, m_colorMap.getTextureForDevice(device) );
			m_vsManager.setTexture(device, m_constants["specMap"].register.index, m_specularMap.getTextureForDevice(device) );
			m_vsManager.setTexture(device, m_constants["specMask"].register.index, m_specularMask.getTextureForDevice(device) );
			m_vsManager.setTexture(device, m_constants["emmisiveMask"].register.index, m_emmisiveMask.getTextureForDevice(device) );
			m_vsManager.setTexture(device, m_constants["refMap"].register.index, m_reflectionMap.getTextureForDevice(device) );
			m_vsManager.setTexture(device, m_constants["lightMap"].register.index, m_lightMap.getTextureForDevice(device) );
		}
		
		protected override function preRender(device:Context3D, _object:SceneObjectRenderable, _camera:Camera3D):void{
			device.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, gen.VC["Model"].index, _object.transformation.matrixGlobal, true );
			device.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, gen.VC["ViewProjection"].index, _camera.viewProjectionMatrix, true );
			
			m_currentCamera = _camera;
			
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
			
			//_device.setProgram( program.program );
			
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
		
		public override function getVertexShader(isSkeletal:Boolean):ByteArray{
			var input:VertexInput = m_vertexInput = new VertexInput(gen);
			var out:VertexOutput = m_vertexOutput;
			var worldPos:IRegister = gen.createVT("worldPos",4);
			
			gen.createVC("Model",4);
			gen.createVC("ViewProjection",4);
			
			var code:String = 
				[	"//*****VERTEX SHADER*****//",
					"//Calculate world pos",
					gen.code("m44",worldPos, input.vertexpos, gen.VC["Model"]),
					gen.code("mov", out.worldPos, worldPos),
					
					"//Calculate normals",
					gen.code("m33",out.normal.xyz, input.normal, gen.VC["Model"]),
					gen.code("mov",out.normal.w, input.normal.w),
					
					"//UV",
					gen.code("mov", out.uvMain, input.uvMain ),
					
					"//UV2",
					gen.code("mov", out.uvSecond, input.uvSecond ),
					
					"//Screen Pos",
					gen.code("m44", "op", worldPos, gen.VC["ViewProjection"])		
				].join("\n");
			
			gen.destroyVT("worldPos");
			
			trace( code );
			
			return ShaderUtils.vertexAssambler.assemble(Context3DProgramType.VERTEX, code, false );
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
			var opacity:String 		= gen.FC["constant6"].z;
			
			var bconst:String		= gen.FC["constant2"].x; 
			var up:String			= gen.FC["constant1"].xzx;
			var approx:String 		= gen.FC["constant3"].w;
			
			var fspecPow:String 	= gen.FC["constant4"].x;
			var krim:String 		= gen.FC["constant4"].y;
			var ksCol:String		= gen.FC["constant4"].z;
			var krCol:String		= gen.FC["constant4"].w;
			var fRimPow:String		= gen.FC["constant5"].x;
				
			var fresnelPower:IRegister = gen.FC["constant6"].x;
			var fresnelRef:IRegister = gen.FC["constant5"].w;
			var oneMinFres:IRegister = gen.FC["constant6"].y;
		
			var view:IRegister 		= gen.createFT("view", 4);
			var temp1:IRegister 	= gen.createFT("temp1", 4);
			var temp2:IRegister 	= gen.createFT("temp2", 4);
			var temp3:IRegister 	= gen.createFT("temp3", 4);
			var temp4:IRegister 	= gen.createFT("temp4", 4);
			var temp5:IRegister 	= gen.createFT("temp5", 4);
			var result:IRegister 	= gen.createFT("result", 4);
			
			
			var reflectionCode:String = [
			
				gen.code("sub", view, camPos, worldPos), 						// View Vector = V
				gen.code("nrm", view.xyz, view.xyz), 							// norm(V)
				
				gen.code("dp3", temp5.x, view.xyz, normal.xyz), 						// V.N
				gen.code("add", temp4.x, temp5.x, temp5.x), 						// 2(V.N)
				gen.code("mul", temp4.xyz, temp4.x, normal.xyz), 			// 2(V.N)N
				gen.code("sub", temp4.xyz, temp4.xyz, view.xyz),			// R = 2(V.N)N - V
				
				gen.code("sub", temp5.x, one , temp5.x), // 1. - dot(N,V)
				gen.code("pow", temp5.x, temp5.x, fresnelPower),
				gen.code("mul", temp5.x, temp5.x, oneMinFres),
				gen.code("add", temp5.x, temp5.x, fresnelRef),
			
				gen.tex(temp4, temp4.xyz, gen.FS["refMap"], "3d", "cube", "linear"),
				gen.code("mul", temp4, temp4, gen.FC["constant1"].w),
				gen.code("mul", temp4, temp4,  temp5.x)
				
			].join("\n");
			
			var code:String = [
				// View - Independent
				// Step 1 : Half Lambert Term
				
				gen.code("mov", temp1, lightDir),			 				// temp1 = lightDir
				gen.code("nrm", temp1.xyz, temp1.xyz),	 				// norm(L)
				
				gen.code("dp3", temp1.x, normal.xyz, temp1.xyz), 			// temp1.x = dot(N.L)
				gen.code("mul", temp1.y, temp1.x, half),					// dot(N.L) * 0.5
				gen.code("add", temp1.y, temp1.y, half),					// lambert = dot(N.L) * 0.5 + 0.5
				
				// Step 2: Warping (lambert)
				gen.code("mov", temp1.x, zero),
				gen.tex(temp2, temp1.yx, gen.FS["gradient"], "2d", "clamp", "linear", m_gradient.mipmap),
			
				gen.code("mul", temp2, temp2, bconst), 
				
//				// Step 3: color of light * Warping (lambert)
				gen.code("mul", temp2, temp2, lightCol), 
//				
//				// Step 4: ambient term a(dot(n.u) )
				gen.code("dp3", temp1.z, normal.xyz, up), 
				gen.code("add", temp1.z, temp1.z, one), 
				gen.code("mul", temp5.x, temp1.z, half), 
				gen.code("mov", temp5.y, one),
				gen.tex(temp3, temp5.xy, gen.FS["gradient"], "2d", "clamp", "linear", m_gradient.mipmap),//TODO
								
//				// a(n.u) + color of light * Warping (lambert)
				gen.code("add", temp2, temp2, temp3),
						
//				// Step 5: Get Color map
				gen.tex(result, uv, gen.FS["colorMap"], "2d", "wrap", "linear", m_colorMap.mipmap, true, m_colorMap.transparent, gen.FC["constant2"].y),
				gen.code("mul", result, temp2, result), 
				gen.code("mul", result.xyz, result.xyz, gen.FC["constant3"].xyz),
				
				//gen.code("mov", "oc", result),
//				
//				// View Dependent
//				// Step 6: Phong Specular Term
				gen.reflectionVector(temp2, lightDir, normal),				// R = reflect vector (L, N)	
				gen.code("sub", view, camPos, worldPos), 						// View Vector = V
				gen.code("nrm", view.xyz, view.xyz), 							// norm(V)
				gen.code("dp3", temp1.z, view, temp2),						// dot(v.r)
////				
				gen.tex(temp2, uv, gen.FS["specMap"], "2d", "wrap", "linear", m_specularMap.mipmap),
				gen.code("mul", temp2.x, temp2.x, gen.FC["constant2"].z),
				gen.code("add", temp2.x, temp2.x, gen.FC["constant2"].w),	// kspec = if there is specular map, get it from it else get from kSpec
				gen.code("pow", temp2.x, temp1.z, temp2.x), 					// kspec = pow(dot(v.r), kspec)
////				
////				// if L.n > 0 max (0, pow(dot(n.l), kspec))
				gen.code("max", temp2.y, zero, temp2.x), 						//max (0, pow(dot(n.l), kspec))
				gen.code("sge", temp5.y, temp1.z, approx), 					// dot(v.r) >= 0.0000001
				gen.code("mul", temp2.y, temp2.y, temp5.y), 					// temp2.y = phong specular term
////				
				gen.fresnel(temp2.z, normal, view, fspecPow, one), 			//fs = DFT
				gen.code("add", temp2.z , temp2.z, half),						// fs = DFT + 0.5
				gen.code("mul", temp2.z, temp2.z, temp2.y), 					// fs * phong specular term
////				
				gen.code("pow", temp2.w, temp1.z, krim),						//pow(dot(v.r), krim)
				gen.code("max", temp2.w, temp2.w, zero),						// max (0, pow(dot(v.r), krim))
				gen.code("mul", temp2.w, temp5.y, temp2.w), 					// temp2.w = rim specular
//				
//				// temp3 =amb  result = independent result,  temp2.y temp2.w temp1 = free 
				gen.fresnel(temp1.x, normal, view, fRimPow, one),
//				//	m_gen.tex(temp4, uv, m_gen.FS["rimMask"], "2d", "wrap", "linear", m_rimMask.mipmap),
//				//	m_gen.code("add", temp4.x, temp4.x, temp4.x),
				gen.code("mov", temp4.x, krCol),
//				
				gen.code("mul", temp1.x, temp1.x, temp4.x),					// fr * kr
				gen.code("mul", temp1.y, temp1.x, temp2.w), 					//   fr * kr * rim spec
//				
				gen.code("max", temp1.z, temp2.z, temp1.y),
				gen.code("mul", temp4, lightCol, temp1.z),
//				
				gen.tex(temp2, uv, gen.FS["specMask"], "2d", "wrap", "linear", m_specularMask.mipmap),
				gen.code("add", temp2.x, temp2.x, temp2.x),
				gen.code("add", temp2.x, temp2.x, ksCol),
////				
				gen.code("mul", temp4, temp4, temp2.x),
				gen.code("mul", temp4, temp4, gen.FC["constant7"].xyz),
//					
				gen.code("mul", temp3, temp1.x, temp3),//ambien based view dependent
				gen.code("mul", temp3, temp5.x, temp3),
//				
				gen.code("add", temp4, temp4, temp3),
				gen.code("add", result, result, temp4),
//				
				gen.tex(temp2, uv2, gen.FS["lightMap"], "2d", "wrap", "linear", m_lightMap.mipmap),
				gen.code("mul", result.xyz, result.xyz, temp2.xyz),
				
				// add emmisive
				gen.tex(temp2, uv2, gen.FS["emmisiveMask"], "2d", "wrap", "linear", m_emmisiveMask.mipmap),
				gen.code("mul", temp2, temp2, gen.FC["constant5"].z),
				gen.code("add", result.xyz, result.xyz, temp2.xyz),
			
				gen.code("mov", result.w, opacity),
				
				// REF MAP

				reflectionCode,
				gen.code("add", result, result, temp4),
//			
				gen.code("mov", "oc", result)
			].join("\n");
			
			trace(gen.printCode( code ));
			return ShaderUtils.vertexAssambler.assemble(Context3DProgramType.FRAGMENT, code, false );
		}
		
		/******************************************************************************************************
		 * Set/Get Constants
		 *****************************************************************************************************/
		
		public function get blendConstant():Number{
			return m_blendConstant;
		}
		
		public function set blendConstant(_value:Number):void{
			m_blendConstant = _value;
			getConstantVec("constant2")[0] = _value;
		}
		
		public function get opacity():Number{
			return m_opacity;
		}
		
		public function set opacity(_value:Number):void{
			m_opacity = _value;
			getConstantVec("constant6")[2] = _value;
		}
		
		public function get fresnelReflectance():Number{
			return m_fresnelReflectance;
		}
		
		public function set fresnelReflectance(_value:Number):void{
			m_fresnelReflectance = _value;
			getConstantVec("constant5")[3] = m_fresnelReflectance;
			getConstantVec("constant6")[1] = 1.0 - m_fresnelReflectance;
		}
		
		
		public function get fresnelPower():Number{
			return m_fresnelPower;		
		}
		
		public function set fresnelPower(_value:Number):void{
			m_fresnelPower = _value;
			getConstantVec("constant6")[0] = m_fresnelPower;
		}
		
		public function get emmisiveAlpha():Number
		{
			return m_emmisiveAlpha;
		}
		
		public function set emmisiveAlpha(value:Number):void
		{
			m_emmisiveAlpha = value;
			getConstantVec("constant5")[2] = value;
		}
		
		public function get reflectionAlpha():Number
		{
			return m_reflectionAlpha;
		}
		
		public function set reflectionAlpha(value:Number):void
		{
			m_reflectionAlpha = value;
			getConstantVec("constant1")[3] = value;
		}
	
		public function set ksColor(value:Number):void{
			
			if(m_specularMask != TextureMapDefaults.BLACK){
				value = 0;
			}
			m_ksColor = value;
			getConstantVec("constant4")[2] = value;
			
		}
		public function get ksColor():Number{
			return m_ksColor;
		}
		
		
		public function get krColor():Number{
			return m_krColor;
		}
		
		public function set krColor(value:Number):void{
	
			m_krColor = value;
			getConstantVec("constant4")[3] = value;
		}
		
		public function get fRimPower():Number
		{
			return m_fRimPower;
		}
		
		public function set fRimPower(value:Number):void
		{
			m_fRimPower = value;
			getConstantVec("constant5")[0] = value;
		}
		
		
		public function get kRim():Number{
			return m_kRim;
		}
		
		public function set kRim(value:Number):void{
			m_kRim = value;
			getConstantVec("constant4")[1]  = value;
		}
		
		public function get fspecPower():Number
		{
			return m_fspecPower;
		}
		
		public function set fspecPower(value:Number):void
		{
			m_fspecPower = value;
			getConstantVec("constant4")[0] = value;
		}
		
		public function get kSpec():Number
		{
			return m_kSpec;
		}
		
		public function set kSpec(value:Number):void
		{
			if(m_specularMap != TextureMapDefaults.BLACK){
				value = 0;
			}
			m_kSpec = value;
			getConstantVec("constant2")[3] = m_kSpec;
		}
		
		public function get color():Color
		{
			return m_color;
		}
		
		public function set color(value:Color):void
		{
			m_color = value;
			getConstantVec("constant3")[0] = m_color.r;
			getConstantVec("constant3")[1] = m_color.g;
			getConstantVec("constant3")[2] = m_color.b;
		}
		
		public function get specColor():Color
		{
			return m_specColor;
		}
		
		public function set specColor(value:Color):void
		{
			m_specColor = value;
			getConstantVec("constant7")[0] = m_specColor.r;
			getConstantVec("constant7")[1] = m_specColor.g;
			getConstantVec("constant7")[2] = m_specColor.b;
		}
		
		/******************************************************************************************************
		 * Set/Get Textures
		 *****************************************************************************************************/
		
		public function get gradient():TextureMap
		{
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
				m_colorMap = TextureMapDefaults.WHITE;
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
				m_specularMap = TextureMapDefaults.BLACK;
			}
			kSpec = m_kSpec;
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
		
		public function get specularMask():TextureMap
		{
			return m_specularMask;
		}
		
		public function set specularMask(value:TextureMap):void
		{
			if(value){
				m_specularMask = value;
			}else{
				m_specularMask = TextureMapDefaults.BLACK;
			}
			ksColor = m_ksColor;
		}
		
		public function get reflectionMap():CubeTextureMap
		{
			return m_reflectionMap;
		}
		
		public function set reflectionMap(value:CubeTextureMap):void
		{
			if(value)
				m_reflectionMap = value;
			else
				m_reflectionMap = TextureMapDefaults.BLACKCUBEMAP;	
		}
	

	}
}