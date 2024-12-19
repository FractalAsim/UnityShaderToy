Shader "GLSL/ WaveInterferrance" 
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
				vec2 aspect = vec2(_ScreenParams.x/_ScreenParams.y, 1.0);
				vec2 pos = (gl_FragCoord.xy - 0.5*_ScreenParams)/_ScreenParams.y;
				vec2 mousePos = (mouse - 0.5)*aspect;
				vec2 invPos = (0.5 - mouse)*aspect;
				float centerDist = 1.0 - length(pos);
				float mouseDist = length(pos - mousePos);
				float hotSpot1 = 0.2/mouseDist;
				float invDist = length(pos-invPos);
				float hotSpot2 = 0.2/invDist;
				gl_FragColor = vec4(centerDist, hotSpot1 * hotSpot2, sin(invDist*55.0 + _Time.y) * sin(mouseDist*55.0 + _Time.y), 1.0);
			}

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}