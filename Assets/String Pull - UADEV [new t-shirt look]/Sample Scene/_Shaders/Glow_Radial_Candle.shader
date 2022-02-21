Shader "CrazyLabs/CandleGlowRadial"
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
        [HDR]_GlowColor("Color Glow",Color) = (1,1,1,1)
        _MainTex("Albedo (RGB)", 2D) = "white" {}
        _Glossiness("Smoothness", Range(0,1)) = 0.5
        _Metallic("Metallic", Range(0,1)) = 0.0
        _GlowPos("Glow Position", Vector) = (0,0,0,1)
        _SpreadFrom("Spread FromBottom", Range(0,1)) = 0
        _SpreadTo("Spread from top", Range(0, 1)) = 1
        _Radius("Glow Radius",Float) = 2
        _FresnelBias("Fresnel Bias",Float) = 1
        _FresnelScale("Fresnel Scale",Float) = 1
        _FresnelPower("Fresnel Power",Float) = 1
        _LitState("Lit State",Range(0,1)) = 0
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows
        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
            float3 worldPos;
            float3 viewDir;
        };

        uniform float _Glossiness;
        uniform float _Metallic;
        uniform float4 _Color;

        uniform float4 _GlowPos;
        uniform float4 _GlowColor;
        uniform float _Radius;

        uniform float _High;
        uniform float _Low;
        uniform float _SpreadFrom;
        uniform float _SpreadTo;

        uniform float _FresnelBias;
        uniform float _FresnelScale;
        uniform float _FresnelPower;

        uniform float _LitState;



        void surf(Input IN, inout SurfaceOutputStandard o)
        {

            float4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
            float r = _High * _Radius;
            float dist = distance(_GlowPos, IN.worldPos);
            float glowR = saturate((r - dist) / r);

            float rimDot = 1 - saturate(dot(IN.viewDir, o.Normal));
            float fresnel = _FresnelBias + _FresnelScale * pow(rimDot, _FresnelPower);

            float spread = smoothstep(_SpreadFrom, _SpreadTo, glowR);
            float3 glow = lerp(float3(0,0,0), _GlowColor.rgb, spread);
            float3 fernel = lerp(glow.rgb, _GlowColor.rgb, fresnel);
            float3 fernelC = lerp(c.rgb, _GlowColor.rgb, fresnel);
            float3 finalGlow = lerp(float3(0, 0, 0), fernel, _LitState);

            o.Albedo = fernelC.rgb;
            o.Emission = finalGlow;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
        FallBack "Diffuse"
}
