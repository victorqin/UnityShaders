Shader "Unlit/HDR2LDRDemo"
{
	// Mimic a HDR color picker.
	// Also apply some tone mapping 
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Hue("Hue", Range(0, 1)) = 0
		_MaxBrightness("Max Brightness", Range(1, 10)) = 1
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

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

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Hue;
			float _MaxBrightness;

			// https://en.wikipedia.org/wiki/HSL_and_HSV#From_HSV
			// range of hsv is [0, 1]
			float3 hsv2rgb(float3 hsv)	{
				float c = hsv.y * hsv.z;
				float h = hsv.x * 6;
				float x = c * (1 - abs(fmod(h, 2.0f) - 1));
				float3 rgb;
				if(h <= 1){
					rgb = float3(c, x, 0);
				}else if(h <= 2){
					rgb = float3(x, c, 0);
				}else if(h <= 3){
					rgb = float3(0, c, x);
				}else if(h <= 4){
					rgb = float3(0, x, c);
				}else if(h <=5){
					rgb = float3(x, 0, c);
				}else if(h <=6){
					rgb = float3(c, 0, x);
				}
				
				float m = hsv.z - c;
				return rgb + float3(m, m, m);
			}

			float3 reinhardToneMapping(float3 col){
				return col/(col+1);
			}

			// https://knarkowicz.wordpress.com/2016/01/06/aces-filmic-tone-mapping-curve/
			// ACES stands for Acamemy Color Encoding System.
			float3 ACESToneMapping(float3 color)
			{
				const float A = 2.51f;
				const float B = 0.03f;
				const float C = 2.43f;
				const float D = 0.59f;
				const float E = 0.14f;

				return (color * (A * color + B)) / (color * (C * color + D) + E);
			}

			// http://filmicworlds.com/blog/filmic-tonemapping-operators/
			float3 F(float3 x)
			{
				const float A = 0.22f;
				const float B = 0.30f;
				const float C = 0.10f;
				const float D = 0.20f;
				const float E = 0.01f;
				const float F = 0.30f;
			
				return ((x * (A * x + C * B) + D * E) / (x * (A * x + B) + D * F)) - E / F;
			}

			float3 Uncharted2ToneMapping(float3 color)
			{
				const float WHITE = 11.2f;
				return F(2.0f * color) / F(WHITE);
			}

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float3 hsv = fixed3(_Hue, i.uv.x, i.uv.y * _MaxBrightness);
				float3 rgb = hsv2rgb(hsv);

				// apply Reinhard tone mapping: x/(x+1)
				//rgb = reinhardToneMapping(rgb);

				// apply uncharted2 tone mapping
				//rgb = Uncharted2ToneMapping(rgb);

				// apply ACES tone mapping
				//rgb = ACESToneMapping(rgb);

				//return fixed4(i.uv.x, i.uv.y, 0.0, 1.0);
				return fixed4(rgb.x, rgb.y, rgb.z, 1.0);
			}
			ENDCG
		}
	}
}
