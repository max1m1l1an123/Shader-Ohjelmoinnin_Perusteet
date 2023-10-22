Shader "Custom/TextureColorShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Position ("Position", Range(0, 1)) = 0.5
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

            TEXTURE2D (_MainTex);
            SAMPLER (sampler_MainTex);

            struct appdata_t
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert(appdata_t v)
            {
                v2f o;
                o.vertex = mul(UNITY_MATRIX_MVP,v.vertex);
                o.uv = v.uv;
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                return SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
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