Shader "GLSL/ BlurDot" 
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
			//uniform vec4 _Time; // (t/20, t, t*2, t*3)
			//uniform  vec4 unity_DeltaTime //  (dt, 1/dt, smoothDt, 1/smoothDt).
			//uniform  vec4 _SinTime // (t/8, t/4, t/2, t).
			//uniform  vec4 _CosTime // (t/8, t/4, t/2, t).

			#ifdef VERTEX // Begin vertex program/shader

			void main()
			{
				gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex; // Draws the Vertex at the correct position in world
			}

			#endif // Ends vertex program/shader

			#ifdef FRAGMENT // Begin fragment program/shader

			const int NUM_SAMPLES = 8;

			float image(vec2 uv) 
			{
				return distance( uv, vec2( 0 ) ) < 0.1 ? 1.5 : 0.0;
			}

			void main( void ) 
			{
				vec2 position = ( gl_FragCoord.xy * 2.0 - _ScreenParams ) / min( _ScreenParams.x, _ScreenParams.y );
				vec2 velocity = ( mouse - vec2( 0.5 ) ) * 0.75;

				float color = 0.0;

				for (int i = 1; i < NUM_SAMPLES; i++) {
					vec2 offset = velocity * ( float( i ) / float( NUM_SAMPLES - 1 ) - 0.5 );
					color += image( position + offset );
				}
				color /= float( NUM_SAMPLES );

				gl_FragColor = vec4( vec3( color ), 1.0 );
			}

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}