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

	public class YogurtistanPassLocation extends Pass
	{
		private var m_opacity				:Number;	
		private var m_fspecPower			:Number;
		private var m_fRimPower				:Number;
		private var m_kRim					:Number;
		private var m_kSpec					:Number;
		private var m_ksColor				:Number;
		private var m_krColor				:Number;
		private var m_color					:Color;
		private var m_reflectionAlpha		:Number;
		private var m_fresnelReflectance	:Number;
		private var m_fresnelPower			:Number;
		
		private var m_reflectionMap			:CubeTextureMap;
		private var m_colorMap				:TextureMap;
		private var m_specularMap			:TextureMap;
		private var m_specularMask			:TextureMap;
		private var m_lightMap				:TextureMap;
		
	//	protected var m_currentCamera		:Camera3D;
			
		public function YogurtistanPassLocation(_colorMap:TextureMap=null,
												_specularMap:TextureMap=null,
												_specularMask:TextureMap=null,
												_lightMap:TextureMap=null,
												_color:Color=null,
												_ks:Number=1.0,//if texture is used for ks, default=-1
												_kr:Number=1.0,
												_fspecPower:Number=1.0,
												_fRimPower:Number=2.0,
												_kRim:Number=1.0, 
												_kSpec:Number=1.0,
												_opacity:Number=1.0, 
												_reflectionMap:CubeTextureMap=null, 
												_refAlpha:Number=0.0,
												_fresnelReflectance:Number=0.028,
												_fresnelPower:Number=5)
		{
			
			m_surfaceParams.blendEnabled = true;
			m_surfaceParams.blendMode = EBlendMode.ALPHA;
			
			m_surfaceParams.writeDepth = true;
			m_surfaceParams.depthFunction = Context3DCompareMode.LESS;
			m_surfaceParams.culling = Context3DTriangleFace.FRONT;
			
			// Set Parameters
			m_color = _color;
			if(_color == null)
				m_color = new Color(1,1,1,1);
			
			m_colorMap = (_colorMap)?_colorMap:TextureMapDefaults.WHITE;
			m_reflectionMap = (_reflectionMap)?_reflectionMap:TextureMapDefaults.BLACKCUBEMAP;
			m_specularMap = (_specularMap)?_specularMap:TextureMapDefaults.BLACK;
			m_specularMask = (_specularMask)?_specularMask:TextureMapDefaults.BLACK;
			m_lightMap = (_lightMap)?_lightMap:TextureMapDefaults.WHITE;
			
			m_reflectionAlpha = _refAlpha;
			m_opacity = _opacity;
			m_fspecPower = _fspecPower;
			m_fRimPower = _fRimPower;
			m_kRim = _kRim;
			m_krColor = _kr;
			m_ksColor = _ks;
			
			m_fresnelReflectance = _fresnelReflectance;
			m_fresnelPower = _fresnelPower;
				
			if(m_specularMask == TextureMapDefaults.BLACK){
				m_ksColor = _ks;
			}else{
				m_ksColor = 0.0;
				m_kSpec = 0.0;
			}
			
			createConstantFromVector( ERegisterShaderType.FRAGMENT, "constant1", Vector.<Number>([ 0.0, 0.5, 1.0, m_reflectionAlpha ]));
			createConstantFromVector( ERegisterShaderType.FRAGMENT, "constant2", Vector.<Number>([ m_opacity, m_color.r, m_color.g, m_color.b ]));
			createConstantFromVector( ERegisterShaderType.FRAGMENT, "constant3", Vector.<Number>([ 200, m_kSpec, 0.00000001, m_fspecPower ]));
			createConstantFromVector( ERegisterShaderType.FRAGMENT, "constant4", Vector.<Number>([ m_fRimPower, m_kRim , m_krColor ,m_ksColor ]));
			createConstantFromVector( ERegisterShaderType.FRAGMENT, "constant5", Vector.<Number>([ 0.1, m_fresnelReflectance , m_fresnelPower ,(1-m_fresnelReflectance) ]));
			
			createConstantFromTexture(ERegisterShaderType.FRAGMENT, "colorMap", m_colorMap );
			createConstantFromTexture(ERegisterShaderType.FRAGMENT, "refMap", m_reflectionMap );
			createConstantFromTexture(ERegisterShaderType.FRAGMENT, "specMap", m_specularMap);
			createConstantFromTexture(ERegisterShaderType.FRAGMENT, "specMask", m_specularMask );
			createConstantFromTexture(ERegisterShaderType.FRAGMENT, "lightMap", m_lightMap );
			
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
			
			// set vectorFunctionsConstants
			
			device.setProgramConstantsFromVector( Context3DProgramType.FRAGMENT, m_constants["lightDir"].register.index, m_constants["lightDir"].callFunction() );
			device.setProgramConstantsFromVector( Context3DProgramType.FRAGMENT, m_constants["lightColor"].register.index, m_constants["lightColor"].callFunction() );
			device.setProgramConstantsFromVector( Context3DProgramType.FRAGMENT, m_constants["cameraPos"].register.index, m_constants["cameraPos"].callFunction() );
			
			// set textureConstants
		
			device.setTextureAt(m_constants["refMap"].register.index, m_reflectionMap.getTextureForDevice(device) );
			device.setTextureAt(m_constants["colorMap"].register.index, m_colorMap.getTextureForDevice(device) );
			device.setTextureAt(m_constants["specMap"].register.index, m_specularMap.getTextureForDevice(device) );
			device.setTextureAt(m_constants["specMask"].register.index, m_specularMask.getTextureForDevice(device) );
			device.setTextureAt(m_constants["lightMap"].register.index, m_lightMap.getTextureForDevice(device) );
			
		}
		
		protected override function preRender(device:Context3D, _object:SceneObjectRenderable, _camera:Camera3D):void{
			device.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, gen.VC["Model"].index, _object.transformation.matrixGlobal, true );
			device.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, gen.VC["ViewProjection"].index, _camera.viewProjectionMatrix, true );
			
			m_currentCamera = _camera;
			
			uploadConstants(device);
		}
		
		public override function render(_object:SceneObjectRenderable, _light:Light, _device:Context3D, _camera:Camera3D):void{
			m_currentLight = _light;
			
			var program:Y3DProgram = getProgram(_device, _object, _light);
			
			_device.setProgram( program.program );
			
			_device.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			_device.setColorMask( m_surfaceParams.colorMaskR, m_surfaceParams.colorMaskG, m_surfaceParams.colorMaskB, m_surfaceParams.colorMaskA);
			_device.setDepthTest( m_surfaceParams.writeDepth, m_surfaceParams.depthFunction );
			_device.setCulling( m_surfaceParams.culling );
			
			preRender(_device, _object, _camera);
			
			var _mesh:IMesh = _object.geometry;
			for( var submeshindex:uint = 0; submeshindex < _mesh.subMeshList.length; submeshindex++ )
			{
				var subMesh:SubMesh = _mesh.subMeshList[submeshindex];
				
				m_vsManager.setStream( _device,  m_vertexInput.YOGURT3D_INTERNAL::m_vertexpos.index, subMesh.getPositonBufferByContext3D(_device),0, Context3DVertexBufferFormat.FLOAT_3);
				m_vsManager.setStream( _device,  m_vertexInput.YOGURT3D_INTERNAL::m_normal.index, subMesh.getNormalBufferByContext3D(_device),0, Context3DVertexBufferFormat.FLOAT_3);
				m_vsManager.setStream( _device,  m_vertexInput.YOGURT3D_INTERNAL::m_uvMain.index, subMesh.getUVBufferByContext3D(_device),0, Context3DVertexBufferFormat.FLOAT_2);
				m_vsManager.setStream( _device,  m_vertexInput.YOGURT3D_INTERNAL::m_uvSecond.index, subMesh.getUV2BufferByContext3D(_device),0, Context3DVertexBufferFormat.FLOAT_2);
			
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
			
			var camPos:IRegister = gen.FC["cameraPos"];
			var lightCol:IRegister = gen.FC["lightColor"];
			var lightDir:IRegister = gen.FC["lightDir"];
			
			var zero:String = gen.FC["constant1"].x;
			var half:String = gen.FC["constant1"].y;
			var one:String = gen.FC["constant1"].z;
			var opacity:String = gen.FC["constant2"].x;
			var approx:String = gen.FC["constant3"].z;
			var fspecPow:String = gen.FC["constant3"].w;
			var frimPow:String = gen.FC["constant4"].x;
			var krim:String = gen.FC["constant4"].y;
			var kcol:String = gen.FC["constant4"].z;
			var kscol:String = gen.FC["constant4"].w;
			
			var worldPos:IRegister = m_vertexOutput.worldPos;
			var normal:IRegister =	m_vertexOutput.normal;
			var uv:IRegister = m_vertexOutput.uvMain;
			var uv2:IRegister = m_vertexOutput.uvSecond;
			var fresnelPower:IRegister = gen.FC["constant5"].z;
			var fresnelRef:IRegister = gen.FC["constant5"].y;
			var oneMinFres:IRegister = gen.FC["constant5"].w;
			
			// TEMP Registers for calculations
			var result:IRegister = gen.createFT("result", 4);
			var view:IRegister = gen.createFT("view", 4);
			var refResult:IRegister = gen.createFT("refResult", 4);
			var temp2:IRegister = gen.createFT("tmp2", 4);
			var sMap:IRegister = gen.createFT("specMap", 4);
			
			var reflectionCode:String = [
				gen.code("dp3", sMap.x, view.xyz, normal.xyz), 						// V.N
				gen.code("add", refResult.x, sMap.x, sMap.x), 						// 2(V.N)
				gen.code("mul", refResult.xyz, refResult.x, normal.xyz), 			// 2(V.N)N
				gen.code("sub", refResult.xyz, refResult.xyz, view.xyz),			// R = 2(V.N)N - V
				
				// fresnel
				
				gen.code("sub", sMap.x, one , sMap.x), // 1. - dot(N,V)
				gen.code("pow", sMap.x, sMap.x, fresnelPower),
				gen.code("mul", sMap.x, sMap.x, oneMinFres),
				gen.code("add", sMap.x, sMap.x, fresnelRef),
				
				gen.tex(refResult, refResult.xyz, gen.FS["refMap"], "3d", "cube", "linear"),
				gen.code("mul", refResult, refResult, gen.FC["constant1"].w),
				gen.code("mul", refResult, refResult,  sMap.x)
			
			].join("\n");
			
			// temp2
			// refResult
			// sMap
		
			
			var code:String = [
				"//*****FRAGMENT SHADER*****//",
				gen.code("sub", view, camPos, worldPos), // View Vector = V
				gen.code("nrm", view.xyz, view.xyz), // norm(V)
				
				reflectionCode,

				// View Dependent 
				gen.reflectionVector(temp2, lightDir, normal), // R = reflect(L, N)
				gen.code("dp3", temp2.x, view.xyz, temp2.xyz), // temp2.x = dot(V.R)
				
				gen.tex(sMap, uv, gen.FS["specMap"], "2d", "wrap", "linear", m_specularMap.mipmap),
				gen.code("mul", sMap.x, sMap.x, gen.FC["constant3"].x),
				gen.code("add", sMap.x, sMap.x, gen.FC["constant3"].y),// if there is specular map, get it from it else get from kSpec
				
				gen.code("pow", sMap.x, temp2.x, sMap.x),//pow(dot(v.r), kspec)
				
				// if L.n > 0 max (0, pow(dot(n.l), kspec))
				gen.code("max", sMap.y, zero, sMap.x), //max (0, pow(dot(n.l), kspec))
				gen.code("sge", sMap.z, temp2.x, approx), // dot(v.r) >= 0.0000001
				gen.code("mul", sMap.y, sMap.y, sMap.z), // sMap.y = phong specular term
				
				gen.fresnel(sMap.w, normal, view, fspecPow, one), //fs = DFT
				gen.code("add", sMap.w , sMap.w, half),// fs = DFT + 0.5
				gen.code("mul", sMap.w, sMap.w, sMap.y), // fs * phong specular term
				
				
				gen.code("pow", temp2.y, temp2.x, krim),//pow(dot(v.r), krim)
				gen.code("max", temp2.y, temp2.y, zero),// max (0, pow(dot(v.r), krim))
				gen.code("mul", temp2.y, sMap.z, temp2.y), // temp2.y = rim specular
				
				gen.fresnel(temp2.z, normal, view, frimPow, one), //fr = DFT
				gen.code("mul", temp2.z, temp2.z, kcol),// fr * kr
				gen.code("mul", temp2.w, temp2.y, temp2.z),//fr * kr * (pow(dot(v.r), krim)
				
				gen.code("max", temp2.z, temp2.w, sMap.w),
				gen.code("mul", view, lightCol, temp2.z),
				
				gen.tex(sMap, uv, gen.FS["specMask"], "2d", "wrap", "linear", m_specularMask.mipmap),
				gen.code("add", sMap.x, sMap.x, sMap.x),
				gen.code("add", sMap.x, sMap.x, kscol),
				
				gen.code("mul", view, view, sMap.x),
				
				// Get Color Map & Color & Alpha Kill
				gen.tex(result, uv, gen.FS["colorMap"], "2d", "wrap", "linear", m_colorMap.mipmap, true, m_colorMap.transparent, gen.FC["constant5"].x),
				
				gen.code("mul", result.xyz, result.xyz, gen.FC["constant2"].yzw),
				
				gen.code("add", result.xyz, view.xyz, result.xyz),
				
				// Holy Light Map
				gen.tex(sMap, uv2, gen.FS["lightMap"], "2d", "wrap", "linear", m_lightMap.mipmap),
				gen.code("mul", result.xyz, sMap.xyz, result.xyz),
				
				
				//gen.code("mov", result.w, opacity),
			//	gen.code("add", result.w, result.w, gen.FC["constant1"].w),
				gen.code("mul", result, result, opacity),
				
				// Add by Reflection
				gen.code("add", result, result, refResult),
				
				gen.code("mov", "oc", result)
			
			].join("\n");
			
			
			
	
			trace("\n" + code);
				
			return ShaderUtils.vertexAssambler.assemble(Context3DProgramType.FRAGMENT, code, false );
		}
		
		/******************************************************************************************************
		 * Set/Get Constants
		 *****************************************************************************************************/
		
		public function get fresnelReflectance():Number{
			return m_fresnelReflectance;
		}
		
		public function set fresnelReflectance(_value:Number):void{
			m_fresnelReflectance = _value;
			getConstantVec("constant5")[1] = m_fresnelReflectance;
			getConstantVec("constant5")[3] = 1.0 - m_fresnelReflectance;
		}
		
		
		public function get fresnelPower():Number{
			return m_fresnelPower;		
		}
		
		public function set fresnelPower(_value:Number):void{
			m_fresnelPower = _value;
			getConstantVec("constant5")[2] = m_fresnelPower;
		}
		
		public function get ksColor():Number{
			return m_ksColor;
		}
		
		public function set ksColor(value:Number):void{
			
			
			if(m_specularMask == TextureMapDefaults.BLACK){
				m_ksColor = value;
			}else{
				m_ksColor = 0.0;
				kSpec = 0.0;
			}
			getConstantVec("constant4")[3] = m_ksColor;
		}
		
		public function get krColor():Number{
			return m_krColor;
		}
		
		public function set krColor(value:Number):void{
			m_krColor = value;
			getConstantVec("constant4")[2] = value;
		}
		
		public function get kRim():Number{
			return m_kRim;
		}
		
		public function set kRim(value:Number):void{
			m_kRim = value;
			getConstantVec("constant4")[1] = value;
		}
		
		public function get fRimPower():Number
		{
			return m_fRimPower;
		}
		
		public function set fRimPower(value:Number):void
		{
			m_fRimPower = value;
			getConstantVec("constant4")[0] = value;
		}
		
		public function get fspecPower():Number
		{
			return m_fspecPower;
		}
		
		public function set fspecPower(value:Number):void
		{
			m_fspecPower = value;
			getConstantVec("constant3")[3] = value;
		}
		
		public function get kSpec():Number
		{
			return m_kSpec;
		}
		
		public function set kSpec(value:Number):void
		{
			if(m_specularMap != TextureMapDefaults.BLACK)
				value = 0;
			m_kSpec = value;
			getConstantVec("constant3")[1] = value;
		}
		
		public function get color():Color
		{
			return m_color;
		}
		
		public function set color(value:Color):void
		{
			m_color = value;
			getConstantVec("constant2")[1] = m_color.r;
			getConstantVec("constant2")[2] = m_color.g;
			getConstantVec("constant2")[3] = m_color.b;
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
		
		public function get opacity():Number
		{
			return m_opacity;
		}
		
		public function set opacity(value:Number):void
		{
			m_opacity = value;
			getConstantVec("constant2")[0] = m_opacity;
		}
		
		
		/******************************************************************************************************
		 * Set/Get Textures
		 *****************************************************************************************************/
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
	}
}