// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/Transparent Colored 1"
{
	Properties
	{
		_MainTex ("Base (RGB), Alpha (A)", 2D) = "black" {}

		_Color ("Tint", Color) = (1,1,1,1)
		_Stencil ("Stencil ID", Float) = 0
		_StencilOp ("Stencil Operation", Float) = 0
		_StencilComp ("Stencil Comparison", Float) = 8
		_StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255

		_ClipForce("ClipForce" , Float) = 1.0
		_ClipDepth("ClipDepth",Float) =1.0
		_ClipDirection("ClipDirection",Vector) = (0.0, 0.0,0.0,0.0)
		_ClipRange("ClipRange",Vector) = (100.0, 100.0, 1.0, 1.0)
		_ClipArgs("ClipArgs",Vector) = (1000.0, 1000.0,0.0,0.0)
	}

	SubShader
	{
		LOD 200

		Tags
		{
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
		}
		
		Pass
		{
			Cull Off
			Lighting Off
			ZWrite Off
			Offset -1, -1
			Fog { Mode Off }
			ColorMask RGB
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			sampler2D _MainTex;
			// float _ClipForce = float(1.0);
			// float _ClipDepth = float(1.0);
			// float2 _ClipDirection = float2(0.0, 0.0);
			// float4 _ClipRange = float4(100.0, 100.0, 1.0, 1.0);
			// float2 _ClipArgs = float2(1000.0, 1000.0);

			float _ClipForce ;
			float _ClipDepth ;
			float2 _ClipDirection ;
			float4 _ClipRange ;
			float2 _ClipArgs ;


			struct appdata_t
			{
				float4 vertex : POSITION;
				half4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				half4 color : COLOR;
				float2 texcoord : TEXCOORD0;
				float2 worldPos : TEXCOORD1;
			};

			v2f o;

			v2f vert (appdata_t v)
			{
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.color = v.color;
				o.texcoord = v.texcoord;
				o.worldPos = v.vertex.xy * _ClipRange.zw + _ClipRange.xy;
				return o;
			}

			half4 frag (v2f IN) : SV_Target
			{
				// Softness factor
				float2 factor_ClipArgs = (float2(1.0, 1.0) - abs(IN.worldPos)) * _ClipArgs;

				float factor_ClipDirection = (IN.worldPos.y * _ClipDirection.y  - float(0.0))
											 + (IN.worldPos.x * _ClipDirection.x - float(0.0));

				float factors = clamp((1 / _ClipDepth), 0.0, 1.0)
						      * clamp((1 - factor_ClipDirection * _ClipForce), 0.0, 1.0) 
							  * clamp( min(factor_ClipArgs.x, factor_ClipArgs.y), 0.0, 1.0);
			
				// Sample the texture
				half4 col = tex2D(_MainTex, IN.texcoord) * IN.color;
				col.a *= factors;
				return col;
			}
			ENDCG
		}
	}
	
	SubShader
	{
		LOD 100

		Tags
		{
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
		}
		
		Pass
		{
			Cull Off
			Lighting Off
			ZWrite Off
			Fog { Mode Off }
			ColorMask RGB
			Blend SrcAlpha OneMinusSrcAlpha
			ColorMaterial AmbientAndDiffuse
			
			SetTexture [_MainTex]
			{
				Combine Texture * Primary
			}
		}
	}
}
