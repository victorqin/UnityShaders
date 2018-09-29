Shader "Unlit/BillboardSimple"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_ScaleOffset("Scale(XY) and Offset(ZW)", Vector) = (1, 1, 0, 0)
	}
	SubShader
	{
		// "DisableBatching"="True" is crutial. Otherwise the shader will
		// break caused by Unity's dynamic batching.
		//https://docs.unity3d.com/Manual/SL-SubShaderTags.html
		Tags { "RenderType"="Transparent" "Queue"="Transparent" "DisableBatching"="True"}
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

				// Spherical Billboard
				// This is just a hack. Not real billboarding.
				// the -1 in the third column is probably cause by left-hand
				// coordinate system that Unity uses.
				float4x4 m1 = UNITY_MATRIX_MV;
				float4x4 m2 = float4x4(
					_ScaleOffset.x, 0.0f, 0.0f, m1._14+_ScaleOffset.z,
					0.0f, _ScaleOffset.y, 0.0f, m1._24+_ScaleOffset.w,
					0.0f, 0.0f, -1.0f, m1._34,
					m1._41, m1._42, m1._43, m1._44);

				o.vertex = mul(UNITY_MATRIX_P, mul(m2, v.vertex));

				/*
				// Cylindrical Billboard
				// This is just a hack. Not real billboarding.
				float4x4 m1 = UNITY_MATRIX_MV;
				float4x4 m2 = float4x4(
					1.0f, m1._12, 0.0f, m1._14,
					0.0f, m1._22, 0.0f, m1._24,
					0.0f, m1._32, -1.0f, m1._34,
					m1._41, m1._42, m1._43, m1._44);

				o.vertex = mul(UNITY_MATRIX_P, mul(m2, v.vertex));
				*/

				/*
				o.vertex = mul(UNITY_MATRIX_P, 
					mul(UNITY_MATRIX_MV, float4(0.0, 0.0, 0.0, 1.0))) 
					+ float4(v.vertex.x * _ScaleOffset.x + _ScaleOffset.z,
					         v.vertex.y * _ScaleOffset.y + _ScaleOffset.w,
							 0.0f, 0.0f);
							 */

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
