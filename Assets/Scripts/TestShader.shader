Shader "Custom/TestShader"
{
    Properties
    {
        _MaterialColor ("Color", Color) = (1, 0.5, 0.3, 1)
    }

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

                float3 normalWS : TEXCOORD0;
            };

            Varyings Vert(const Attributes input)
            {
                Varyings output;

                output.positionHCS = TransformObjectToHClip(input.positionOS);

                output.normalWS = TransformObjectToWorldNormal(input.normalOS);

                return output;
            }

            half4 Frag(const Varyings input) : SV_TARGET
            {
                // return half4(1, 0.5, 0.3, 1);

                // -------------- trying to return _MaterialColor  v
                // half4 color = tex2D(input)._MaterialColor;
                // return color;
                // -------------- trying to return _MaterialColor  ^
                
                half4 color = 0;
                color.rgb = input.normalWS * 0.5 + 0.5;
                return color;
            }
            ENDHLSL
        }
    }
}