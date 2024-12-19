Shader "GLSL/ Pattern1" 
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

			uniform vec2 _ScreenParams; 
			//uniform vec2 mouse;
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

			float dist(vec2 pos)
			{
				return length(pos) - 0.1;
			}

			void main()
			{
				vec2 position = gl_FragCoord.xy - _ScreenParams / 2.0;
				float color = smoothstep(2.0, 4.0, abs(length(position) - 50.0 + sin(atan(position.y, position.x) * 4.0 - 3.141 / 2.0) * 7.0));

				gl_FragColor = vec4(vec3(color), 1.0 );
			}

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}