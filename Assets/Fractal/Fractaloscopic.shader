Shader "GLSL/ Fractaloscopic" 
{
	//Robert Schütze (trirop) 07.12.2015
	Properties
	{
		mouse ("Mouse", Vector) = (0,0,0,0)
	}
	SubShader
	{	
		// Fractaloscopic.glsl
		Pass
		{
			GLSLPROGRAM // Begin GLSL

			#ifdef GL_ES
			precision mediump float;
			#endif

			uniform vec2 mouse;
			uniform vec2 _ScreenParams; 
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

			const float NUM_SIDES = 7.0; // set your favorite mirror factor here
			const float PI = 3.14159265359;
			const float KA = PI / NUM_SIDES;

			void smallKoleidoscope(inout vec2 uv)
			{
			float angle = abs (mod (atan (uv.y, uv.x), 2.0 * KA) - KA) + 0.1*_Time.y;
			uv = length(uv) * vec2(cos(angle), sin(angle));
			}

			void main(void)
			{
				vec2 uv = 16.0*(2.0 * gl_FragCoord.xy / _ScreenParams.xy - 1.0);
				uv.x *= _ScreenParams.x / _ScreenParams.y;
					
				smallKoleidoscope(uv);

				vec3 p = vec3 (uv, mouse.x); // //  vec3 p = vec3 (uv, 16.*mouse.x)
				for (int i = 0; i < 44; i++)
				{
					p.xzy = vec3(1.3,0.999,0.678)*(abs((abs(p)/dot(p,p)-vec3(1.0,1.02,mouse.y*0.4))));
					
				}
				gl_FragColor = vec4(p,1.0);
			}

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}