Shader "Custom/TestShader"
{
    Properties {}

    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
            "Queue" = "Geometry"
        }


        Pass
        {
            Name "OmaPass"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            HLSLPROGRAM



        #pragma vertex Vert
        #pragma fragment Frag

        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/core.hlsl"

        struct Attributes
        {
             float3 positionOS : POSITION;
             
                float3 normalOS : NORMAL;
        };

        struct Varyings
        {
             float4 positionHCS : POSITION;
             
             float4 normalHCS : NORMAL;
        };

        Varyings Vert(const Attributes input)
        {
            Varyings output;
    
            output.positionHCS = TransformObjectToHClip(input.positionOS);
    
            return output;
        }

        half4 Frag(const Varyings input) : SV_TARGET
        {
            return half4(1, 0.5, 0.3, 1);
        }


        ENDHLSL
        }
    }
}