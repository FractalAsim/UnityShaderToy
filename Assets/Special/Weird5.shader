Shader "GLSL/ Weird5" 
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

			#ifdef VERTEX // Begin vertex program/shader

			void main()
			{
				gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex; // Draws the Vertex at the correct position in world
			}

			#endif // Ends vertex program/shader

			#ifdef FRAGMENT // Begin fragment program/shader

			float t=time/65.*30.,C,D;

			vec2 B(vec2 a)
			{
			return vec2(log(length(a)),atan(a.y,a.x)-6.3);
			}

			vec3 F(vec2 E)
			{
			vec2 e_=E;
			float c=5.;
			const int i_max= 60;
			for(int i=0; i<i_max; i++)
				{
				e_=B(vec2(e_.x,abs(e_.y)))+vec2(.1*sin(t/3.)-.1,5.+.1*cos(t/5.));
				c += length(e_);
				}
			float d = log2(log2(c*.05))*6.;
			return vec3(.1+.7*cos(d),0.24+.5*cos(d-.7),.7+.7*cos(d-.7));
			}

			void main(void)
			{
			gl_FragColor=vec4(F((gl_FragCoord.xy/resolution.x-vec2(.1,.4))*(9.1-9.*cos(t/9.))),1.);
			}

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}