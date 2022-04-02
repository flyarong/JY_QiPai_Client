// Shader created with Shader Forge v1.38 
// Shader Forge (c) Freya Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:0,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:False,nrmq:0,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:0,bdst:0,dpts:2,wrdp:False,dith:0,atcv:False,rfrpo:False,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.8088235,fgcg:0.7824097,fgcb:0.6720372,fgca:1,fgde:0.005,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:True,fnsp:True,fnfb:False,fsmp:False;n:type:ShaderForge.SFN_Final,id:3138,x:34155,y:32473,varname:node_3138,prsc:2|emission-9545-OUT;n:type:ShaderForge.SFN_Tex2d,id:7833,x:32603,y:32127,ptovrint:False,ptlb:Main Tex,ptin:_MainTex,varname:_MainTex,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-2623-OUT;n:type:ShaderForge.SFN_TexCoord,id:8076,x:31514,y:32193,varname:node_8076,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Tex2d,id:9985,x:32622,y:32819,ptovrint:False,ptlb:Mask Tex,ptin:_MaskTex,varname:_MaskTex,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-2745-UVOUT;n:type:ShaderForge.SFN_TexCoord,id:2745,x:32194,y:32827,varname:node_2745,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Multiply,id:1266,x:33096,y:32729,varname:node_1266,prsc:2|A-7833-A,B-9985-R;n:type:ShaderForge.SFN_Multiply,id:4525,x:33461,y:32396,varname:node_4525,prsc:2|A-6642-OUT,B-7552-RGB;n:type:ShaderForge.SFN_VertexColor,id:7552,x:33181,y:32495,varname:node_7552,prsc:2;n:type:ShaderForge.SFN_Multiply,id:5537,x:33409,y:32716,varname:node_5537,prsc:2|A-7552-A,B-1266-OUT;n:type:ShaderForge.SFN_Multiply,id:4535,x:32882,y:32145,varname:node_4535,prsc:2|A-9434-OUT,B-7833-RGB;n:type:ShaderForge.SFN_ValueProperty,id:9434,x:32668,y:31983,ptovrint:False,ptlb:Brightness,ptin:_Brightness,varname:_MainTexBrightness,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_Tex2d,id:3488,x:31208,y:31664,ptovrint:False,ptlb:Turbulence Tex,ptin:_TurbulenceTex,varname:_NormalTex,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:3,isnm:False|UVIN-1145-OUT;n:type:ShaderForge.SFN_Add,id:9326,x:31781,y:32281,varname:node_9326,prsc:2|A-8076-UVOUT,B-9450-OUT;n:type:ShaderForge.SFN_Add,id:407,x:32035,y:32072,varname:node_407,prsc:2|A-6613-OUT,B-9326-OUT;n:type:ShaderForge.SFN_Multiply,id:6613,x:31551,y:31993,varname:node_6613,prsc:2|A-3488-R,B-301-W;n:type:ShaderForge.SFN_TexCoord,id:775,x:30621,y:31404,varname:node_775,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Multiply,id:232,x:30664,y:31808,varname:node_232,prsc:2|A-6886-OUT,B-7882-T;n:type:ShaderForge.SFN_Time,id:7882,x:30297,y:31936,varname:node_7882,prsc:2;n:type:ShaderForge.SFN_Append,id:6886,x:30370,y:31679,varname:node_6886,prsc:2|A-2727-OUT,B-8873-OUT;n:type:ShaderForge.SFN_ValueProperty,id:2727,x:30105,y:31601,ptovrint:False,ptlb:Power X,ptin:_PowerX,varname:_NormalTexPannerX,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_ValueProperty,id:8873,x:29758,y:31711,ptovrint:False,ptlb:Power Y,ptin:_PowerY,varname:_NormalTexPannerY,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Add,id:1145,x:30973,y:31601,varname:node_1145,prsc:2|A-775-UVOUT,B-232-OUT;n:type:ShaderForge.SFN_TexCoord,id:301,x:30974,y:32395,varname:node_301,prsc:2,uv:1,uaff:True;n:type:ShaderForge.SFN_Multiply,id:1193,x:33714,y:32103,varname:node_1193,prsc:2|A-1550-RGB,B-4525-OUT;n:type:ShaderForge.SFN_Color,id:1550,x:33212,y:31833,ptovrint:False,ptlb:Main Color,ptin:_MainColor,varname:node_1550,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:1,c2:1,c3:1,c4:1;n:type:ShaderForge.SFN_Multiply,id:9782,x:33686,y:32617,varname:node_9782,prsc:2|A-1550-A,B-5537-OUT;n:type:ShaderForge.SFN_Append,id:9450,x:31541,y:32469,varname:node_9450,prsc:2|A-301-U,B-301-V;n:type:ShaderForge.SFN_Power,id:6642,x:33212,y:32063,varname:node_6642,prsc:2|VAL-4535-OUT,EXP-2723-OUT;n:type:ShaderForge.SFN_ValueProperty,id:2723,x:32839,y:31849,ptovrint:False,ptlb:Contrast,ptin:_Contrast,varname:node_2723,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_Multiply,id:7805,x:33823,y:32470,varname:node_7805,prsc:2|A-1193-OUT,B-9782-OUT;n:type:ShaderForge.SFN_TexCoord,id:9060,x:31340,y:31384,varname:node_9060,prsc:2,uv:2,uaff:True;n:type:ShaderForge.SFN_Append,id:5974,x:31668,y:31405,varname:node_5974,prsc:2|A-9060-U,B-9060-V;n:type:ShaderForge.SFN_TexCoord,id:4332,x:31431,y:31179,varname:node_4332,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Multiply,id:9631,x:32000,y:31340,varname:node_9631,prsc:2|A-4332-UVOUT,B-2357-OUT;n:type:ShaderForge.SFN_Vector1,id:6756,x:31480,y:31595,varname:node_6756,prsc:2,v1:-1;n:type:ShaderForge.SFN_Vector1,id:7451,x:31493,y:31696,varname:node_7451,prsc:2,v1:-0.5;n:type:ShaderForge.SFN_Multiply,id:3559,x:32052,y:31588,varname:node_3559,prsc:2|A-2357-OUT,B-7451-OUT;n:type:ShaderForge.SFN_Add,id:5916,x:32256,y:31540,varname:node_5916,prsc:2|A-9631-OUT,B-3559-OUT;n:type:ShaderForge.SFN_Add,id:2623,x:32277,y:31839,varname:node_2623,prsc:2|A-5916-OUT,B-407-OUT;n:type:ShaderForge.SFN_Add,id:2357,x:31830,y:31480,varname:node_2357,prsc:2|A-5974-OUT,B-6756-OUT;n:type:ShaderForge.SFN_Add,id:8652,x:32784,y:33139,varname:node_8652,prsc:2|A-3488-R,B-1598-OUT;n:type:ShaderForge.SFN_Clamp01,id:7858,x:33109,y:33161,varname:node_7858,prsc:2|IN-8652-OUT;n:type:ShaderForge.SFN_Smoothstep,id:4145,x:33598,y:33247,varname:node_4145,prsc:2|A-6566-OUT,B-7767-OUT,V-7858-OUT;n:type:ShaderForge.SFN_Slider,id:7767,x:33008,y:33521,ptovrint:False,ptlb:Max,ptin:_Max,varname:node_7518,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:1,max:1;n:type:ShaderForge.SFN_Vector1,id:3208,x:32098,y:33354,varname:node_3208,prsc:2,v1:-1;n:type:ShaderForge.SFN_Multiply,id:1598,x:32230,y:33100,varname:node_1598,prsc:2|A-9850-OUT,B-3208-OUT;n:type:ShaderForge.SFN_Add,id:9850,x:31737,y:33091,varname:node_9850,prsc:2|A-301-Z,B-3155-OUT;n:type:ShaderForge.SFN_Vector1,id:3155,x:31382,y:33205,varname:node_3155,prsc:2,v1:-1;n:type:ShaderForge.SFN_Multiply,id:9545,x:33985,y:32646,varname:node_9545,prsc:2|A-7805-OUT,B-4145-OUT;n:type:ShaderForge.SFN_Slider,id:6566,x:33048,y:33359,ptovrint:False,ptlb:Min,ptin:_Min,varname:node_6566,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0,max:1;proporder:9434-2723-1550-7833-3488-2727-8873-9985-6566-7767;pass:END;sub:END;*/

Shader "YuLongZhi/AHJS/Dynamatic/UVeffect_add" {
    Properties {
        _Brightness ("Brightness", Float ) = 1
        _Contrast ("Contrast", Float ) = 1
        _MainColor ("Main Color", Color) = (1,1,1,1)
        _MainTex ("Main Tex", 2D) = "white" {}
        _TurbulenceTex ("Turbulence Tex", 2D) = "bump" {}
        _PowerX ("Power X", Float ) = 0
        _PowerY ("Power Y", Float ) = 0
        _MaskTex ("Mask Tex", 2D) = "white" {}
        _Min ("Min", Range(0, 1)) = 0
        _Max ("Max", Range(0, 1)) = 1
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            Blend One One
            Cull Off
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            #pragma target 2.0
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            uniform sampler2D _MaskTex; uniform float4 _MaskTex_ST;
            uniform float _Brightness;
            uniform sampler2D _TurbulenceTex; uniform float4 _TurbulenceTex_ST;
            uniform float _PowerX;
            uniform float _PowerY;
            uniform float4 _MainColor;
            uniform float _Contrast;
            uniform float _Max;
            uniform float _Min;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
                float4 texcoord1 : TEXCOORD1;
                float4 texcoord2 : TEXCOORD2;
                float4 vertexColor : COLOR;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 uv1 : TEXCOORD1;
                float4 uv2 : TEXCOORD2;
                float4 vertexColor : COLOR;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.uv1 = v.texcoord1;
                o.uv2 = v.texcoord2;
                o.vertexColor = v.vertexColor;
                o.pos = UnityObjectToClipPos( v.vertex );
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
////// Lighting:
////// Emissive:
                float2 node_2357 = (float2(i.uv2.r,i.uv2.g)+(-1.0));
                float4 node_7882 = _Time;
                float2 node_1145 = (i.uv0+(float2(_PowerX,_PowerY)*node_7882.g));
                float4 _TurbulenceTex_var = tex2D(_TurbulenceTex,TRANSFORM_TEX(node_1145, _TurbulenceTex));
                float2 node_2623 = (((i.uv0*node_2357)+(node_2357*(-0.5)))+((_TurbulenceTex_var.r*i.uv1.a)+(i.uv0+float2(i.uv1.r,i.uv1.g))));
                float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(node_2623, _MainTex));
                float4 _MaskTex_var = tex2D(_MaskTex,TRANSFORM_TEX(i.uv0, _MaskTex));
                float3 emissive = (((_MainColor.rgb*(pow((_Brightness*_MainTex_var.rgb),_Contrast)*i.vertexColor.rgb))*(_MainColor.a*(i.vertexColor.a*(_MainTex_var.a*_MaskTex_var.r))))*smoothstep( _Min, _Max, saturate((_TurbulenceTex_var.r+((i.uv1.b+(-1.0))*(-1.0)))) ));
                float3 finalColor = emissive;
                return fixed4(finalColor,1);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
