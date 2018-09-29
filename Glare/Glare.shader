Shader "Unlit/Glare"
{
	Properties
	{
		_TintColor("Tint Color", Color) = (1, 1, 1, 1)
		_Brightness("Brightness", Range(0, 10)) = 1.0
		_ScaleOffset("Scale(XY) and Offset(ZW)", Vector) = (1, 1, 0, 0)
	}
	SubShader
	{
		// "DisableBatching"="True" is crutial. Otherwise the shader will
		// break caused by Unity's dynamic batching.
		//https://docs.unity3d.com/Manual/SL-SubShaderTags.html
		Tags { "RenderType"="Transparent" "Queue"="Transparent" "DisableBatching"="True"}
		LOD 100

		Blend One One
		ZWrite Off
		ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			fixed4 _TintColor;
			float _Brightness;
			float4 _ScaleOffset;

			v2f vert (appdata v)
			{
				v2f o;
				float4x4 m1 = UNITY_MATRIX_MV;
				float4x4 m2 = float4x4(
					_ScaleOffset.x, 0.0f, 0.0f, m1._14+_ScaleOffset.z,
					0.0f, _ScaleOffset.y, 0.0f, m1._24+_ScaleOffset.w,
					0.0f, 0.0f, 1.0f, m1._34,
					m1._41, m1._42, m1._43, m1._44);

				o.vertex = mul(UNITY_MATRIX_P, mul(m2, v.vertex));
				o.uv = v.uv;
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				float2 uv = i.uv - float2(0.5, 0.5);
				float l = length(uv);
				float c = 0.01/(l) * _Brightness * (1 - smoothstep(0, 0.2, l));
				float4 col = float4(c, c, c, 1.0);
				col.rgb *= _TintColor.rgb*_TintColor.a;
				return col;
			}
			ENDCG
		}
	}
}
