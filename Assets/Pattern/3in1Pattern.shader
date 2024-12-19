Shader "GLSL/ 3in1Pattern" 
{
	Properties
	{
		mouse ("Mouse", Vector) = (0,0,0,0)
	}
	SubShader
	{	
		Pass
		{
			GLSLPROGRAM // Begin GLSL

			uniform vec2 _ScreenParams; 
			//uniform vec2 mouse;
			uniform vec4 _Time; // (t/20, t, t*2, t*3)
			//uniform  vec4 unity_DeltaTime //  (dt, 1/dt, smoothDt, 1/smoothDt).
			//uniform  vec4 _SinTime // (t/8, t/4, t/2, t).
			//uniform  vec4 _CosTime // (t/8, t/4, t/2, t).

			#ifdef VERTEX // Begin vertex program/shader

			void main()
			{
				gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex; // Draws the Vertex at the correct position in world
			}

			#endif // Ends vertex program/shader

			#ifdef FRAGMENT // Begin fragment program/shader

			float dia(vec2 uv) 
			{
				float a = atan(uv.y, uv.x);	
				float s = floor((abs(uv.x) + abs(uv.y)) * 50.0);
				s *= sin(s * 24.0);
				float s2 = fract(sin(s));
				
				float c = step(0.9, tan(a + s + s2 * _Time.y) * 0.5 + 0.5);
				
				c *= s2 * 0.7 + 0.5;
				return c;		
			}

			float pluralRing(vec2 uv, float interval) 
			{
				return sin(length(uv) * interval);
			}

			float rotationSpiral(vec2 uv, float count, float speed, float num) 
			{
				return step(0.0, sin(atan(uv.y, uv.x) * count + speed)) * sin(floor(length(uv * num)));
			}

			void main()
			{
				vec2 uv = (gl_FragCoord.xy * 2.0 - _ScreenParams.xy) / min(_ScreenParams.x, _ScreenParams.y);
	
				float scaledTime = mod(_Time.y * 1.0, 3.0);
				float type = floor(scaledTime);
				float newTime = 1.0 - fract(scaledTime);
				
				vec3 color = vec3(0.0);
				
				if (type == 1.0) {
					color.r += pluralRing(uv * 4.0, newTime * 25.0);
					
				} else if (type == 2.0) {
					color.g += dia(uv * newTime);
					
				} else {
					color.b += rotationSpiral(uv, 20.0, newTime * 10.0, newTime * 100.0);
				}

				gl_FragColor = vec4(color, 1.0);
			}

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}