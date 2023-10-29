Shader "Custom/TextureSamplerShader"
{
    Properties
    {
        _MainTex ("Texture A", 2D) = "white" {}
        _Position ("Position", Range(0, 1)) = 0.5
        _SecondTex ("Texture B", 2D) = "white" {}
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
            #pragma vertex vert
            #pragma fragment frag

            // #include "UnityCG.cginc"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/lighting.hlsl"

            // TEXTURE2D (_MainTex);
            // SAMPLER (sampler_MainTex);
            sampler2D _MainTex;
            // TEXTURE2D (_SecondTex);
            // SAMPLER (sampler_SecondTex);
            sampler2D _SecondTex;
            
            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            float4 _SecondTex_ST;
            CBUFFER_END
            
            struct appdata_t
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD1;
            };

            v2f vert(appdata_t v)
            {
                v2f o;
                o.vertex = mul(UNITY_MATRIX_MVP,v.vertex);
                o.uv = v.uv;
                o.normal = v.normal;
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                // Sample textures
                half4 texA = tex2D(_MainTex, i.uv);
                half4 texB = tex2D(_SecondTex, i.uv);

                // Use the normal's Z component to blend between textures
                half blendAmount = i.normal.z;

                // Blend textures based on normal
                return lerp(texA, texB, blendAmount);
    
                // half4 blendedTexture = lerp(texA, texB, saturate(blendAmount));
                
                // -------------------------------------------------------- v
                // return SAMPLE_TEXTURE2D(blendedTexture, sampler_MainTex, i.uv);
                // -------------------------------------------------------- ^

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