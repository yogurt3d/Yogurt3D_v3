package com.yogurt3d.presets.material
{
import com.yogurt3d.core.material.MaterialBase;
import com.yogurt3d.core.material.agalgen.AGALGEN;
import com.yogurt3d.core.material.enum.EBlendMode;
import com.yogurt3d.core.material.enum.ERegisterShaderType;
import com.yogurt3d.core.material.parameters.FragmentInput;
import com.yogurt3d.core.material.parameters.SurfaceOutput;
import com.yogurt3d.utils.Color;

import flash.display3D.Context3DTriangleFace;

public class MaterialFill extends MaterialBase{
		
		private var m_color:Color;
		
		public function MaterialFill(_color:uint=0xFFFFFF, _opacity:Number=1.0){
			super();
			
			lightFunction = NoLight;
			surfaceFunction = mySurfaceFunction;
			vertexFunction = emptyFunction;
			
			params.writeDepth		= true;
			params.blendEnabled 	= true;
			params.blendMode = EBlendMode.ALPHA;
			params.culling = Context3DTriangleFace.FRONT;
			
			
			var _colorVec:Vector.<Number> = new Vector.<Number>;
			_colorVec[0] = (_color >> 16 & 255 ) / 255;
			_colorVec[1] = (_color >> 8 & 255) / 255;
			_colorVec[2] = (_color & 255) / 255;
			
			createConstantFromVector( ERegisterShaderType.FRAGMENT, "color", Vector.<Number>([_colorVec[0], _colorVec[1], _colorVec[2], _opacity]) );

			 opacity = _opacity;
		}
		
		private function mySurfaceFunction( surfaceInput:FragmentInput, surfaceOutput:SurfaceOutput, gen:AGALGEN ):String{

			var str:String = "\n//****SurfaceFunction START: MaterialFill****/"+ "\n";
			
			str += "mov " + surfaceOutput.Albedo + " " + getConstant("color").xyz + "\n";
			str += "mov " + surfaceOutput.Alpha + " " + getConstant("color").w + "\n";
			
			str += "//****SurfaceFunction END****/"+ "\n";
			return str;
		}
		
		public function get color():Color{
			return m_color;
		}
		
		public function set color(_color:Color):void{
			m_color = _color;
			getConstantVec("color")[0] = m_color.r;
			getConstantVec("color")[1] = m_color.g;
			getConstantVec("color")[2] = m_color.b;
		}
		
		public function get opacity( ):Number{
			return getConstantVec("color")[3];
		}
		
		public function set opacity( value:Number ):void{
			getConstantVec("color")[3] = value;
			transparent = (value < 1.0);
			
		}
		
	}

}