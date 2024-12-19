Shader "GLSL/ RedBlackCheckered" 
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

			#define PI 3.1415926
			#define COLS 15.0
			#define ROWS 10.0

			void main( void ) 
			{
				vec2 pos = texcoord.xy;

				float pattern = sign(sin(pos.x * PI * COLS)) * sign(sin(pos.y * PI * ROWS));
				
				bool col = floor(pos.x * COLS) / COLS == floor(mouse.x * COLS) / COLS;
				bool row = floor(pos.y * ROWS) / ROWS == floor(mouse.y * ROWS) / ROWS;

				gl_FragColor = vec4( pattern, col ? 0.5 : 0.0, row ? 0.5 : 0.0, 1.0 );
			}

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}