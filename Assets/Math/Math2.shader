Shader "GLSL/ Math2" 
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

			#ifdef GL_ES
			precision mediump float;
			#endif

			uniform vec2 mouse;
			uniform vec2 _ScreenParams; 
			uniform vec4 _Time; // (t/20, t, t*2, t*3)

			#define resolution _ScreenParams
			#define time _Time.y

			#ifdef VERTEX // Begin vertex program/shader

			void main()
			{
				gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex; // Draws the Vertex at the correct position in world
			}

			#endif // Ends vertex program/shader

			#ifdef FRAGMENT // Begin fragment program/shader

			void main()
			{
				vec2 pos = gl_FragCoord.xy / resolution.xy -0.5;

				const float pi = 3.14159;
				const int n = 32;
				
				float radius = length(pos) * 2.0 - 0.1;
				float t = atan(pos.y, pos.x);
				
				float color = 0.20;
				
				for (int i = 1; i <= n; i++)
				{
					color += 0.003 / abs(0.77 * sin(3. * (t + i/n * time * 0.988888888888)) - radius);
				}

				gl_FragColor = vec4(vec3(1.5, 0.5, 0.15) * color, 1.);
			}

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}