Shader "Custom/ProperShader"
{
    Properties
    {
        [MainColor] _Color ("Color", Color) = (0.5566214,0.8018868,0.4190993,1)
        [MainTexture] _Texture("Texture", 2D) = "black" {}
        
        [NoScaleOffset] [Normal] _NormalMap("Normal Map", 2D) = "bump" { }
        [NoScaleOffset] _RoughnessMap("Roughness Map", 2D) = "white" { }
        [NoScaleOffset] _OcclusionMap("Ambient Occlusion Map", 2D) = "white" { }
        [NoScaleOffset] _MetallicMap("Metallic Map", 2D) = "black" { }
        [NoScaleOffset] _ParallaxMap ("Parallax Map", 2D) = "black" { }
	    _ParallaxStrength ("Parallax Strength", Range(0, 1)) = 0
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline" = "UniversalPipeline" "Queue" = "Geometry" }

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }

            Cull Back
            Blend One Zero
            ZTest LEqual
            ZWrite On
            
            HLSLPROGRAM

            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5
            
            #pragma vertex vert
            #pragma fragment frag

            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
            #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
            #pragma multi_compile_fragment _ _LIGHT_LAYERS
            #pragma multi_compile_fragment _ _LIGHT_COOKIES
            #pragma multi_compile _ _FORWARD_PLUS

            // Unity defined keywords
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ DYNAMICLIGHTMAP_ON
            #pragma multi_compile_fog

            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options renderinglayer

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core//ShaderLibrary/ParallaxMapping.hlsl"

            
            TEXTURE2D(_Texture);
            SAMPLER(sampler_Texture);
            TEXTURE2D(_NormalMap);
            SAMPLER(sampler_NormalMap);
            TEXTURE2D(_RoughnessMap);
            SAMPLER(sampler_RoughnessMap);
            TEXTURE2D(_OcclusionMap);
            SAMPLER(sampler_OcclusionMap);
            TEXTURE2D(_MetallicMap);
            SAMPLER(sampler_MetallicMap);
            TEXTURE2D(_ParallaxMap);
            SAMPLER(sampler_ParallaxMap);

            CBUFFER_START(UnityPerMaterial)
                float4 _Color;
                float4 _Texture_ST;
                float1 _ParallaxStrength;
            CBUFFER_END

            // --------------  LIT PASS STRUCTS v
            struct Attributes
            {
                float4 positionOS : POSITION;
                
                float4 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float2 uv0 : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
                float2 uv2 : TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 positionWS : TEXCOORD1;
                float3 normalWS : TEXCOORD2;
                float4 tangentWS : TEXCOORD3;
                half fogFactor : TEXCOORD4;
                half3 viewDirTS : TEXCOORD5;
                DECLARE_LIGHTMAP_OR_SH(staticLightmapUV, sh, 6);
                #if defined(DYNAMICLIGHTMAP_ON)
                float2  dynamicLightmapUV : TEXCOORD6;
                #endif
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            // --------------  LIT PASS STRUCTS ^

            Varyings vert(Attributes input)
            {
                Varyings output;

                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);

                VertexPositionInputs vertPos = GetVertexPositionInputs(input.positionOS.xyz);
                VertexNormalInputs vertNormals = GetVertexNormalInputs(input.normalOS, input.tangentOS);

                output.positionHCS = vertPos.positionCS;
                output.positionWS = vertPos.positionWS;
                output.uv = TRANSFORM_TEX(input.uv0, _Texture);

                output.normalWS = vertNormals.normalWS;
                output.tangentWS = float4(vertNormals.tangentWS.xyz, input.tangentOS.w * GetOddNegativeScale());

                half fogFactor = 0;
                #if !defined(_FOG_FRAGMENT)
                fogFactor = ComputeFogFactor(input.positionHCS.z);
                #endif

                const half3 viewDirWS = GetWorldSpaceNormalizeViewDir(vertPos.positionWS);
                const half3 viewDirTS = GetViewDirectionTangentSpace(output.tangentWS, output.normalWS, viewDirWS);
                output.viewDirTS = viewDirTS;

                OUTPUT_LIGHTMAP_UV(input.uv1, unity_LightmapST, output.staticLightmapUV);
                #if defined(DYNAMICLIGHTMAP_ON)
                output.dynamicLightmapUV = input.dynamicLightmapUV.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
                #endif
                OUTPUT_SH(output.normalWS.xyz, output.sh);
                output.fogFactor = fogFactor;
                return output;
            }

            // --------------  TEXTURE SAMPLING v
            half4 SampleColor(const float2 uv) { return SAMPLE_TEXTURE2D(_Texture, sampler_Texture, uv); }
            half4 SampleMetallic(const float2 uv) { return SAMPLE_TEXTURE2D(_MetallicMap, sampler_MetallicMap, uv); }
            half4 SampleRoughness(const float2 uv) { return SAMPLE_TEXTURE2D(_RoughnessMap, sampler_RoughnessMap, uv); }
            half3 SampleNormal(const float2 uv) { return UnpackNormal(SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, uv)); }
            half4 SampleOcclusion(const float2 uv) { return SAMPLE_TEXTURE2D(_OcclusionMap, sampler_OcclusionMap, uv); }

            void ApplyPerPixelDisplacement(const half3 viewDirTS, inout float2 uv)
            {
                uv += ParallaxOffset1Step(
                    SAMPLE_TEXTURE2D(_ParallaxMap, sampler_ParallaxMap, uv).r, _ParallaxStrength * 0.1, viewDirTS);
            }
            // --------------  TEXTURE SAMPLING ^
            // --------------  INPUT DATA v
            void InitializeInputData(const Varyings input, const half3 normalTS, out InputData inputData)
            {
                inputData = (InputData)0;
                inputData.positionWS = input.positionWS;

                const half3 viewDirWS = GetWorldSpaceNormalizeViewDir(input.positionWS);
                const float sgn = input.tangentWS.w; // should be either +1 or -1
                const float3 bitangentWS = sgn * cross(input.normalWS.xyz, input.tangentWS.xyz);
                const half3x3 tangentToWorld = half3x3(input.tangentWS.xyz, bitangentWS.xyz, input.normalWS.xyz);
                inputData.tangentToWorld = tangentToWorld;
                inputData.normalWS = TransformTangentToWorld(normalTS, tangentToWorld);

                inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
                inputData.viewDirectionWS = viewDirWS;

                inputData.shadowCoord = TransformWorldToShadowCoord(input.positionWS);
                inputData.fogCoord = InitializeInputDataFog(float4(input.positionWS, 1.0), input.fogFactor);

                #if defined(DYNAMICLIGHTMAP_ON)
                inputData.bakedGI = SAMPLE_GI(input.staticLightmapUV, input.dynamicLightmapUV, input.vertexSH, inputData.normalWS);
                #else
                inputData.bakedGI = SAMPLE_GI(input.staticLightmapUV, input.sh, inputData.normalWS);
                #endif

                inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionHCS);
                inputData.shadowMask = SAMPLE_SHADOWMASK(input.staticLightmapUV);
            }
            // --------------  INPUT DATA ^
            // --------------  SURFACE DATA v
            void InitializeSurfaceData(const float2 uv, out SurfaceData surfaceData)
            {
                surfaceData = (SurfaceData)0;
                half4 albedo = SampleColor(uv);
                surfaceData.alpha = albedo.a * _Color.a;
                surfaceData.albedo = albedo.rgb * _Color.rgb;
                surfaceData.albedo = AlphaModulate(surfaceData.albedo, surfaceData.alpha);
                surfaceData.metallic = SampleMetallic(uv);
                surfaceData.smoothness = 1 - SampleRoughness(uv);
                surfaceData.normalTS = SampleNormal(uv);
                surfaceData.occlusion = SampleOcclusion(uv);
            }
            // --------------  SURFACE DATA ^
            
            float4 frag(Varyings input) : SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(input);

                ApplyPerPixelDisplacement(input.viewDirTS, input.uv);

                SurfaceData surfaceData;
                InitializeSurfaceData(input.uv, surfaceData);

                InputData inputData;
                InitializeInputData(input, surfaceData.normalTS, inputData);

                half4 color = UniversalFragmentPBR(inputData, surfaceData);
                color.rgb = MixFog(color.rgb, inputData.fogCoord);
                color.a = OutputAlpha(color.a, false);
                
                return color;
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