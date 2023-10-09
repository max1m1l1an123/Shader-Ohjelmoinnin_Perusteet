Shader "Custom/CoordinateShader"
{
    Properties
    {
        [KeywordEnum(Object, World, View)] _Space("Type", Float) = 0
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
            #pragma vertex Vertex
            #pragma fragment Fragment
            #pragma shader_feature_local_vertex _SPACE_OBJECT _SPACE_WORLD _SPACE_VIEW
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/core.hlsl"

            float4 Vertex(float3 positionOS : POSITION) : SV_POSITION
            {
                float4 positionHCS;

                #if _SPACE_OBJECT
                positionHCS = TransformObjectToHClip(positionOS + float3(0,1,0));
                #elif _SPACE_WORLD
                const float3 positionWS = TransformObjectToWorld(positionOS) + float3(0,1,0);
                positionHCS = TransformWorldToHClip(positionWS);
                #elif _SPACE_VIEW
                const float3 positionVS = TransformWorldToView(TransformObjectToWorld(positionOS));
                positionHCS = TransformWViewToHClip(positionVS + float3(0,1,0));
                #endif
                
                return  positionHCS;
            }

            // --------------   v
            struct Attributes
            {
                float3 normalOS : NORMAL;
            };
            struct Varyings
            {
                float4 positionHCS : POSITION;
                float3 normalWS : TEXCOORD0;
            };
            half4 Fragment(const Varyings input) : SV_TARGET
            {
                float4 color = float4(1, 0.5, 0.3, 1);
                return color;
            }
            // --------------   ^
            ENDHLSL
        }
    }
}