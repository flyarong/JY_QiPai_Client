Shader "FontGlow"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_Intensity("Intensity", Range(0, 2)) = 0.5
		_Width("Width", Range(0, 12)) = 5
	}

	SubShader
	{
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }

		Pass
		{
			Cull Back ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_TexelSize;
			float4 _Color;
			float _Intensity;
			float _Width;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				fixed4 color : COLOR;
			};
			struct v2f
			{
				float4 vertex : SV_POSITION;
				half2 uv : TEXCOORD0;
				fixed4 color : COLOR;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.color = v.color;
				return o;
			}

			half4 frag(v2f i) : COLOR
			{
				float rx = _MainTex_TexelSize.x;
				float ry = _MainTex_TexelSize.y;
				float inner = 0;
				int rge = (int)_Width;
				for(int idx = -rge; idx <= rge; ++idx)
				{
					for(int jdx = -rge; jdx <= rge; ++jdx)
					{
						float4 c = tex2D(_MainTex, float2(i.uv.x + idx * rx, i.uv.y + jdx * ry));
						inner += c.a;
					}
				}
				inner /= pow((rge + rge + 1), 2);

				float4 col = tex2D(_MainTex, i.uv);
				col.rgb = col.rgb * i.color.rgb + (1 - col.a) * _Intensity * _Color.rgb * _Color.a;
				col.a = max(col.a, inner) * i.color.a;

				return col;
			}

			ENDCG
		}
	}
}
