//https://www.shadertoy.com/view/4dc3D8
Shader "GLSL/ CircleWave" 
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

			#define resolution _ScreenParams
			#define time _Time.y

			#define SCALE 20
			#define SPEED 9
			#define FREQUENCY 0.3
			float d;
			#define C(p)  min(1., sqrt(10.*abs(length(p-.5)-.4)))
			#define D(p,o)  ( (d=length(p-o)*5.)<=.6 ? d:1. )

			#ifdef VERTEX // Begin vertex program/shader

			void main()
			{
				gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex; // Draws the Vertex at the correct position in world
			}

			#endif // Ends vertex program/shader

			#ifdef FRAGMENT // Begin fragment program/shader

			void main()
			{
				
				vec2 R = resolution.xy, 
					p = SCALE*(gl_FragCoord.xy+gl_FragCoord.xy/R)/R.y,
					f = fract(p);
				p=floor(p);
				float t=(p.x+p.y)*FREQUENCY+time*SPEED;
				vec2 o=vec2(cos(t),sin(t))*.4+.5;
				gl_FragColor.xyz = vec3(C(f)*D(f,o));
			}

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}