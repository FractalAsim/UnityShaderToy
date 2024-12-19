Shader "GLSL/ Bars" 
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
				vec2 position = ( gl_FragCoord.xy / resolution.xy ) + mouse / 4.0;
					
					float color = 0.0;
					float mx = mod(gl_FragCoord.x, 10.0);
					
					if(mx < 5.0) 
					{
						color = 0.0;
					} else 
					{
						color = 1.0;	
					}
					
					gl_FragColor = vec4( vec3( color, color, color), 1.0 );
				
			}
			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}