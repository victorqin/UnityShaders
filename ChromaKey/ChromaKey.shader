Shader "Unlit/ChromaKey"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_KeyColor("Key Color", Color) = (0, 1, 0)
		_LowerThreshold1("Lower Threshold (Transparency)", Range(0, 0.5)) = 0
		_HigherThreshold1("Higher Threshold (Transparency)", Range(0, 0.5)) = 0

		_ReplacedColor("Replaced Color", Color) = (0, 0, 0, 0)
		_LowerThreshold2("Lower Threshold (Color)", Range(0, 0.5)) = 0
		_HigherThreshold2("Higher Threshold (Color)", Range(0, 0.5)) = 0
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "IgnoreProjector"="True"}

		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha

		LOD 100

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
			float4 _KeyColor;
			float4 _ReplacedColor;
			float _LowerThreshold1;
			float _HigherThreshold1;
			float _LowerThreshold2;
			float _HigherThreshold2;

			float3 rgb2yCbCr(float3 rgb)
			{
				float3x3 m = {0.299, 0.587, 0.114, 
				              -0.169, -0.331, 0.5,
							  0.5, -0.419, -0.081};

				return mul(m, rgb) + float3(0.0, 0.5, 0.5);
			}
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);

				float2 col1 = rgb2yCbCr(col).yz;
				float2 col2 = rgb2yCbCr(_KeyColor).yz;

				float dist = length(col1 - col2)/2 + (dot(normalize(col1), normalize(col2)) + 1) /4;

				float alphaFactor = smoothstep(_LowerThreshold1, _HigherThreshold1, dist);
				float colorFactor = smoothstep(_LowerThreshold2, _HigherThreshold2,  dist);

				//col.rgb = dist * float3(1, 1, 1);
				col = lerp(_ReplacedColor, col, colorFactor);
				col.a *= alphaFactor;

				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);

				return col;
			}
			ENDCG
		}
	}
}
