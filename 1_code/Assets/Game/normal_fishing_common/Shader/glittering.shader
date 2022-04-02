// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Unlit/glittering"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}

		_NoiseTex ("NoiseTex", 2D) = "white" {}
		_Intensity("Intensity", Range(0, 0.05)) = 0.01
		_NoiseSpeed("NoiseSpeed", Range(0, 1)) = 0.01

		_LightTex ("LightTexture", 2D) = "white" {}
		_LightColor("LightColor", Color) = (1,1,1,1)
		_LightSpeed ("LightSpeed", Range(0, 1)) = 0.01

		[Toggle] _ATLAS("Atlas?", float) = 0
	}
	SubShader
	{
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
		LOD 100

		Pass
		{
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma shader_feature _ATLAS_ON
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float4 color : COLOR;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float4 color : COLOR;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			sampler2D _NoiseTex;
			float4 _NoiseTex_ST;
			float _Intensity;
			float _NoiseSpeed;

			sampler2D _LightTex;
			float4 _LightTex_ST;
			float4 _LightColor;
			float _LightSpeed;

			#ifdef _ATLAS_ON
			float4 _Rect;
			#endif

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.color = v.color;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				#ifdef _ATLAS_ON
				fixed2 luv = (i.uv - _Rect.xy) / (_Rect.zw - _Rect.xy);
				luv = luv + fixed2(_Time.y * _LightSpeed, 0);
				#else
				fixed2 luv =  i.uv + fixed2(_Time.y * _LightSpeed, 0);
				#endif

				fixed noise = tex2D(_NoiseTex, TRANSFORM_TEX(luv, _NoiseTex)).r;

				fixed4 fcol = tex2D(_MainTex, i.uv + _Intensity * noise);
				fcol.rgb = fcol.rgb * i.color.rgb * i.color.a + (1 - i.color.a) * i.color.rgb;

				fixed4 lcol = tex2D(_LightTex, TRANSFORM_TEX(luv, _LightTex));
				lcol.rgb = lcol.r * _LightColor.rgb * _LightColor.a;

				lcol *= fcol.a;
				fcol.rgb += lcol.rgb;

				return fcol;
			}
			ENDCG
		}
	}
}
