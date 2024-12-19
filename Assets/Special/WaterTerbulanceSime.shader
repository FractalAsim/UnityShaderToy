Shader "GLSL/ WaterTerbulanceSime" 
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

			#define MAX_ITER 16
			void main( void ) 
			{
				vec2 p = (gl_FragCoord.xy/resolution.xy)*8.0;
				vec2 i = p;
				float c = 0.0;
				float inten = 0.5;
				
				// pattern scanline 
				float scl = abs(sin(time*mod(gl_FragCoord.y*gl_FragCoord.x, 2.0)));

				for (int n = 0; n < MAX_ITER; n++)
				{
					float t = time * (1.0 - (1.0 / float(n+1)));
					i = p + vec2(
						cos(  i.x) - sin(t + i.y), 
						sin(  i.y) + cos(t + i.x)
					);
					c += 1.0/length(vec2(
						(sin(i.x)/inten),
						(cos(i.y)/inten)
						)
					);
				}
				c /= float(MAX_ITER);
				float m = max(0.5,abs(sin(time)));
				
				gl_FragColor = vec4(c*vec3(m, m+m, m*m*m), 1.0)/2.*scl;
			// EOFile	
			}

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}