Shader "Unlit/Billboard"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_ScaleOffset("Scale(XY) and Offset(ZW)", Vector) = (1, 1, 0, 0)
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue"="Transparent"}
		LOD 100

		ZWrite Off
		//Cull Off
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _ScaleOffset;
			
			v2f vert (appdata v)
			{
				v2f o;

				/*
				// this is for getting camera world position from view matrix.
				float4x4 view = UNITY_MATRIX_V;
				float3x3 v1 = float3x3(
					view._11, view._21, view._31,
					view._12, view._22, view._32,
					view._13, view._23, view._33
				);
				float3 camPos = mul(v1, float3(-view._14, -view._24, -view._34));
				*/
				// get camera world position from Unity directly
				float3 camPos = _WorldSpaceCameraPos;

				float4 objCenter = mul(UNITY_MATRIX_M, float4(0.0f, 0.0f, 0.0f, 1.0f));
				float3 z1 = -normalize(camPos - objCenter.xyz/objCenter.w);

				/*
				// (V._21, V._22, V._23) is the up vector of camera.
				// Using it as the up vector avoids the artifact of particle
				// rotating crazy when camera's forward direction is close to
				// Y or -Y direction. But doing so will make particle rotate
				// with camera.
				float3 x1 = normalize(cross(float3(UNITY_MATRIX_V._21, UNITY_MATRIX_V._22, UNITY_MATRIX_V._23), z1));
				*/
				float3 x1 = normalize(cross(float3(0.0f, 1.0f, 0.0f), z1));

				float3 y1 = cross(z1, x1);

				// scale
				x1 *= _ScaleOffset.x;
				y1 *= _ScaleOffset.y;
				
				// construct a new model matrix.
				float4x4 lookRot = float4x4(
					x1.x, y1.x, z1.x, UNITY_MATRIX_M._14 + _ScaleOffset.z,
					x1.y, y1.y, x1.y, UNITY_MATRIX_M._24 + _ScaleOffset.w,
					x1.z, y1.z, z1.z, UNITY_MATRIX_M._34,
					0.0f, 0.0f, 0.0f, 1.0f
				);

				o.vertex = mul(UNITY_MATRIX_P, mul(UNITY_MATRIX_V, mul(lookRot, v.vertex)));

				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
