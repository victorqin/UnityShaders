Shader "Unlit/ARMask"
{
	Properties
	{
		_Opacity("Opacity", Range(0,1)) = 1
	}
	SubShader
	{
		Tags { "RenderType" = "Transparent" "Queue" = "Transparent+1"}
		LOD 100

		ZWrite Off
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
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float4 grabPos: TEXCOORD0;
			};

			uniform sampler2D _VideoTexture;
			half _Opacity;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.grabPos = ComputeGrabScreenPos(o.vertex);
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2Dproj(_VideoTexture, i.grabPos);
				col.a *= _Opacity;
				return col;
			}
			ENDCG
		}
	}
}
