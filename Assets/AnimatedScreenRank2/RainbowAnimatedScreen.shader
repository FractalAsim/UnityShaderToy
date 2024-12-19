Shader "GLSL/ RainbowAnimatedScreen" 
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

			//uniform vec2 mouse;
			uniform vec2 _ScreenParams; 
			uniform vec4 _Time; // (t/20, t, t*2, t*3)
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

			vec3 rb( const float a ) 
			{
				float r = -1. + min( mod( a     , 6. ), 6. - mod( a     , 6. ) );
				float g = -1. + min( mod( a + 2., 6. ), 6. - mod( a + 2., 6. ) );
				float b = -1. + min( mod( a + 4., 6. ), 6. - mod( a + 4., 6. ) );
				
				r = clamp( r, 0., 1. );
				g = clamp( g, 0., 1. );
				b = clamp( b, 0., 1. );
				
				return vec3( r,g,b );
			}

			void main()
			{
				vec2 p =  gl_FragCoord.xy / _ScreenParams.xy*2.-1.  ;
	 
				float scl = mod(gl_FragCoord.y+(4.*p.y+_Time.y ),2.)-mod(gl_FragCoord.x,2.0)*0.5;
				
				gl_FragColor = vec4( rb(4.*p.y+(_Time.y*1.)), 1.)*scl  ;
			}

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}