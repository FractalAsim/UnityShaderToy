Shader "GLSL/ RainbowCircle4" 
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

			#define PI 3.14159265359
			#define T (time/2.)

			vec3 hsv2rgb(vec3 c)
			{
				vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
				vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
				return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
			}

			void main( void ) {

				vec2 position = (( gl_FragCoord.xy / resolution.xy ) - 0.5);
				position.x *= resolution.x / resolution.y;
				
				vec3 color = vec3(0.);
				
				for (float i = 0.; i < PI*2.; i += PI/17.5) {
					vec2 p = position - vec2(cos(i+T), sin(i+T)) * 0.25;
					vec3 col = hsv2rgb(vec3((i)/(PI*2.), 1., mod(i-T*3.,PI*2.)/PI));
					color += col * (1./128.) / length(p);
				}

				gl_FragColor = vec4( color, 1.0 );

			}

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}