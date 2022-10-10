Shader "Unlit/BarrierCube"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color", Color) = (1, 0, 0, 1)
        _Speed("Speed", float) = 20 //how fast the color changes
        _Distance("Distance", Range(0, 3)) = 2 //when color starts to change
        _WaveSpeed("WaveSpeed", float) = 1 //how fast the waves move
        _Pattern("Pattern", float) = 0.1 //determines the pattern
        _Size("Size", float) = 10 //how many squares are in each side, each face will have Size^2 squares
        _MinimumAlpha("Minimum Alpha", Range(0, 1)) = 0.01 //lowest the alpha can go
        _ShipRipple("Ship Ripple Distance", float) = 20 //distance from ship that shield starts to ripple
    }
    SubShader
    {
        Tags { "RenderType" = "Transparent"
            "Queue" = "Transparent" }

        Pass
        {
            Cull Off
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
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
                float3 worldPos : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            float _Speed;
            float _Distance;
            float _WaveSpeed;
            float _Pattern;
            float _Size;
            float _MinimumAlpha;
            float _ShipRipple;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                //o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv = v.uv;
                o.normal = v.normal * -1;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // sample the texture
                //fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 col = _Color;
                col.a = _Distance - (distance(i.worldPos, _WorldSpaceCameraPos) / _Speed);
                col.a = max(_MinimumAlpha, col.a);
                //square pattern
                float2 squares = i.uv * _Size;
                //tiling
                squares.x += step(1, fmod(squares.y, 2.0)) * 0.5; //offset second row
                fixed4 tex = tex2D(_MainTex, squares); //testing hex pattern
                //clip(frac(squares) - _Pattern); //- tex.xy);//can add texture to every square
                col.r += max(0, tex.xy.r);
                //ripple
                float dist = frac(tan(length(i.uv * 2 - 1)) - _Time.y * _WaveSpeed) - _Pattern;//magic
                clip(dist);
                //player ship ripple
                dist = distance(i.worldPos, _WorldSpaceCameraPos);
                col.g = step(0.9, sin(dist)) * step(dist, _Distance + _ShipRipple);
                return col;
            }
            ENDCG
        }
    }
}
