Shader "Unlit/Portal"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ColorA ("Color A", Color) = (1, 1, 1, 1)
        _ColorB ("Color B", Color) = (0, 0, 0, 1)
        _ColorStart ("Color Start", Range(0, 1)) = 1
        _ColorEnd ("Color End", Range(0, 1)) = 0
        _Scale ("Scale UV", float) = 1
        _Offset ("Offset UV", float) = 1
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Transparent"
            "Queue" = "Transparent"
        }

        Pass
        {
            Cull Off
            Blend One One //black is transparent

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            #define PI UNITY_PI
            #define TAU 2*PI

            struct appdata //input for the vertex shader
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            //output for the vertex shader
            struct v2f //for the frag shader
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Scale;
            float _Offset;
            float4 _ColorA;
            float4 _ColorB;
            float _ColorStart;
            float _ColorEnd;

            float InverseLerp(float a, float b, float v)
            {
                return (v - a) / (b - a);
            }

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = (v.uv + _Offset) * _Scale; //TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = mul(v.normal, unity_WorldToObject);
                return o;
            }

            //per texel
            float4 frag(v2f i) : SV_Target
            {
                float xOffset = cos(i.uv.x* TAU * 8) * 0.1;
                float t = cos((i.uv.x + xOffset + _Time.y * 0.1) *  TAU * 2) * 0.5 + 0.5;
                t*= 1-i.uv.y;
                float4 outColor = lerp(_ColorA, _ColorB, t);
                outColor = mul(1 - _ColorA, outColor);//totally not arbitrary
                return outColor;
            }
            ENDCG
        }
    }
}