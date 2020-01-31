Shader "Unlit/Hue Replacer"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _SrcHueColor ("Source Hue", Color) = (1.0, 0.0, 1.0)
        _DestHueColor ("Destination Hue", Color) = (0.0, 1.0, 0.0)
        _HueThreshold ("Hue Threshold", Float) = 0.1
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            // use "vert" function as the vertex shader
            #pragma vertex vert
            // use "frag" function as the __pixel__ (fragment) shader
            #pragma fragment frag

            // vertex shader inputs
            struct appdata
            {
                float4 vertex : POSITION; // vertex position
                float2 uv : TEXCOORD0; // texture coordinate
            };

            // vertex shader outputs ("vertex to fragment")
            struct v2f
            {
                float2 uv : TEXCOORD0; // texture coordinate
                float4 vertex : SV_POSITION; // clip space position
            };

            // vertex shader
            v2f vert (appdata v)
            {
                v2f o;
                // transform position to clip space
                // (multiply with model*view*projection matrix)
                o.vertex = UnityObjectToClipPos(v.vertex);
                // just pass the texture coordinate
                o.uv = v.uv;
                return o;
            }

            fixed3 rgb2hsv(fixed3 c) {
                fixed4 K = fixed4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
                fixed4 p = lerp(fixed4(c.bg, K.wz), fixed4(c.gb, K.xy), step(c.b, c.g));
                fixed4 q = lerp(fixed4(p.xyw, c.r), fixed4(c.r, p.yzx), step(p.x, c.r));

                float d = q.x - min(q.w, q.y);
                float e = 1.0e-10;
                return fixed3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
            }

            fixed3 hsv2rgb(fixed3 c) {
                fixed4 K = fixed4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
                fixed3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
                return c.z * lerp(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
            }

            // texture we will sample
            sampler2D _MainTex;
            fixed4 _SrcHueColor;
            fixed4 _DestHueColor;
            fixed _HueThreshold;

            // pixel shader; returns low precision ("fixed4" type)
            // color ("SV_Target" semantic)
            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 rgb = (fixed3)(tex2D(_MainTex, i.uv));
                fixed3 hsv = rgb2hsv(rgb);

                fixed srcHue = rgb2hsv(_SrcHueColor).x;
                fixed hueDiff = abs(hsv.x - srcHue);

                if (hueDiff < _HueThreshold) {
                    fixed destHue = rgb2hsv(_DestHueColor).x;
                    fixed3 destRGB = hsv2rgb(fixed3(destHue, hsv.y, hsv.z));
                    rgb = lerp(destRGB, rgb, hueDiff / _HueThreshold);
                }

                return fixed4(rgb, 1);
            }
            ENDCG
        }
    }
}
