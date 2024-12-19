Shader "GLSL/ Atmosphere1" 
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

			#define sunColor vec3(1.0, 0.85, 0.6)

			#define rayleighCoefficient vec3(4.593e-6, 1.097e-5, 2.716e-5)

			const vec3 totalCoeffSky = rayleighCoefficient / log(2.0);

			#define coeffFromDepth(a) a * totalCoeffSky
			#define absorb(a) exp2(-coeffFromDepth(a))
			void main( void ) {

				vec2 position = ( gl_FragCoord.xy / resolution.xy );
				float opticalDepth = 4000.0 / position.y;
					opticalDepth /= opticalDepth / 300000.0 + 0.2;
				
				
				vec3 color = totalCoeffSky * opticalDepth * sunColor * absorb(opticalDepth);
					
				gl_FragColor = vec4(color, 1.0 );

			}

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}