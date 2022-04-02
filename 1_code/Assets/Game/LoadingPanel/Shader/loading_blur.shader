Shader "Unlit/loading_blur"
{
	Properties
	{
		_BlurSize("BlurSize", Range(0, 0.01)) = 0.001
	}
	SubShader
	{
		Tags { "Queue" = "Transparent" }

		GrabPass {}

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float4 pos : TEXCOORD0;
			};

			sampler2D _GrabTexture : register(s0);
			float _BlurSize;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.pos = ComputeGrabScreenPos(o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float2 spos = i.pos.xy / i.pos.w;

				half4 sum = half4(0, 0, 0, 0);
				float factor = 0.0;
				for(int idx = 5; idx > 0; --idx) {
					factor = _BlurSize * idx;
					sum += tex2D(_GrabTexture, float2(spos.x - factor, spos.y + factor));
					sum += tex2D(_GrabTexture, float2(spos.x + factor, spos.y - factor));
					sum += tex2D(_GrabTexture, float2(spos - factor));
					sum += tex2D(_GrabTexture, float2(spos + factor));
				}

				return sum * 0.05;
			}
			ENDCG
		}
	}
}
