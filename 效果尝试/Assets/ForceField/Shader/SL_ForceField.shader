Shader "TestEffect/ForceField" {
    Properties {
    [Header(Texture)]
        _MainTex ("Pattern图", 2D) = "white"{}
    [Header(Fresnel)]
[HDR]   _FresCol ("边缘光颜色", Color) = (1.0, 1.0, 1.0, 1.0)
        _FresPow ("边缘光范围", float) = 1.0
    [Header(Pattern Attribute)]
[HDR]   _PatCol ("图案颜色", Color) = (1.0, 1.0, 1.0, 1.0)

    }
    SubShader {
        Tags {
            "Queue"="Transparent"        
            "RenderType"="Transparent"   
            "ForceNoShadowCasting"="True"
            "IgnoreProjector"="True"     
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            
            Blend One OneMinusSrcAlpha 
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma target 3.0

            // 输入参数
            // Texture
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            // Fresnel
            uniform float3 _FresCol;
            uniform float _FresPow;
            // Pattern
            uniform float3 _PatCol;
            uniform float4 _PatParam;


            
            struct VertexInput {
                float4 vertex : POSITION;
                float2 uv0 : TEXCOORD0;
                float3 normal : NORMAL;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float3 posWS : TEXCOORD0;
                float2 uv0 : TEXCOORD1;
                float3 normal : TEXCOORD2;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.pos = UnityObjectToClipPos( v.vertex );
                o.posWS = mul(unity_ObjectToWorld, v.vertex);
                o.uv0 = TRANSFORM_TEX(v.uv0, _MainTex);
                o.normal = normalize(UnityObjectToWorldNormal(v.normal));
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                // 向量准备
                float3 vDirWS = normalize(_WorldSpaceCameraPos.xyz - i.posWS);      // 世界空间视方向
                float3 nDirWS = i.normal;                                           // 世界空间法线方向

                // 中间量计算
                float vDotn =dot(vDirWS, nDirWS);   

                // 纹理采样
                float var_MainTex = tex2D(_MainTex, i.uv0);
                
                // 纹理处理
                float3 pattern = var_MainTex * _PatCol;
                
                // Fresnel
                float3 fresnel = pow(max(0.0, (1 - vDotn)), _FresPow) * _FresCol;


                float opacity = pattern;
                float3 finalColor = pattern * opacity;
                return float4(finalColor, opacity);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
