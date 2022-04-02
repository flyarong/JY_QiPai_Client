// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/distortion"
{
	Properties
	{
		_NoiseTex ("NoiseTex", 2D) = "white" {}
		_Intensity ("Intensity", range(0, 100)) = 10
		_Speed ("Speed", range(0, 2)) = 1
		_Life ("Life", range(0.1, 10)) = 1
	}
	SubShader
	{
		Tags { "Queue" = "Transparent+100" "RenderType"="Hidden" }

		GrabPass {
			"_GrabTexture"
		}

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float4 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float4 uvGrab : TEXCOORD0;
				float4 uvNoise : TEXCOORD1;
			};

			sampler2D _NoiseTex;
			float4 _NoiseTex_ST;
			float _Intensity;
			float _Speed;
			float _Life;
			sampler2D _GrabTexture;
			float4 _GrabTexture_TexelSize;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				#if UNITY_UV_STARTS_AT_TOP
				float scale = -1.0;
				#else
				float scale = 1.0;
				#endif
				o.uvGrab = ComputeGrabScreenPos(o.vertex);
				o.uvNoise.xy = TRANSFORM_TEX(v.uv, _NoiseTex);
				o.uvNoise.zw = v.uv.zw;

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed2 v = fixed2(0.5, 0.5) - i.uvNoise;
				v = normalize(v);

				fixed mask = tex2D(_NoiseTex, i.uvNoise).r;
				fixed2 nv = tex2D(_NoiseTex, i.uvNoise + v * fmod(_Speed * _Time.y, _Life));
				float2 delta = (nv * _Intensity * _GrabTexture_TexelSize.xy * i.uvGrab.z) * mask;
				i.uvGrab.xy += delta;
				fixed4 gcol = tex2Dproj(_GrabTexture, UNITY_PROJ_COORD(i.uvGrab));

				return gcol;
			}
			ENDCG
		}
	}
}
