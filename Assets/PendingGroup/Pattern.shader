Shader "GLSL/ Pattern" 
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

			void main( void ) {

				vec2 position = abs( gl_FragCoord.xy * 2.0 -  resolution) / min(resolution.x, resolution.y);
				vec3 destColor = vec3(.70, 0.0, .75 );
				float f = 0.25;
				
				for(float i = 0.5; i < 21.0; i++){
					
					float s = tan(sin(time/3.0 - i )) ;
					float c = atan(cos(time/7.0 - i ));
					f +=abs(0.0027 / abs(length(5.0* position *f - vec2(c, s) ) -0.84));
				}

				gl_FragColor = vec4(vec3(destColor * f) + vec3(destColor.yzx * f/2.0), 1.0);
			}

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}