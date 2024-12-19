Shader "GLSL/ Matrix" 
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

			void main( void ) 
			{
				vec2 uv = ( gl_FragCoord.xy / resolution.xy ) * 50.0 - 1.0;
				uv.x *= resolution.x/resolution.y;
				
				vec3 finalColor = vec3( 0.0, 0.0, 0.0 );
				
				float g = -mod( gl_FragCoord.y + time, cos( gl_FragCoord.x ) + 0.004 );
				g = g + clamp(uv.y, -1.0, 0.0);	
				
				finalColor = vec3( 0.0, g, 0.0 );
				
				gl_FragColor = vec4( finalColor, 1.0 );

			}

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}