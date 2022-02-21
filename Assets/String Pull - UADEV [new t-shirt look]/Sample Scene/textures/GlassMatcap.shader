// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "GlassMatcap"
{
	Properties
	{
		_TopTexture0("Top Texture 0", 2D) = "white" {}
		_TextureSample0("Texture Sample 0", 2D) = "white" {}
		_freezeAmount("freezeAmount", Range( 0 , 1)) = 0
		_FreezeMask("_FreezeMask", 2D) = "black" {}
		_stencil("stencil", 2D) = "black" {}
		[HideInInspector] _texcoord2( "", 2D ) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float3 worldNormal;
			INTERNAL_DATA
			float3 worldPos;
			float2 uv_texcoord;
			float2 uv2_texcoord2;
		};

		sampler2D _TopTexture0;
		uniform float _freezeAmount;
		uniform sampler2D _FreezeMask;
		uniform float4 _FreezeMask_ST;
		uniform sampler2D _stencil;
		uniform sampler2D _TextureSample0;


		inline float4 TriplanarSampling72( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
		{
			float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
			projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
			float3 nsign = sign( worldNormal );
			half4 xNorm; half4 yNorm; half4 zNorm;
			xNorm = tex2D( topTexMap, tiling * worldPos.zy * float2(  nsign.x, 1.0 ) );
			yNorm = tex2D( topTexMap, tiling * worldPos.xz * float2(  nsign.y, 1.0 ) );
			zNorm = tex2D( topTexMap, tiling * worldPos.xy * float2( -nsign.z, 1.0 ) );
			return xNorm * projNormal.x + yNorm * projNormal.y + zNorm * projNormal.z;
		}


		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			o.Normal = float3(0,0,1);
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 temp_output_12_0_g7 = ase_worldNormal;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float dotResult4_g7 = dot( temp_output_12_0_g7 , ase_worldViewDir );
			float temp_output_102_0 = ( saturate( ( pow( (( 1.0 - dotResult4_g7 )*0.7 + 0.5) , -1.0 ) - ( 1.0 - mul( float4( temp_output_12_0_g7 , 0.0 ), UNITY_MATRIX_V ).xyz.y ) ) ) * 0.1 );
			float4 temp_cast_2 = (temp_output_102_0).xxxx;
			float4 color12 = IsGammaSpace() ? float4(0.875445,0.963677,0.9716981,0) : float4(0.7396936,0.9193519,0.9368213,0);
			float3 ase_normWorldNormal = normalize( ase_worldNormal );
			float fresnelNdotV17 = dot( ase_normWorldNormal, ase_worldViewDir );
			float fresnelNode17 = ( 0.4 + 1.0 * pow( max( 1.0 - fresnelNdotV17 , 0.0001 ), 1.0 ) );
			float4 temp_cast_3 = (fresnelNode17).xxxx;
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float3 ase_vertexNormal = mul( unity_WorldToObject, float4( ase_worldNormal, 0 ) );
			ase_vertexNormal = normalize( ase_vertexNormal );
			float4 triplanar72 = TriplanarSampling72( _TopTexture0, ase_vertex3Pos, ase_vertexNormal, 2.88, float2( 1,1 ), 1.0, 0 );
			float4 smoothstepResult55 = smoothstep( float4( 0.1,0,0,0 ) , float4( 1.37,0,0,0 ) , ( triplanar72 - float4( 0.3,0.3,0.3,0 ) ));
			float2 uv_FreezeMask = i.uv_texcoord * _FreezeMask_ST.xy + _FreezeMask_ST.zw;
			float4 temp_cast_4 = (tex2D( _FreezeMask, uv_FreezeMask ).r).xxxx;
			float saferPower69 = abs( ( 1.0 - fresnelNode17 ) );
			float4 temp_cast_5 = (( pow( saferPower69 , 16.71 ) * 0.5 )).xxxx;
			float2 uv2_TexCoord118 = i.uv2_texcoord2 * float2( 4,4 );
			float4 frostMask18 = ( saturate( ( ( ( temp_cast_3 - smoothstepResult55 ) * (0.0 + (_freezeAmount - 0.0) * (1.5 - 0.0) / (1.0 - 0.0)) ) + ( ( temp_cast_4 - smoothstepResult55 ) - temp_cast_5 ) ) ) - tex2D( _stencil, uv2_TexCoord118 ) );
			float4 lerpResult24 = lerp( color12 , float4( 1,1,1,0 ) , frostMask18);
			float4 blendOpSrc95 = temp_cast_2;
			float4 blendOpDest95 = lerpResult24;
			o.Emission = ( saturate( ( blendOpSrc95 + blendOpDest95 ) )).rgb;
			float4 matCap80 = tex2D( _TextureSample0, (mul( UNITY_MATRIX_V, float4( ase_normWorldNormal , 0.0 ) ).xyz*0.5 + 0.5).xy );
			float4 clampResult88 = clamp( frostMask18 , float4( 0,0,0,0 ) , float4( 1,1,1,0 ) );
			float4 clampResult87 = clamp( ( ( matCap80 + clampResult88 ) - float4( 0.2,0.2,0.2,0 ) ) , float4( 0,0,0,0 ) , float4( 1,1,1,0 ) );
			o.Alpha = ( clampResult87 + temp_output_102_0 ).r;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit alpha:fade keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float4 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.customPack1.zw = customInputData.uv2_texcoord2;
				o.customPack1.zw = v.texcoord1;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				surfIN.uv2_texcoord2 = IN.customPack1.zw;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutput o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutput, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18933
2574;88;1600;837;-806.0767;-69.61679;1;True;False
Node;AmplifyShaderEditor.TriplanarNode;72;-855.1744,648.6268;Inherit;True;Spherical;Object;False;Top Texture 0;_TopTexture0;white;0;Assets/Liran/Materials/Bottle/frost_noise_2.jpg;Mid Texture 0;_MidTexture0;white;0;None;Bot Texture 0;_BotTexture0;white;1;None;Triplanar Sampler;Tangent;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT2;1,1;False;4;FLOAT;2.88;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FresnelNode;17;-835.306,326.1108;Inherit;True;Standard;WorldNormal;ViewDir;True;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0.4;False;2;FLOAT;1;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;48;-492.2343,639.0007;Inherit;True;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0.3,0.3,0.3,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.OneMinusNode;67;92.76064,961.1613;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;63;232.0129,633.4695;Inherit;True;Property;_FreezeMask;_FreezeMask;3;0;Create;True;0;0;0;False;0;False;-1;17b4bf3d742fa764388f0c25e60e9f4d;None;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;69;246.2985,961.751;Inherit;True;True;2;0;FLOAT;0;False;1;FLOAT;16.71;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;55;-222.8733,632.5599;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0.1,0,0,0;False;2;FLOAT4;1.37,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-734.0837,954.7339;Inherit;False;Property;_freezeAmount;freezeAmount;2;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;70;459.4631,961.6493;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;45;-23.94232,416.9261;Inherit;True;2;0;FLOAT;0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;66;373.6885,819.0296;Inherit;False;2;0;FLOAT;0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TFHCRemapNode;47;-340.2528,823.3384;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;68;676.3959,821.0165;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;19;290.068,415.8715;Inherit;True;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;118;901.0853,522.9637;Inherit;False;1;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;4,4;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;64;840.1244,426.6651;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;117;869.3244,634.6227;Inherit;True;Property;_stencil;stencil;5;0;Create;True;0;0;0;False;0;False;-1;4e3d2e54a12c1e54ba133929dec483a0;1a151d745284d8342a5a50ea6270a849;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;44;999.2071,429.813;Inherit;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ViewMatrixNode;8;-838.6643,-322.5049;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.WorldNormalVector;1;-828.1001,-251.3;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;5;-628.1,-223.3;Inherit;False;Constant;_Float0;Float 0;0;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;3;-625.1,-316.3;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;104;1216.629,515.5385;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;18;1390.681,510.7854;Inherit;False;frostMask;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;4;-498.7418,-356.4111;Inherit;True;3;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;21;44.0551,-43.76384;Inherit;False;18;frostMask;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;6;-267.1,-341.3;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;0;False;0;False;-1;None;e392ffbd309448240b03a8d3f2894f07;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;88;269.4558,-25.99361;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT4;1,1,1,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;80;24.1501,-122.0851;Inherit;False;matCap;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;22;598.3669,-132.5909;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;12;141.1357,-543.1102;Inherit;False;Constant;_Color0;Color 0;1;0;Create;True;0;0;0;False;0;False;0.875445,0.963677,0.9716981,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector;98;568.2259,3.945099;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;92;754.5912,-138.0901;Inherit;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0.2,0.2,0.2,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;25;193.4639,-353.1234;Inherit;False;18;frostMask;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.LerpOp;24;541.0629,-437.7579;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;1,1,1,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;102;779.4482,1.059937;Inherit;False;DedicatedRimLight;-1;;7;e6cfd57f9cb0eaf4a94bf6d5157755de;0;3;19;FLOAT;0.1;False;12;FLOAT3;0,0,0;False;11;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;87;897.112,-143.4101;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;85;1813.382,321.6488;Inherit;False;vCol;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;-333.721,1216.9;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BlendOpsNode;95;1038.736,-458.2971;Inherit;False;LinearDodge;True;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;28;-690.5823,1151.156;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.VertexColorNode;74;1338.264,199.1245;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ViewMatrixNode;51;-681.7493,1061.327;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;78;1677.377,220.6484;Inherit;False;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;53;-845.751,1119.476;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;94;1076.068,-39.22205;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;83;1678.69,309.9149;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0.4150943;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;81;1502.628,264.2077;Inherit;False;80;matCap;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;84;1337.573,362.4993;Inherit;False;Property;_VertexColorMultiplier;Vertex Color Multiplier;4;0;Create;True;0;0;0;False;0;False;0;0.038;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;77;1500.048,195.8685;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;50;-556.184,1078.532;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;33;-500.721,1221.9;Inherit;False;Constant;_Float2;Float 2;3;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1312.017,-422.8369;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;GlassMatcap;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;18;all;True;True;True;True;0;False;-1;False;255;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;48;0;72;0
WireConnection;67;0;17;0
WireConnection;69;0;67;0
WireConnection;55;0;48;0
WireConnection;70;0;69;0
WireConnection;45;0;17;0
WireConnection;45;1;55;0
WireConnection;66;0;63;1
WireConnection;66;1;55;0
WireConnection;47;0;20;0
WireConnection;68;0;66;0
WireConnection;68;1;70;0
WireConnection;19;0;45;0
WireConnection;19;1;47;0
WireConnection;64;0;19;0
WireConnection;64;1;68;0
WireConnection;117;1;118;0
WireConnection;44;0;64;0
WireConnection;3;0;8;0
WireConnection;3;1;1;0
WireConnection;104;0;44;0
WireConnection;104;1;117;0
WireConnection;18;0;104;0
WireConnection;4;0;3;0
WireConnection;4;1;5;0
WireConnection;4;2;5;0
WireConnection;6;1;4;0
WireConnection;88;0;21;0
WireConnection;80;0;6;0
WireConnection;22;0;80;0
WireConnection;22;1;88;0
WireConnection;92;0;22;0
WireConnection;24;0;12;0
WireConnection;24;2;25;0
WireConnection;102;12;98;0
WireConnection;87;0;92;0
WireConnection;85;0;83;0
WireConnection;32;0;50;0
WireConnection;32;1;33;0
WireConnection;95;0;102;0
WireConnection;95;1;24;0
WireConnection;28;0;53;1
WireConnection;28;1;53;2
WireConnection;78;0;77;0
WireConnection;78;1;81;0
WireConnection;94;0;87;0
WireConnection;94;1;102;0
WireConnection;83;0;78;0
WireConnection;83;1;84;0
WireConnection;77;0;74;1
WireConnection;50;0;51;0
WireConnection;50;1;28;0
WireConnection;0;2;95;0
WireConnection;0;9;94;0
ASEEND*/
//CHKSM=40949FE830FD593E10CCD527234069BB3EEA6B63