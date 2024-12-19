Shader "GLSL/ SineWave" 
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

			void main()
			{
				vec2 pos = gl_FragCoord.xy / _ScreenParams;
				pos.y = pos.y * 4.0 - 2.0;
				
				float pi = 3.141569;
				float amplitude = 1.0;
				float speed = 1.0;
				float length = 10.0;
				
				float frequency = speed / length;
				float angular_frequency = frequency * 2.0 * pi;
				
				float height = amplitude * cos(5.0 * pos.x - angular_frequency * _Time.y );

				if(pos.y < height)
					gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
			}

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}