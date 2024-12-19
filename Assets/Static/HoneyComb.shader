Shader "GLSL/ HoneyComb" 
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

			float hex(vec2 p) 
			{
				p.x *= 0.57735*2.0;
				p.y += mod(floor(p.x), 2.0)*0.5;
				p = abs((mod(p, 1.0) - 0.5));
				return abs(max(p.x*1.5 + p.y, p.y*2.0) - 1.0);
			}


			void main( void ) 
			{
				vec2 pos = gl_FragCoord.xy;
				vec2 p = pos/20.0; 
				float  r = (1.0 -0.7)*0.5;	
				gl_FragColor = vec4(smoothstep(0.0, r + 0.05, hex(p)));
			}


			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}