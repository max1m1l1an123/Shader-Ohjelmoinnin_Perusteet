Shader "Custom/NormalTextureShader"
{
    Properties
    {
        _MainTex("Main Texture", 2D) = "white" {}
        _NormalMap("Normal Map", 2D) = "white" {}
        _Shininess("Shininess", Range(1, 512)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline" = "UniversalPipeline" "Queue" = "Geometry" }
        
        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            TEXTURE2D(_NormalMap);
            SAMPLER(sampler_NormalMap);
            
            CBUFFER_START(UnityPerMaterial)
            float _Shininess;
            float4 _MainTex_ST;
            float4 _NormalMap_ST;
            CBUFFER_END
            
            struct Attributes
            {
                float4 tangentOS : TANGENT;
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float4 normalOS : NORMAL;
            };
            
            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 positionWS : TEXCOORD1;

                float3 normalWS : TEXCOORD2;
                float3 tangentWS : TEXCOORD3;
                float3 bitangentWS : TEXCOORD4;
            };
            
            Varyings vert (Attributes input)
            {
                Varyings output;

                const VertexPositionInputs position_inputs = GetVertexPositionInputs(input.positionOS);
                const VertexNormalInputs normal_inputs = GetVertexNormalInputs(input.normalOS, input.tangentOS);

                output.positionHCS = position_inputs.positionCS;
                output.positionWS = position_inputs.positionWS;
                output.normalWS = normal_inputs.normalWS;
                output.tangentWS = normal_inputs.tangentWS;
                output.bitangentWS = normal_inputs.bitangentWS;

                output.uv = input.uv * _MainTex_ST.xy + _MainTex_ST.zw;
                
                return output;
            }

            float4 BlinnPhong(const Varyings input, float4 color)
            {
                const Light mainLight = GetMainLight();
                const float3 ambientLight = 0.1 * mainLight.color;
                const float3 diffuseLight = saturate(dot(input.normalWS, mainLight.direction)) * mainLight.color;
                const float3 viewDir = GetWorldSpaceNormalizeViewDir(input.positionWS);
                const float3 halfwayDir = normalize(mainLight.direction + viewDir);
                const float3 specularLight = pow(saturate(dot(input.normalWS, halfwayDir)), _Shininess) * mainLight.color;
                return float4((ambientLight + diffuseLight + specularLight * 10) * color.rgb, 1);
            }
            
            float4 frag (Varyings input) : SV_TARGET
            {
                const float4 color1 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, TRANSFORM_TEX(input.uv, _MainTex));
                const float3 normalTS = UnpackNormal(SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, TRANSFORM_TEX(input.uv, _MainTex)));
                const float3x3 TangentToWorld = float3x3(input.tangentWS, input.bitangentWS, input.normalWS);
                
                const float3 normalWS = TransformTangentToWorld(normalTS, TangentToWorld, true);
                input.normalWS = normalWS;                
                
                return BlinnPhong(input, color1);
            }
            ENDHLSL
        }
        // --------------  DepthOnly pass v
        Pass
        {
            Name "Depth"
            Tags
            {
                "LightMode" = "DepthOnly"
            }

            Cull Back
            ZTest LEqual
            ZWrite On
            ColorMask R

            HLSLPROGRAM
            #pragma vertex DepthVert
            #pragma fragment DepthFrag

            #include "DepthPass.hlsl"
            ENDHLSL
        }
        // --------------  DepthOnly pass        ^
        // --------------  DepthNormalsOnly pass v
        Pass
        {
            Name "Normals"
            Tags
            {
                "LightMode" = "DepthNormalsOnly"
            }

            Cull Back
            ZTest LEqual
            ZWrite On

            HLSLPROGRAM
            #pragma vertex DepthNormalsVert
            #pragma fragment DepthNormalsFrag

            #include "DepthNormalsPass.hlsl"
            ENDHLSL
        }
        // --------------  DepthNormalsOnly pass ^
    }
}