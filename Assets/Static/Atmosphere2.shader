Shader "GLSL/ Atmosphere2" 
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
				vec2 position = ( gl_FragCoord.xy / resolution.xy );;
					
				float zenith = 0.2 / position.y - 0.1;

				vec3 color = vec3(0.3, 0.5, 1.0) * zenith;
					color = pow(color, vec3(1.0 - zenith));
					color /= color + 1.0;

				gl_FragColor = vec4(color, 1.0 );
			}

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}