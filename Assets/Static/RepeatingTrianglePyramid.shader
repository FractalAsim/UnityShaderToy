Shader "GLSL/ RepeatingTrianglePyramid" 
{
	//Catzpaw 2017
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

			float pattern(vec2 p)
			{
				p.x *= 0.866;
				p.x -= p.y *0.5;
				p = mod(p,1.0);
				return p.x + p.y < 1.0 ? 0.0 : 1.0;
			}

			void main()
			{
				gl_FragColor = vec4(pattern(gl_FragCoord.xy*.0173));
			}

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}