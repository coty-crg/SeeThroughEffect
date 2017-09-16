
#pragma vertex vert
#pragma fragment frag

// make fog work
//#pragma multi_compile_fog

#include "UnityCG.cginc"

struct appdata
{
	float2 uv : TEXCOORD0;
	float4 vertex : POSITION;
	float4 normal : NORMAL; 
};

struct v2f
{
	float2 uv : TEXCOORD0;
	//UNITY_FOG_COORDS(1)
	float4 pos : SV_POSITION;
	float3 worldNormal : TEXCOORD2;
	float3 viewDir : TEXCOORD3;
	float4 grabPos : TEXCOORD4;
};

sampler2D _MainTex;
float4 _MainTex_ST;

fixed4 _Color; 
fixed4 _XrayInverseColor; 
fixed4 _XrayColor;
half _XRayThickness; 
half _XRayIntensity; 
half _XRayAlbedoIntensity; 

sampler2D _CameraDepthTexture;
half _XRayIntersectionLength; 

v2f vert(appdata v)
{
	v2f o;

	o.uv = TRANSFORM_TEX(v.uv, _MainTex);
	o.pos = UnityObjectToClipPos(v.vertex);
	o.worldNormal = UnityObjectToWorldNormal(v.normal);
	o.viewDir = normalize(WorldSpaceViewDir(v.vertex));
	o.grabPos = ComputeGrabScreenPos(o.pos);

	//UNITY_TRANSFER_FOG(o,v.vertex); 
	return o;
}

fixed4 frag(v2f i) : SV_Target
{
	fixed4 tex = tex2D(_MainTex, i.uv); 

	float rim = saturate((_XRayThickness - saturate(dot(i.worldNormal, i.viewDir))) * _XRayIntensity);

	// final color 
	fixed4 col = lerp(_XrayColor, lerp(_XrayInverseColor, tex * _Color, _XRayAlbedoIntensity), 1 - rim);

	// depth check for alpha strength 
	float2 screenUv = i.grabPos.xy / i.grabPos.w;
	half4 screenDepthTex = LinearEyeDepth(tex2D(_CameraDepthTexture, screenUv));
	half screenDepth = screenDepthTex.r;
	half ourDepth = i.grabPos.w;
	half depthDifference = abs(ourDepth - screenDepth);
	half intersection = saturate(depthDifference - _XRayIntersectionLength);
	//col.a *= intersection; 

	//UNITY_APPLY_FOG(i.fogCoord, col);
	return col;
}