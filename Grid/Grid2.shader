// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/Grid2"
{
	Properties
	{
		_Color("Color", Color) = (1, 1, 1, 1)
		_MainTex ("Texture", 2D) = "white" {}
		_InnerRadius("Inner Radius", Range(0, 0.5)) = 0.2
		_TransitionDistance("Transition Distance", Range(0, 0.5)) = 0.05
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue"="Transparent"}
		LOD 100
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv: TEXCOORD0;
			};

			struct v2f
			{
				float2 uv: TEXCOORD0;
				float4 worldPos: TEXCOORD1;
				float4 vertex : SV_POSITION;
			};

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _InnerRadius;
			float _TransitionDistance;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.uv = v.uv;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.worldPos /= o.worldPos.w;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float2 worldCenter = float2(
					unity_ObjectToWorld[0][3]/unity_ObjectToWorld[3][3],
					unity_ObjectToWorld[2][3]/unity_ObjectToWorld[3][3]);
				float2 uv = i.worldPos.xz - worldCenter;

				float transparency = 1 - smoothstep(
					_InnerRadius, _InnerRadius+_TransitionDistance,
					length(i.uv - float2(0.5, 0.5)));

				// sample the texture
				fixed4 col = tex2D(_MainTex, uv * _MainTex_ST.xy + _MainTex_ST.zw);
				col.a *= transparency;
				col *= _Color;
				return col;
			}
			ENDCG
		}
	}
}
