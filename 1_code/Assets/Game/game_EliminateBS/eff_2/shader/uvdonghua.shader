// Shader created with Shader Forge v1.38 
// Shader Forge (c) Freya Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,bsrc:0,bdst:0,dpts:2,wrdp:False,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:True,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:True,fgod:False,fgor:False,fgmd:0,fgcr:0,fgcg:0,fgcb:0,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:True,fnfb:True,fsmp:False;n:type:ShaderForge.SFN_Final,id:4795,x:32724,y:32693,varname:node_4795,prsc:2|emission-2393-OUT;n:type:ShaderForge.SFN_Tex2d,id:6074,x:32222,y:32576,ptovrint:False,ptlb:MainTex,ptin:_MainTex,varname:_MainTex,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-9538-UVOUT;n:type:ShaderForge.SFN_Multiply,id:2393,x:32495,y:32793,varname:node_2393,prsc:2|A-6074-RGB,B-2053-RGB,C-797-RGB,D-9248-OUT;n:type:ShaderForge.SFN_VertexColor,id:2053,x:32235,y:32772,varname:node_2053,prsc:2;n:type:ShaderForge.SFN_Color,id:797,x:32235,y:32930,ptovrint:True,ptlb:Color,ptin:_TintColor,varname:_TintColor,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_Vector1,id:9248,x:32222,y:33115,varname:node_9248,prsc:2,v1:2;n:type:ShaderForge.SFN_UVTile,id:9538,x:32067,y:32750,varname:node_9538,prsc:2|UVIN-3766-OUT,WDT-7063-OUT,HGT-6825-OUT,TILE-2779-OUT;n:type:ShaderForge.SFN_Append,id:3766,x:31906,y:32608,varname:node_3766,prsc:2|A-7729-U,B-3849-OUT;n:type:ShaderForge.SFN_RemapRange,id:3849,x:31687,y:32717,varname:node_3849,prsc:2,frmn:0,frmx:1,tomn:1,tomx:0|IN-7729-V;n:type:ShaderForge.SFN_TexCoord,id:7729,x:31358,y:32551,varname:node_7729,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_ValueProperty,id:7063,x:31750,y:32907,ptovrint:False,ptlb:heng,ptin:_heng,varname:node_7063,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_ValueProperty,id:9749,x:31673,y:33011,ptovrint:False,ptlb:shu,ptin:_shu,varname:_heng_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Negate,id:6825,x:31885,y:32967,varname:node_6825,prsc:2|IN-9749-OUT;n:type:ShaderForge.SFN_ValueProperty,id:9300,x:31798,y:33127,ptovrint:False,ptlb:ti,ptin:_ti,varname:_shu_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Time,id:5104,x:31755,y:33254,varname:node_5104,prsc:2;n:type:ShaderForge.SFN_Multiply,id:4858,x:31924,y:33222,varname:node_4858,prsc:2|A-9300-OUT,B-5104-T;n:type:ShaderForge.SFN_Trunc,id:2779,x:32114,y:33245,varname:node_2779,prsc:2|IN-4858-OUT;proporder:6074-797-7063-9749-9300;pass:END;sub:END;*/

Shader "Shader Forge/uvdonghua" {
    Properties {
        _MainTex ("MainTex", 2D) = "white" {}
        _TintColor ("Color", Color) = (0.5,0.5,0.5,1)
        _heng ("heng", Float ) = 0
        _shu ("shu", Float ) = 0
        _ti ("ti", Float ) = 0
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
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma only_renderers d3d9 d3d11 glcore gles gles3 metal d3d11_9x xboxone ps4 psp2 n3ds wiiu 
            #pragma target 3.0
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            uniform float4 _TintColor;
            uniform float _heng;
            uniform float _shu;
            uniform float _ti;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 vertexColor : COLOR;
                UNITY_FOG_COORDS(1)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.vertexColor = v.vertexColor;
                o.pos = UnityObjectToClipPos( v.vertex );
                UNITY_TRANSFER_FOG(o,o.pos);
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
////// Lighting:
////// Emissive:
                float4 node_5104 = _Time;
                float node_2779 = trunc((_ti*node_5104.g));
                float2 node_9538_tc_rcp = float2(1.0,1.0)/float2( _heng, (-1*_shu) );
                float node_9538_ty = floor(node_2779 * node_9538_tc_rcp.x);
                float node_9538_tx = node_2779 - _heng * node_9538_ty;
                float2 node_9538 = (float2(i.uv0.r,(i.uv0.g*-1.0+1.0)) + float2(node_9538_tx, node_9538_ty)) * node_9538_tc_rcp;
                float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(node_9538, _MainTex));
                float3 emissive = (_MainTex_var.rgb*i.vertexColor.rgb*_TintColor.rgb*2.0);
                float3 finalColor = emissive;
                fixed4 finalRGBA = fixed4(finalColor,1);
                UNITY_APPLY_FOG_COLOR(i.fogCoord, finalRGBA, fixed4(0,0,0,1));
                return finalRGBA;
            }
            ENDCG
        }
    }
    CustomEditor "ShaderForgeMaterialInspector"
}
