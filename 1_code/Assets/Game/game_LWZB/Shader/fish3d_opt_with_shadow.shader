// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "fish3d_opt_with_shadow"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo", 2D) = "white" {}

		_Glossiness("Smoothness", Range(0.0, 1.0)) = 0.5
		[Gamma] _Metallic("Metallic", Range(0.0, 1.0)) = 0.0

		[ToggleOff] _SpecularHighlights("Specular Highlights", Float) = 1.0

		_BumpScale("Scale", Float) = 1.0
		_BumpMap("Normal Map", 2D) = "bump" {}

		_Occlusion("Occlusion", Range(0.0, 2.0)) = 1
		_Ambient("Ambient", Range(0.0, 2.0)) = 1
		_Atten("Atten", Range(0.0, 2.0)) = 1

		_EmissionColor("EmissionColor", Color) = (0,0,0)

		_ShadowAlpha("ShadowAlpha", Range(0, 1)) = 0.25
		_ShadowShift("ShadowShift",Range(-1,1)) = -0.01
		_ShadowDepth("ShadowDepth",Range(-1,1)) = -0.1
	}

		CGINCLUDE
#define UNITY_SETUP_BRDF_INPUT MetallicSetup

#include "UnityStandardCoreForward.cginc"
		half _Occlusion;
		half _Ambient;
		half _Atten;

		half4 fragBaseOpt(VertexOutputForwardBase i) : SV_Target
		{
			UNITY_APPLY_DITHER_CROSSFADE(i.pos.xy);

			FRAGMENT_SETUP(s)

			UNITY_SETUP_INSTANCE_ID(i);

			UnityLight mainLight = MainLight();
			UNITY_LIGHT_ATTENUATION(atten, i, s.posWorld);
			UnityGI gi = FragmentGI(s, _Occlusion, _Ambient, atten * _Atten, mainLight);

			half4 c = UNITY_BRDF_PBS(s.diffColor, s.specColor, s.oneMinusReflectivity, s.smoothness, s.normalWorld, -s.eyeVec, gi.light, gi.indirect);
			c.rgb += Emission(i.tex.xy);

			return OutputForward(c, s.alpha);
		}

		half _ShadowAlpha;
		half _ShadowShift;
		half _ShadowDepth;

		struct appdataShadow
		{
			float4 vertex : POSITION;
		};

		struct v2fShadow
		{
			float4 pos : SV_POSITION;
		};

		v2fShadow vertShadow(appdataShadow v)
		{
			const fixed ShadowShift = -0.01;
			const fixed ShadowDepth = -0.1;

			//_ShadowShift = ShadowShift;
			//_ShadowDepth = ShadowDepth;

			v2fShadow o;
			float3 vdir = ObjSpaceViewDir(v.vertex);
			float3 wdir = _WorldSpaceLightPos0.xyz;
			vdir *= _ShadowDepth;
			float4 wpos = mul(unity_ObjectToWorld, v.vertex + fixed4(vdir, 0));
			float dis = wpos.z + _ShadowShift;
			float delta = dis - wpos.z;
			float fac = 1.0 / wdir.z;
			o.pos.x = delta * wdir.x * fac + wpos.x;
			o.pos.y = delta * wdir.y * fac + wpos.y;
			o.pos.z = dis;
			o.pos.w = 1.0;
			o.pos = UnityWorldToClipPos(o.pos.xyz);

			return o;
		}

		fixed4 fragShadow(v2fShadow i) : SV_Target
		{
			return fixed4(0, 0, 0, _ShadowAlpha);
		}

			ENDCG

			SubShader
		{
			Tags{ "RenderType" = "Opaque" "IgnoreProjector" = "True" }
				LOD 300

				Pass
			{
				Name "FORWARD"
				Tags { "LightMode" = "ForwardBase" }

				CGPROGRAM
				#pragma target 3.0

				#pragma multi_compile _NORMALMAP
				#pragma multi_compile _EMISSION
				#pragma multi_compile _GLOSSYREFLECTIONS_OFF
				#pragma skip_variants SHADOWS_SOFT DIRLIGHTMAP_COMBINED
				#pragma multi_compile_fwdbase
				#pragma multi_compile_instancing

				#pragma vertex vertBase
				#pragma fragment fragBaseOpt

				ENDCG
			}
				Pass
			{
				Tags { "RenderType" = "Transparent" "Queue" = "Transparent+1000" }
				ZWrite Off
				Blend SrcAlpha OneMinusSrcAlpha

				Stencil {
				   Ref 7
				   Comp NotEqual
				   Pass Replace
				}

				CGPROGRAM
				#pragma vertex vertShadow
				#pragma fragment fragShadow
				#pragma multi_compile_fwdbase
				ENDCG
			}
		}

		SubShader
		{
			Tags { "RenderType" = "Opaque" "IgnoreProjector" = "True" }
			LOD 150

			Pass
			{
				Name "FORWARD"
				Tags { "LightMode" = "ForwardBase" }

				CGPROGRAM
				#pragma target 2.0

				#pragma multi_compile _NORMALMAP
				#pragma multi_compile _EMISSION
				#pragma multi_compile _GLOSSYREFLECTIONS_OFF
				#pragma skip_variants SHADOWS_SOFT DIRLIGHTMAP_COMBINED
				#pragma multi_compile_fwdbase

				#pragma vertex vertBase
				#pragma fragment fragBaseOpt

				ENDCG
			}
			Pass
			{
				Tags { "RenderType" = "Transparent" "Queue" = "Transparent+1000" }
				ZWrite Off
				Blend SrcAlpha OneMinusSrcAlpha

				Stencil {
				   Ref 7
				   Comp NotEqual
				   Pass Replace
				}

				CGPROGRAM
				#pragma vertex vertShadow
				#pragma fragment fragShadow
				#pragma multi_compile_fwdbase
				ENDCG
			}
		}
}
