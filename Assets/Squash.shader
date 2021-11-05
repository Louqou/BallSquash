Shader "Custom/Squash" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_SquishDistance ("Squish Distance", Float) = 1.0
		_SquishY ("Squish Y", Float) = 1.0
		_SquishCurve ("Squish Curve", Range(1, 20)) = 3
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
// Upgrade NOTE: excluded shader from OpenGL ES 2.0 because it uses non-square matrices
#pragma exclude_renderers gles
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows vertex:vert

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;
		half _SquishDistance;
		half _SquishY;
		half _SquishCurve;

		void vert(inout appdata_full v) {
			float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
			float4 normal = mul(unity_ObjectToWorld, v.normal);

			float squish = (worldPos.y - _SquishY) / _SquishDistance;
			squish = 1 - saturate(squish);
			squish = pow(squish, _SquishCurve);

			normal.y = 0;
			normal = normalize(normal);
			
			normal.xyz = normal.xyz * squish;

			v.vertex.xyz += mul(unity_WorldToObject, normal);
		}

		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
