package com.yogurt3d.presets.material.yogurtistan
{
	import com.yogurt3d.core.material.agalgen.IRegister;
	import com.yogurt3d.core.sceneobjects.camera.Camera3D;
	import com.yogurt3d.core.geoms.SkeletalAnimatedMesh;
	import com.yogurt3d.core.geoms.SkinnedSubMesh;
	import com.yogurt3d.core.geoms.SubMesh;
	import com.yogurt3d.core.geoms.IMesh;
	import com.yogurt3d.core.sceneobjects.lights.Light;
	import com.yogurt3d.core.material.Y3DProgram;
	import com.yogurt3d.core.material.enum.EBlendMode;
	import com.yogurt3d.core.material.enum.ERegisterShaderType;
	import com.yogurt3d.core.material.parameters.FragmentInput;
	import com.yogurt3d.core.material.parameters.VertexInput;
	import com.yogurt3d.core.material.parameters.VertexOutput;
	import com.yogurt3d.core.material.pass.Pass;
	import com.yogurt3d.core.sceneobjects.SceneObjectRenderable;
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
	import flash.display3D.VertexBuffer3D;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import com.yogurt3d.YOGURT3D_INTERNAL;

	public class YogurtistanPassAvatar extends Pass
	{
		private var m_specColor				:Color;
		private var m_blendConstant			:Number;
		private var m_opacity				:Number;	
		private var m_specular				:Number;
		private var m_shineness				:Number;
		private var m_rim					:Number;
		private var m_rimShineness			:Number;
		private var m_fspecPower			:Number;
		private var m_fRimPower				:Number;
		
		private var m_gradient				:TextureMap;
		private var m_emmisiveMask			:TextureMap;
		private var m_colorMap				:TextureMap;
		private var m_specularMap			:TextureMap; 
		private var m_shinenessMask			:TextureMap;
		
		
		public function YogurtistanPassAvatar(_gradient:TextureMap,
											  _emmisiveMask:TextureMap=null,
											  _colorMap:TextureMap=null,
											  _specularMap:TextureMap=null,
											  _shinenessMask:TextureMap=null,
											  _specularColor:Color=null,
											  _specular:Number=1.0,
											  _shineness:Number=1.0,
											  _rimShineness:Number=1.0,
											  _rim:Number=1.0,
											  _blendConstant:Number=1.0,
											  _fspecPower:Number=1.0,
											  _fRimPower:Number=2.0,
											  _opacity:Number=1.0)
		{
			m_surfaceParams.blendEnabled = true;
			m_surfaceParams.blendMode = EBlendMode.ALPHA;
			
			m_surfaceParams.writeDepth = true;
			m_surfaceParams.depthFunction = Context3DCompareMode.LESS;
			m_surfaceParams.culling = Context3DTriangleFace.FRONT;
			
		
			if(_specularColor == null)
				m_specColor = new Color(1,1,1,1);
			
			m_opacity = _opacity;
			m_blendConstant = _blendConstant;
			m_fspecPower = _fspecPower;
			m_fRimPower = _fRimPower;
			m_shineness = _shineness;
			m_rim = _rim;
			m_rimShineness = _rimShineness;
			m_specular = _specular;
			
			m_gradient = _gradient;
			m_colorMap = (_colorMap)?_colorMap:TextureMapDefaults.WHITEMIPMAP;
			m_shinenessMask = (_shinenessMask)?_shinenessMask:TextureMapDefaults.BLACKMIPMAP;
			m_specularMap = (_specularMap)?_specularMap:TextureMapDefaults.BLACKMIPMAP;
			m_emmisiveMask = (_emmisiveMask)?_emmisiveMask:TextureMapDefaults.BLACKMIPMAP;
	
			if(m_specularMap != TextureMapDefaults.BLACKMIPMAP)
				m_specular = 0;
			
			if(m_shinenessMask != TextureMapDefaults.BLACKMIPMAP)
				m_shineness = 0.0;
			
			createConstantFromVector( ERegisterShaderType.FRAGMENT, "constant1", Vector.<Number>([ 0.0, 0.5, 1.0, m_opacity ]));
			createConstantFromVector( ERegisterShaderType.FRAGMENT, "constant2", Vector.<Number>([ m_blendConstant, 0.1, 200, m_fspecPower ]));
			createConstantFromVector( ERegisterShaderType.FRAGMENT, "constant3", Vector.<Number>([ 0.00000001, m_fRimPower, m_shineness, m_rim ]));
			createConstantFromVector( ERegisterShaderType.FRAGMENT, "constant4", Vector.<Number>([ m_rimShineness, m_specColor.r, m_specColor.g, m_specColor.b ]));
			createConstantFromVector( ERegisterShaderType.FRAGMENT, "constant5", Vector.<Number>([ m_specular, 0, 0, 0]));
			
			createConstantFromTexture(ERegisterShaderType.FRAGMENT, "gradient", m_gradient );
			createConstantFromTexture(ERegisterShaderType.FRAGMENT, "colorMap", m_colorMap );
			createConstantFromTexture(ERegisterShaderType.FRAGMENT, "shineMask", m_shinenessMask);
			createConstantFromTexture(ERegisterShaderType.FRAGMENT, "specMap", m_specularMap);
			createConstantFromTexture(ERegisterShaderType.FRAGMENT, "emissiveMask", m_emmisiveMask);
		
			
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
			m_vsManager.setTexture(device, m_constants["gradient"].register.index, m_gradient.getTextureForDevice(device) );
			m_vsManager.setTexture(device, m_constants["colorMap"].register.index, m_colorMap.getTextureForDevice(device) );
			m_vsManager.setTexture(device, m_constants["shineMask"].register.index, m_shinenessMask.getTextureForDevice(device) );
			m_vsManager.setTexture(device, m_constants["specMap"].register.index, m_specularMap.getTextureForDevice(device) );
			m_vsManager.setTexture(device, m_constants["emissiveMask"].register.index, m_emmisiveMask.getTextureForDevice(device) );
		
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
			
			_device.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			_device.setColorMask( m_surfaceParams.colorMaskR, m_surfaceParams.colorMaskG, m_surfaceParams.colorMaskB, m_surfaceParams.colorMaskA);
			_device.setDepthTest( m_surfaceParams.writeDepth, m_surfaceParams.depthFunction );
			_device.setCulling( m_surfaceParams.culling );
			
			preRender(_device, _object, _camera);
			
			
			var _mesh:IMesh = _object.geometry;
			for( var submeshindex:uint = 0; submeshindex < _mesh.subMeshList.length; submeshindex++ )
			{
				var subMesh:SubMesh = _mesh.subMeshList[submeshindex];
				var _skinnedsubmesh:SkinnedSubMesh = subMesh as SkinnedSubMesh
				if( _skinnedsubmesh != null )
				{
					for( var boneIndex:int = 0; boneIndex < _skinnedsubmesh.originalBoneIndex.length; boneIndex++)
					{	
						var originalBoneIndex:uint = _skinnedsubmesh.originalBoneIndex[boneIndex];
						_device.setProgramConstantsFromVector( Context3DProgramType.VERTEX, gen.VC["BoneMatrices"].index  + (boneIndex*3), SkeletalAnimatedMesh(_object.geometry).bones[originalBoneIndex].transformationMatrix.rawData, 3 );
					}
				}
			
				m_vsManager.markVertex(_device);
				
				m_vsManager.setStream( _device,  m_vertexInput.YOGURT3D_INTERNAL::m_vertexpos.index, subMesh.getPositonBufferByContext3D(_device),0, Context3DVertexBufferFormat.FLOAT_3);
				m_vsManager.setStream( _device,  m_vertexInput.YOGURT3D_INTERNAL::m_normal.index, subMesh.getNormalBufferByContext3D(_device),0, Context3DVertexBufferFormat.FLOAT_3);
				m_vsManager.setStream( _device,  m_vertexInput.YOGURT3D_INTERNAL::m_uvMain.index, subMesh.getUVBufferByContext3D(_device),0, Context3DVertexBufferFormat.FLOAT_2);
				
			
				var skinnedSubmesh:SkinnedSubMesh = subMesh as SkinnedSubMesh;
				var buffer:VertexBuffer3D = skinnedSubmesh.getBoneDataBufferByContext3D(_device);
				m_vsManager.setStream( _device, m_vertexInput.YOGURT3D_INTERNAL::m_boneData.index,   buffer, 0, Context3DVertexBufferFormat.FLOAT_4 );
				m_vsManager.setStream( _device, m_vertexInput.YOGURT3D_INTERNAL::m_boneData.index+1, buffer, 4, Context3DVertexBufferFormat.FLOAT_4 );
				m_vsManager.setStream( _device, m_vertexInput.YOGURT3D_INTERNAL::m_boneData.index+2, buffer, 8, Context3DVertexBufferFormat.FLOAT_4 );
				m_vsManager.setStream( _device, m_vertexInput.YOGURT3D_INTERNAL::m_boneData.index+3, buffer, 12,Context3DVertexBufferFormat.FLOAT_4 );
				m_vsManager.sweepVertex(_device);
				_device.drawTriangles(subMesh.getIndexBufferByContext3D(_device), 0, subMesh.triangleCount);
			}
		
			postRender(_device);
		}
		
		public override function getVertexShader(isSkeletal:Boolean):ByteArray{
			
			var input:VertexInput = m_vertexInput = new VertexInput(gen);
			var out:VertexOutput = m_vertexOutput;
			var vt1:IRegister = gen.createVT("vt1",4);
			var vt2:IRegister = gen.createVT("vt2",4);
			var vt3:IRegister = gen.createVT("vt3",4);
			var vt4:IRegister = gen.createVT("boneResult",4);
			var vt5:IRegister = gen.createVT("vt5",4);
			var vt6:IRegister = gen.createVT("vt6",4);
			
			gen.createVC("Model",4);
			gen.createVC("ViewProjection",4);
			gen.createVC("BoneMatrices",4);
			
			var posVec3:Array = [vt3.x, vt3.y, vt3.z, vt3.w];
			var posVec2:Array = [vt2.x, vt2.y, vt2.z, vt2.w];
			
			var code:String = [
				
				gen.code("mov", vt2, "va"+(input.boneData.index+1)), 
				gen.code("mov", vt2, input.boneData), // bone Indices
				
				gen.code("mov", vt3, "va"+(input.boneData.index+3)), 
				gen.code("mov", vt3, "va"+(input.boneData.index+2)) // bone Weight
				
			].join("\n") + "\n";
			
			for( var i:int = 0; i < 8; i++ )
			{
				code += gen.code("mul", vt1 ,posVec3[ i % 4 ], "vc[" + posVec2[ i % 4 ] + "+"+gen.VC["BoneMatrices"].index+"]") + "\n";
				
				if( i == 0 )
				{
					code += gen.code("mov", vt4, vt1)+ "\n";	
				}else{
					code += gen.code("add", vt4, vt1, vt4)+ "\n";
				}	
				
				code += gen.code("mul", vt1, posVec3[ i % 4 ], "vc[" + posVec2[ i % 4 ] + "+"+(gen.VC["BoneMatrices"].index+1)+"]")+ "\n";
				
				if( i == 0 )
				{
					code += gen.code("mov", vt5, vt1)+ "\n";
				}else{
					code += gen.code("add", vt5, vt1, vt5)+ "\n";
				}
				
				code += gen.code("mul", vt1, posVec3[ i % 4 ], "vc[" + posVec2[ i % 4 ] + "+"+(gen.VC["BoneMatrices"].index+2)+"]")+ "\n";
				
				if( i == 0 )
				{
					code += gen.code("mov", vt6, vt1)+ "\n";
				}else{
					code += gen.code("add", vt6, vt1, vt6)+ "\n";
				}
				
				if( i == 3 )
				{
					code += [
						gen.code("mov", vt2, "va"+(input.boneData.index + int( ( i + 1 ) / 4 ))),
						gen.code("mov", vt3, "va"+(input.boneData.index + 2 +int( ( i + 1 ) / 4 ))),
					].join("\n")+ "\n";
				}
			}
			
			code += "\n";
			
			gen.destroyVT("vt1");
			gen.destroyVT("vt2");
			gen.destroyVT("vt3");
			gen.destroyVT("vt5");
			gen.destroyVT("vt6");
			
			var worldPos:IRegister = gen.createVT("worldPos",4);
			var normalTemp:IRegister = gen.createVT("normTemp",3);
			
			code += [
				"//Calculate world pos",
				gen.code("m34", worldPos.xyz, input.vertexpos, vt4),
				gen.code("mov", worldPos.w, input.vertexpos.w),
				gen.code("m44", worldPos, worldPos, gen.VC["Model"]),
				gen.code("mov", out.worldPos, worldPos),
				"//Screen Pos",
				gen.code("m44", "op", worldPos, gen.VC["ViewProjection"]),	
				
				"//Calculate normals",
				gen.code("m33",normalTemp, input.normal.xyz, vt4),
				gen.code("m33",normalTemp, normalTemp, gen.VC["Model"]),
				gen.code("nrm",normalTemp, normalTemp),
				gen.code("mov",out.normal.xyz, normalTemp),
				gen.code("mov",out.normal.w, input.normal.w),		
				"//UV",
				gen.code("mov", out.uvMain, input.uvMain )
				
			].join("\n");
			
//			trace("VERTEX FUNCTION");
//			trace(gen.printCode( code ));
//			trace("---------------------------");
			
			return ShaderUtils.vertexAssambler.assemble(Context3DProgramType.VERTEX, code, false );
		}
		
		public override function getFragmentShader(_light:Light):ByteArray{
			gen.destroyAllTmp();
			m_vertexOutput = new FragmentInput(gen);
			
			var camPos:IRegister 	= gen.FC["cameraPos"];
			var lightDir:IRegister 	= gen.FC["lightDir"];
			var lightCol:IRegister 	= gen.FC["lightColor"];
			
			var zero:String 		= gen.FC["constant1"].x;
			var half:String 		= gen.FC["constant1"].y;
			var one:String 			= gen.FC["constant1"].z;
			var opacity:String 		= gen.FC["constant1"].w;
			
			var up:String			= gen.FC["constant1"].xzx;
			var bconst:String		= gen.FC["constant2"].x; 
			
			var fspecPow:String 	= gen.FC["constant2"].w;
			var approx:String 		= gen.FC["constant3"].x;
			var fRimPow:String		= gen.FC["constant3"].y;
			var shine:String 		= gen.FC["constant3"].z;

			var riM:String			= gen.FC["constant3"].w;
			var riMShine:String		= gen.FC["constant4"].x;
			var specCol:String		= gen.FC["constant4"].yzw;
			var spec:String			= gen.FC["constant5"].x;
			
			var worldPos:IRegister 	= m_vertexOutput.worldPos;
			var normal:IRegister 	= m_vertexOutput.normal;
			var uv:IRegister 		= m_vertexOutput.uvMain;
			
			var view:IRegister 		= gen.createFT("view", 4);
			var temp1:IRegister 	= gen.createFT("temp1", 4);
			var temp2:IRegister 	= gen.createFT("temp2", 4);
			var temp3:IRegister 	= gen.createFT("temp3", 4);
			var temp4:IRegister 	= gen.createFT("temp4", 4);
			var temp5:IRegister 	= gen.createFT("temp5", 4);
			var result:IRegister 	= gen.createFT("result", 4);
			
			var code:String = [
				
				// VIEW DEPENDENT 
				// specColor * lightColor * ks * max(fs*(pow v.r, (shine OR shinemask)), fr*rim* (pow v.r, rimShine))
				
				gen.code("mov", temp5, normal),			 				// Normal = N
				gen.code("nrm", temp5.xyz, temp5.xyz),	 				// norm(N)
				
				gen.code("sub", view, camPos, worldPos), 				// View Vector = V
				gen.code("nrm", view.xyz, view.xyz), 
			
				gen.fresnel(temp1.x, temp5, view, fspecPow, one), 		// fs
				gen.fresnel(temp1.y, temp5, view, fRimPow, one), 		// fr
				
				gen.reflectionVector(temp2, temp5, lightDir),			// Reflection vector = R
				gen.code("dp3", temp1.z, view.xyz, temp2.xyz),			// V.R
				gen.code("max", temp1.z, temp1.z, zero),			    // V.R
				
				// fs*(pow v.r, (shine OR shinemask))
				gen.tex(temp2, uv, gen.FS["shineMask"], "2d", "wrap", "linear", true),
				gen.code("mul", temp2.x, temp2.x, gen.FC["constant2"].z), 		// 200 * shineMask
				gen.code("add", temp2.x, temp2.x, shine),  						// 200 * shineMask + shinness
				gen.code("pow", temp2.x, temp1.z, temp2.x),						// pow (v.r, (200 * shineMask + shinness))
				gen.code("max", temp2.x, zero, temp2.x),   						// max(pow (v.r, (200 * shineMask + shinness)) , 0 )
				gen.code("mul", temp2.x, temp2.x, temp1.x),						// fs * pow (v.r, shine) 
				
				// fr * rim * (pow v.r, rimShine)
				gen.code("pow", temp2.y, temp1.z, riMShine), // (pow v.r, rimShine)
				gen.code("max", temp2.y, zero, temp2.y),     // max(0, (pow v.r, rimShine)
				gen.code("mul", temp1.y, temp1.y, riM),		 // fr * kr
				gen.code("mul", temp2.y, temp2.y, temp1.y),	 // fr * kr * (pow v.r, rimShine)
		
				// max(fs*(pow v.r, (shine OR shinemask)), fr*rim* (pow v.r, rimShine))
				gen.code("max", temp2.x, temp2.x, temp2.y),
				
				// max(fs*(pow v.r, (shine OR shinemask)), fr*rim* (pow v.r, rimShine)) * lighCol
				gen.code("mul", result, lightCol, temp2.x),
				
				// max(fs*(pow v.r, (shine OR shinemask)), fr*rim* (pow v.r, rimShine)) * specCol * lighCol
				gen.code("mul", result, result, specCol),
				
				// specularmap & specular
				gen.tex(temp2, uv, gen.FS["specMap"], "2d", "wrap", "linear", true),
				gen.code("add", temp2.x, temp2.x, temp2.x),
				gen.code("add", temp2.x, temp2.x, spec),
				
				// max(fs*(pow v.r, (shine OR shinemask)), fr*rim* (pow v.r, rimShine)) * specCol * lighCol * specular
				gen.code("mul", result, result, temp2.x),
				
				// View - Independent
				
				// Step 1: ambient term a((dot(n.u) + 1.0) * 0.5 )
				gen.code("dp3", temp1.z, temp5.xyz, up), 
				gen.code("add", temp1.z, temp1.z, one), // dot(n.u) + 1.0
				gen.code("mul", temp3.x, temp1.z, half), // temp3.x = (dot(n.u) + 1.0) * 0.5
				gen.code("mov", temp3.y, one),
				gen.tex(temp4, temp3.xy, gen.FS["gradient"], "2d", "clamp", "linear"), //temp4 = a(dot(n.u) + 1.0) * 0.5)
				
				// CASE:((dot(n.u) + 1.0) * 0.5 ) * fr * kr * a(dot(n.u) + 1.0) * 0.5)
				gen.code("mul", temp1.y, temp1.y, temp3.x), //(dot(n.u) + 1.0) * 0.5 ) * fr * kr 
				gen.code("mul", temp1, temp4, temp1.y), // (dot(n.u) + 1.0) * 0.5 ) * fr * kr * a(dot(n.u) + 1.0) * 0.5)
				gen.code("add", result, temp1, result), // (dot(n.u) + 1.0) * 0.5 ) * fr * kr * a(dot(n.u) + 1.0) * 0.5) + ViewDependent
				
				
				// Step 1 : Half Lambert Term
				gen.code("dp3", temp1.x, temp5.xyz, lightDir.xyz), 		// temp1.x = dot(N.L)
				gen.code("mul", temp1.y, temp1.x, half),				// dot(N.L) * 0.5
				gen.code("add", temp1.y, temp1.y, half),				// lambert = dot(N.L) * 0.5 + 0.5
				
				// Step 2: Warping (lambert)
				gen.code("mov", temp1.x, zero),
				gen.tex(temp2, temp1.yx, gen.FS["gradient"], "2d", "clamp", "linear"),
				
				// Step 3: color of light * blendConst * Warping (lambert)
				gen.code("mul", temp2, temp2, lightCol), // w * lightCol
				gen.code("mul", temp2, temp2, bconst),  // w * lightCol * blendConst
				
				// a((dot(n.u) + 1.0) * 0.5 ) + w *lightColor*blendConst
				gen.code("add", temp2, temp2, temp4), 
			
				// Step 5: Get Color map
				gen.tex(temp1, uv, gen.FS["colorMap"], "2d", "wrap", "linear", true, true, true, gen.FC["constant2"].y),
				gen.code("mul", temp1, temp1, temp2),
				
				gen.code("add", result, temp1, result),
			
				// Add Emmisive Map
				gen.tex(temp2, uv, gen.FS["emissiveMask"], "2d", "wrap", "linear", true),
				gen.code("add", result, temp2, result),
				
				
				gen.code("mov", result.w, opacity),
				gen.code("mov", "oc", result),
//				// View Dependent
//				// Step 6: Phong Specular Term
//				gen.reflectionVector(temp2, lightDir, normal),				// R = reflect vector (L, N)	
//				gen.code("sub", view, camPos, worldPos), 						// View Vector = V
//				gen.code("nrm", view.xyz, view.xyz), 							// norm(V)
//				gen.code("dp3", temp1.z, view, temp2),						// dot(v.r)
//				
//				gen.tex(temp2, uv, gen.FS["specMap"], "2d", "wrap", "linear", m_specularMap.mipmap),
//				gen.code("mul", temp2.x, temp2.x, gen.FC["constant2"].z),
//				gen.code("add", temp2.x, temp2.x, gen.FC["constant2"].w),	// kspec = if there is specular map, get it from it else get from kSpec
//				gen.code("pow", temp2.x, temp1.z, temp2.x), 					// kspec = pow(dot(v.r), kspec)
//				
//				// if L.n > 0 max (0, pow(dot(n.l), kspec))
//				gen.code("max", temp2.y, zero, temp2.x), 						//max (0, pow(dot(n.l), kspec))
//				gen.code("sge", temp5.y, temp1.z, approx), 					// dot(v.r) >= 0.0000001
//				gen.code("mul", temp2.y, temp2.y, temp5.y), 					// temp2.y = phong specular term
//				
//				gen.fresnel(temp2.z, normal, view, fspecPow, one), 			//fs = DFT
//				gen.code("add", temp2.z , temp2.z, half),						// fs = DFT + 0.5
//				gen.code("mul", temp2.z, temp2.z, temp2.y), 					// fs * phong specular term
//				
//				gen.code("pow", temp2.w, temp1.z, krim),						//pow(dot(v.r), krim)
//				gen.code("max", temp2.w, temp2.w, zero),						// max (0, pow(dot(v.r), krim))
//				gen.code("mul", temp2.w, temp5.y, temp2.w), 					// temp2.w = rim specular
//				
//				// temp3 =amb  result = independent result,  temp2.y temp2.w temp1 = free 
//				gen.fresnel(temp1.x, normal, view, fRimPow, one),
//				gen.tex(temp4, uv, gen.FS["rimMask"], "2d", "wrap", "linear", m_rimMask.mipmap),
//				gen.code("add", temp4.x, temp4.x, temp4.x),
//				gen.code("add", temp4.x, temp4.x, krCol),
//				
//				gen.code("mul", temp1.x, temp1.x, temp4.x),					// fr * kr
//				gen.code("mul", temp1.y, temp1.x, temp2.w), 					//   fr * kr * rim spec
//				
//				gen.code("max", temp1.z, temp2.z, temp1.y),
//				gen.code("mul", temp4, lightCol, temp1.z),
//				
//				
//				gen.tex(view, uv, gen.FS["specMask"], "2d", "wrap", "linear", m_specularMask.mipmap),
//				gen.code("add", view.x, view.x, view.x),
//				gen.code("add", view.x, view.x, ksCol),
//				
//				gen.code("mul", temp4, temp4, view.x),
//				
//				gen.code("mul", temp3, temp1.x, temp3),//ambien based view dependent
//				gen.code("mul", temp3, temp5.x, temp3),
//				
//				gen.code("add", temp4, temp4, temp3),
//				gen.code("add", result, result, temp4),
//				
//				gen.tex(temp2, uv, gen.FS["emissiveMask"], "2d", "wrap", "linear", m_emmisiveMask.mipmap),
//				gen.code("add", result.xyz, result.xyz, temp2.xyz),
				
			//	gen.code("mov", result.w, opacity),
			//	gen.code("mov", "oc", result)

			].join("\n");
			
//			trace("FRAGMENT FUNCTION");
//			trace(gen.printCode( code ));
//			trace("---------------------------");
			return ShaderUtils.fragmentAssambler.assemble(Context3DProgramType.FRAGMENT, code, false );
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
			getConstantVec("constant4")[1] = m_specColor.r;
			getConstantVec("constant4")[2] = m_specColor.g;
			getConstantVec("constant4")[3] = m_specColor.b;
		}
		
		public function get specular():Number{
			return m_specular;
		}
		
		public function set specular(_value:Number):void{
			if(m_specularMap != TextureMapDefaults.BLACKMIPMAP)
				_value = 0;
			m_specular = _value;
			getConstantVec("constant5")[0] = m_specular;
		}
		
		public function get shineness():Number{
			return m_shineness;
		}
		
		public function set shineness(_value:Number):void{
			if(m_shinenessMask != TextureMapDefaults.BLACKMIPMAP)
				_value = 0;
			m_shineness = _value;
			getConstantVec("constant3")[2] = m_shineness;
		}

		public function get rim():Number{
			return m_rim;
		}
		
		public function set rim(value:Number):void{
			m_rim = value;
			getConstantVec("constant3")[3] = m_rim;
		}
		
		public function get rimShineness():Number{
			return m_rimShineness;
		}

		public function set rimShineness(value:Number):void{
			m_rimShineness = value;
			getConstantVec("constant4")[0] = m_rimShineness;
		}
		
		public function get fRimPower():Number
		{
			return m_fRimPower;
		}
		
		public function set fRimPower(value:Number):void
		{
			m_fRimPower = value;
			getConstantVec("constant3")[1] = m_fRimPower;
		}

		public function get fspecPower():Number
		{
			return m_fspecPower;
		}
		
		public function set fspecPower(value:Number):void
		{
			m_fspecPower = value;
			getConstantVec("constant2")[3] = m_fspecPower;
		}
		
		public function get blendConstant():Number{
			return m_blendConstant;
		}
		
		public function set blendConstant(_value:Number):void{
			m_blendConstant = _value;
			getConstantVec("constant2")[0] = m_blendConstant;
		}
		
		public function get opacity():Number
		{
			return m_opacity;
		}
		
		public function set opacity(value:Number):void
		{
			m_opacity = value;
			getConstantVec("constant1")[3] = m_opacity;
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
		
		public function get shinenessMask():TextureMap
		{
			return m_shinenessMask;
		}
				
		public function set shinenessMask(value:TextureMap):void
		{
			if(value){
				m_shinenessMask = value;
			}else{
				m_shinenessMask = TextureMapDefaults.BLACKMIPMAP;
			}
			
			shineness = m_shineness;
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
				m_emmisiveMask = TextureMapDefaults.BLACKMIPMAP;
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
	
	}
}