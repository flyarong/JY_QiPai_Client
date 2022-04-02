Shader "Unlit/wave"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_WaveTex ("WaveTex", 2D) = "white" {}
		_Intensity("Intensity", Range(0, 1)) = 0.01
		_Speed("Speed", Range(0, 1)) = 0.01
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" }
		LOD 100

		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			sampler2D _WaveTex;
			float4 _WaveTex_ST;

			float _Intensity;
			float _Speed;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed noise = tex2D(_WaveTex, i.uv + fixed2(_Time.y * _Speed, 0)).r;
				fixed4 col = tex2D(_MainTex, i.uv + (_Intensity * noise));
				clip(col.a - 0.1);
				return col;
			}
			ENDCG
		}
	}
}
