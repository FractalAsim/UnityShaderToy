Shader "GLSL/ Brazilian flag" 
{
	// Simple waving brazilian flag by feliposz (2017-10-06)
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

			vec3 flag(vec2 position) 
			{
				float centerDist = length(position);
				float diamond = position.x - position.y;
				bool r = (centerDist > 0.5) && (position.x*0.5 + 0.8 > position.y) && (position.x*0.5 - 0.8 < position.y) && (-position.x*0.5 - 0.8 < position.y) && (-position.x*0.5 + 0.8 > position.y);
				bool g = centerDist >= 0.5;
				bool b = centerDist < 0.5;
				bool valid = abs(position.x) <= 2.0 && abs(position.y) <= 1.0;
				return valid ? vec3( r ? 1.0 : 0.0, (r && g) ? 1.0 : (g ? 0.6 : 0.0), b ? 1.0 : 0.0) : vec3(0.0, 0.0, 0.0);
			}

			in vec4 texcoord;
			void main( void ) 
			{

				vec2 position = vec2(texcoord.y - 0.5,texcoord.x-0.5)*4;
				//vec2 position = 2.0*( gl_FragCoord.xy - 0.5*_ScreenParams.xy ) / _ScreenParams.y;

				vec2 wave = vec2(sin(5.0*position.x+_Time.y) + 0.3*sin(position.y*7.0), sin(5.0*position.x+_Time.y));
				
				gl_FragColor = vec4(flag(1.2*position + 0.05*wave), 1.0);
			}

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}