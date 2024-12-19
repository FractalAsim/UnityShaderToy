Shader "GLSL/ RainbowPaint" 
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

			const float color_intensity = 0.;
			const float Pi = 3.14159;

			void main()
			{
				vec2 p= gl_FragCoord.xy - resolution / 2.;
				for(int i=1;i<9;i++)
				{
						vec2 newp=p;
					float ii = float(i);  
						newp.x+=0.55/ii*sin(ii*Pi*p.y+time*.01+cos((time/(10.*ii))*ii));
						newp.y+=0.55/ii*cos(ii*Pi*p.x+time*.01+sin((time/(10.*ii))*ii));
						p=newp;
				}
				gl_FragColor = vec4(cos(p.x+p.y+3.+time)*.5+.5, sin(p.x+p.y+3.+time)*.5+.5, (sin(p.x+p.y+9.+time)+cos(p.x+p.y+12.+time))*.25+.5, .5);
			}

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}