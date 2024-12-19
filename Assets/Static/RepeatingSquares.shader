Shader "GLSL/ Template" 
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

			float map(float s0, float s1, float d0, float d1, float x) {
				return mix(d0, d1, (x-s0)/(s1-s0));
			}

			void main( void ) {
				vec2 p = ( gl_FragCoord.xy / resolution.xy );

				//gl_FragColor = vec4(mix(0.5, 0.3, smoothstep(0.1, 0.9, pos.y))*vec3(0.4*step(0.5, fract(gl_FragCoord.x / 100.)), 0.5, 0.5), 1.);
				float b = step(25., mod(gl_FragCoord.x, 50.)) * step(25., mod(gl_FragCoord.y, 50.));
				vec3 c = (1.-b)*vec3(0.5, 0.5, 0.5);
				gl_FragColor = vec4(0.5*c, 1.);
			}

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}