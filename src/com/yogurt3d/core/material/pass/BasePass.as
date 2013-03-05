/*
 * BasePass.as
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

package com.yogurt3d.core.material.pass
{
    import com.yogurt3d.core.material.MaterialBase;
    import com.yogurt3d.core.material.agalgen.IRegister;
    import com.yogurt3d.core.material.enum.EBlendMode;
    import com.yogurt3d.core.material.enum.ERegisterShaderType;
    import com.yogurt3d.core.material.parameters.FragmentInput;
    import com.yogurt3d.core.material.parameters.LightInput;
    import com.yogurt3d.core.sceneobjects.lights.Light;
    import com.yogurt3d.utils.ShaderUtils;

    import flash.display3D.Context3DCompareMode;
    import flash.display3D.Context3DProgramType;
    import flash.display3D.Context3DTriangleFace;
    import flash.utils.ByteArray;

    public class BasePass extends Pass
    {
        public function BasePass()
        {
            super();

            m_surfaceParams.blendEnabled = true;
            m_surfaceParams.blendMode = EBlendMode.ALPHA;

            m_surfaceParams.writeDepth = true;
            m_surfaceParams.depthFunction = Context3DCompareMode.LESS;

            m_surfaceParams.culling = Context3DTriangleFace.FRONT;

            createConstantFromVector( ERegisterShaderType.FRAGMENT, "yAmbientCol", m_ambientColor.getColorVectorRaw());
            createConstantFromVector( ERegisterShaderType.FRAGMENT, "yEmmisiveCol", m_emissiveColor.getColorVectorRaw());
        }

        public override function getFragmentShader(_light:Light):ByteArray{
            gen.destroyAllTmp();

            m_vertexOutput = new FragmentInput(gen);
            var surfaceOutput:LightInput = new LightInput(gen);

            var surface:String = surfaceFunction( m_vertexOutput as FragmentInput, surfaceOutput, gen );

            var resultAmb:IRegister = gen.createFT("resultAmb",4);
            var ambient:String = [
                gen.code("mov", resultAmb, gen.FC["yEmmisiveCol"]),
                gen.code("add", resultAmb, resultAmb, gen.FC["yAmbientCol"])
            ].join("\n");


            var light:String;
            if( _light == null )
            {
                light = MaterialBase.NoLight(surfaceOutput,gen);
            }else{
                light = lightFunction(surfaceOutput,gen);
            }

            var code:String = "//*****PIXEL SHADER - BasePass*****//\n";

            code += generateNeededCalculations(_light, surfaceOutput);

            //code += ambient + surface + light;
            code += surface + light;
            //code += gen.code("add", gen.FT["result"].xyz, gen.FT["result"].xyz, resultAmb.xyz);

            code += "\n//Move result to output\n";
            code += "mov oc " + gen.FT["result"];

//			trace("[Base Pass] FRAGMENT SHADER");
//			trace(code);
//			trace("[Base Pass] END FRAGMENT SHADER");

            return ShaderUtils.vertexAssambler.assemble(Context3DProgramType.FRAGMENT, code, false );

        }
    }
}