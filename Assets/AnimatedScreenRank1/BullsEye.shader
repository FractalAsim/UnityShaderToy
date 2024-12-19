Shader "GLSL/ BullsEye" 
{
	Properties
	{
		mouse ("Mouse", Vector) = (0,0,0,0)
		[Toggle] _3D("3D Mode", Float) = 0
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
			uniform float _3D;
			uniform vec2 _ScreenParams; 
			uniform vec4 _Time; // (t/20, t, t*2, t*3)
			//uniform  vec4 unity_DeltaTime //  (dt, 1/dt, smoothDt, 1/smoothDt).
			//uniform  vec4 _SinTime // (t/8, t/4, t/2, t).
			//uniform  vec4 _CosTime // (t/8, t/4, t/2, t).

			#define resolution _ScreenParams
			#define time _Time.y

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

			//texcoord.xy = gl_FragCoord.xy / _ScreenParams.xy
			//gl_FragCoord.xy = texcoord.yx * _ScreenParams.xy

			void main()
			{
				if(_3D>0)
				{
					vec2 position = vec2(texcoord.x * mouse.x, texcoord.y * mouse.y);

					float color = sin(distance((texcoord.xy-0.5) * _ScreenParams.xy, position) / 8.0 + time);

					gl_FragColor = vec4(color, color, color, 1.0 );
				}
				else
				{
					vec2 position = vec2(resolution.x * mouse.x, resolution.y * mouse.y);

					float color = sin(distance(gl_FragCoord.xy, position) / 8.0 + time);

					gl_FragColor = vec4(color, color, color, 1.0 );
				}
			}

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}