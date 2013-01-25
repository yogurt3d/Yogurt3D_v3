package com.yogurt3d.presets.material
{
	import com.yogurt3d.core.material.MaterialBase;
	import com.yogurt3d.core.material.agalgen.AGALGEN;
	import com.yogurt3d.core.material.agalgen.IRegister;
	import com.yogurt3d.core.material.enum.EBlendMode;
	import com.yogurt3d.core.material.enum.ERegisterShaderType;
	import com.yogurt3d.core.material.parameters.FragmentInput;
	import com.yogurt3d.core.material.parameters.SurfaceOutput;
	import com.yogurt3d.core.texture.ITexture;
	import com.yogurt3d.core.texture.TextureMap;
	import com.yogurt3d.utils.Color;
	import com.yogurt3d.utils.TextureMapDefaults;
	
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DTriangleFace;
	
	public class MaterialTexture extends MaterialBase{
		
		
		public function MaterialTexture(texture:ITexture = null, _opacity:Number=1.0){
			super();
			
			lightFunction = NoLight;
			surfaceFunction = mySurfaceFunction;
			vertexFunction = emptyFunction;
			
			params.depthFunction 	= Context3DCompareMode.LESS;
			params.writeDepth		= true;
			params.blendEnabled 	= true;
			params.blendMode.blendSource = Context3DBlendFactor.ONE;
			params.blendMode.blendDestination = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
			params.culling = Context3DTriangleFace.FRONT;
			
			ambientColor = new Color(0,0,0,1);
			emissiveColor = new Color(0,0,0,1);
			
			createConstantFromVector( ERegisterShaderType.FRAGMENT, "opacity", Vector.<Number>([1.0, 0.2, 0, 0]) );
			createConstantFromTexture( "colorMap", (texture)?texture:TextureMapDefaults.CHECKER_BOARD );
		}
		
		private function mySurfaceFunction( surfaceInput:FragmentInput, surfaceOutput:SurfaceOutput, gen:AGALGEN ):String{
			var temp:IRegister = gen.createFT( "temp1",4);
			var str:String = 
				["\n\n//****SurfaceFunction START****/",
					gen.tex( temp, surfaceInput.uvMain, getConstant("colorMap"), "2d", "wrap", "linear", (texture as TextureMap).mipmap, true, (texture as TextureMap).transparent, getConstant("opacity").y),
					gen.code("mul", temp.w, temp.w, getConstant("opacity").x),
					gen.code("mov",surfaceOutput.Albedo, temp.xyz),
					gen.code("mov",surfaceOutput.Alpha, temp.w),
					"\n\n//****SurfaceFunction END****/"
				].join("\n");
			
			gen.destroyFT("temp1");
			return str;
		}
		
		public function get opacity():Number{
			return getConstantVec("opacity")[0];
		}
		
		public function set opacity( value:Number ):void{
			getConstantVec("opacity")[0] = value;
		}
		
		public function get texture():ITexture {
			return getConstantTex("colorMap");
		}
		
		public function set texture(value:ITexture):void{
			if( value == null )
			{
				setConstantTex( "colorMap", TextureMapDefaults.CHECKER_BOARD );
			}else{
				setConstantTex( "colorMap", value );
			}
		}
	}

}