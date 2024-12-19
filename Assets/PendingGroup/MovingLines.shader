Shader "GLSL/ MovingLines" 
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

			float hash(float g){
				return fract(tan((g+ time) * 112.8253367586 ));	
			}
			void main( void ) {

				vec2 position = ( gl_FragCoord.xy / resolution.xy ) + mouse / 4.0;

				float color = 0.0;
				color += sin( position.x * cos( time / 5.0 ) * 8.0 ) + cos( position.y * cos( time / 15.0 ) * 10.0 );
				color += sin( position.y * sin( time / 10.0 ) * 4.0 ) + cos( position.x * sin( time / 25.0 ) * 40.0 );
				color += sin( position.x * sin( time / 5.0 ) * 10.0 ) + sin( position.y * sin( time / 35.0 ) * 80.0 );
				color *= sin( time / 10.0 ) * 0.5;

				gl_FragColor = vec4( hash(gl_FragCoord.x + gl_FragCoord.y * 1000.0) * vec3(1.0), 1.0 );

			}

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}