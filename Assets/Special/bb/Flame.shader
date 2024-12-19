Shader "GLSL/ Flame" 
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
			
			uniform sampler2D backbuffer;
			#define resolution _ScreenParams
			#define time _Time.y

			#ifdef VERTEX // Begin vertex program/shader

			void main()
			{
				gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex; // Draws the Vertex at the correct position in world
			}

			#endif // Ends vertex program/shader

			#ifdef FRAGMENT // Begin fragment program/shader

			void main( void ) 
			{

				vec2 position = 2.0 * ( gl_FragCoord.xy - 0.5*resolution.xy) / resolution.y;
				vec2 m = 2.0*(mouse - 0.5);
				m.x = m.x * resolution.x / resolution.y;
				
				
				float a = 0.02 / length(position-m);
				float b = 0.01 / length(position-m);
				float c = 0.001 / length(position-m);
				
				float d = sin(time*time + position.x*position.y);
				vec2 offset = -vec2(0.001*d, 0.01 + 0.001*d);
				vec4 prev = texture2D(backbuffer, offset + gl_FragCoord.xy/resolution.xy);
				
				gl_FragColor = 0.95 * prev + vec4(a, b, c, 1.0);
			}

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}