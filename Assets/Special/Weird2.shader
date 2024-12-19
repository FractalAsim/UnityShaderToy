Shader "GLSL/ Weird2" 
{
	//Robert Schütze (trirop) 07.12.2015
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

			vec2 B(vec2 a)
			{
				return vec2(log(length(a)),atan(a.y,a.x)-6.3);
			}

			float t=_Time.y/65.*30.,C,D;

			vec3 F(vec2 E)
			{
				vec2 e_=E;
				float c=6.;
				const int i_max=30;
				for(int i=0; i<i_max; i++)
					{
					e_=B(vec2(e_.x,abs(e_.y)))+vec2(.1*sin(t/3.)-.1,5.+.1*cos(t/5.));
					c += length(e_);
					}
				float d = log2(log2(c*.05))*6.;
				return vec3(.7+tan(.7*cos(d)),.5+.5*cos(d-.7),.7+sin(.7*cos(d-.7)));
			}

			void main(void)
			{
				gl_FragColor=vec4(F(vec2(dot(F(gl_FragCoord.xy/_ScreenParams.x).zx,F(vec2(gl_FragCoord.y,cos(t))).yz),cos(9.0-9.1*sin(-t)))),1.);
			}

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}