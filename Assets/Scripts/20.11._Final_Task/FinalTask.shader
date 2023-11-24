Shader "Unlit/FinalTask"
{
    Properties
    {
        _blackUVTexture ("blackUVTexture", 2D) = "black" {} // dead
        _whiteUVTexture ("whiteUVTexture", 2D) = "white" {} // alive
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline" = "UniversalPipeline" "Queue" = "Geometry" }

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "UnityCG.cginc"

            CBUFFER_START(UnityPerMaterial)
            Texture2D _blackUVTexture;
            Texture2D _whiteUVTexture;
            CBUFFER_END
            
            struct attributes
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };
            struct varyings
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D sampler_blackUVTexture;
            sampler2D sampler_whiteUVTexture;
            float4 sampler_blackUVTexture_ST;
            float4 sampler_whiteUVTexture_ST;

            varyings vert (attributes v)
            {
                varyings o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, sampler_blackUVTexture);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            float4 frag (varyings i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_blackUVTexture, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDHLSL
        }
    }
}
