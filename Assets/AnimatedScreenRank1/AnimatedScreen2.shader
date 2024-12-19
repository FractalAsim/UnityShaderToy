Shader "GLSL/ AnimatedScreen2" 
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

			out vec4 texcoord;

			void main()
			{
				texcoord = gl_MultiTexCoord0;
				gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex; // Draws the Vertex at the correct position in world
			}

			#endif // Ends vertex program/shader

			#ifdef FRAGMENT // Begin fragment program/shader

			in vec4 texcoord;

			void main()
			{
				//gl_FragCoord.xy / _ScreenParams.xy = texcoord.yx
				vec2 position = (texcoord.yx - 0.5) * 2.0;
				//vec2 position = ( gl_FragCoord.xy / _ScreenParams.xy - 0.5 ) * 2.0;

				float color = 1.0 - ( sin( _Time.y * 2.0 ) * 0.5 + 0.5) * distance( vec2( 0.0 ), position );

				gl_FragColor = vec4( vec3( color ), 1.0 );
			}

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}