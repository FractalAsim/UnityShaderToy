Shader "GLSL/ RainbowFractal" 
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

			#define TIMER		int(mod(time * .125, 4.))

			//#define MODE		TIMER
			#define MODE		2

			#define SCALE 		.0315
			//#define SCALE		1.

			#define ITERATIONS 	31.

			vec4 fractal(in vec2 uv);

			void main(void) 
			{
				vec2 uv			= gl_FragCoord.xy/resolution.xy;
				vec2 aspect		= resolution/min(resolution.x, resolution.y);

				vec2 m			= (mouse - .5) * aspect * SCALE;
				vec2 p       		= (uv -.5) * aspect * SCALE;
				p			-= m;
				
				vec2 c			= p/dot(p,p);
				
				float t			= atan(1.);
				mat2 rm			= mat2(cos(t), sin(t), sin(-t), cos(t));
				c 			*= rm;
				p			= floor(p * 512.);
				c			= floor(c);
				
				
				vec4 f_p		= fractal(p);
				vec4 f_c		= fractal(c);

				
				vec4 result		= vec4(0., 0., 0., 0.);	
				result			+= MODE == 0 ? ceil(f_c.xxxx-f_c.yyyy) : result;
				result			+= MODE == 1 ? ceil(f_p.xxxx-f_p.yyyy) : result;
				result			+= MODE == 2 ? f_c/8. : result;
				result			+= MODE == 3 ? f_p/8. : result;
				
				gl_FragColor		= sin(result*3.);	
			}//sphinx


			vec4 fractal(in vec2 uv)
			{
				vec4 a         		= vec4(uv, 0., 0.);
				vec4 b          	= vec4(0.);
				float rotation     	= .13;
				
				vec4 result      	= vec4(0.);
				for ( float i = 0.; i < ITERATIONS; i++ )
				{
			//		if(mouse.y * ITERATIONS < i) //iteration cutoff
					{
						b        	= fract(a - a.wxyz + rotation);
						b		*= 1. - b;

						a       	+= a.wxyz;
						a       	= a.yzwx * .5 + b.wxyz;	
						
						result		+= b;
					}		
				}
				return result;
			}

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}