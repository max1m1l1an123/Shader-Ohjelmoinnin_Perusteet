Shader "Custom/FinalTask"
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
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }

            Cull Back
            Blend One Zero
            ZTest LEqual
            ZWrite On
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc" // for texture sampling

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
                float4 pos : POSITION;
            };

            sampler2D sampler_blackUVTexture;
            sampler2D sampler_whiteUVTexture;
            float4 sampler_blackUVTexture_ST;
            float4 sampler_whiteUVTexture_ST;

            varyings vert (attributes input)
            {
                varyings output;
                output.pos = UnityObjectToClipPos(input.vertex);
                output.uv = input.uv;
                UNITY_TRANSFER_FOG(output, output.pos);
                return output;
            }
            float4 frag (varyings input) : SV_Target
            {
                half4 color = tex2D(sampler_blackUVTexture, input.uv);
                UNITY_APPLY_FOG(input.fogCoord, color);
                return color;
            }
            ENDHLSL
        }
    }
}
