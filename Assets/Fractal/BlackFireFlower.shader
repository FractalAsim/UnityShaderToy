Shader "GLSL/ BlackFireFlower" 
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

			void main()
			{
				gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex; // Draws the Vertex at the correct position in world
			}

			#endif // Ends vertex program/shader

			#ifdef FRAGMENT // Begin fragment program/shader

			void main()
			{
				vec2 uv =( gl_FragCoord.xy*2.-_ScreenParams.xy)/min(_ScreenParams.x,_ScreenParams.y);
				float t = _Time.y*.2;
				vec2 z = vec2(.1*uv.x+.48+cos(t) * .1,.1*uv.y+.25+sin(t)*.1);
				vec2 c = vec2(-.66,-.47);
				//c+=mouse*.1;
				c.x += cos(_Time.y*.31)*.066;
				c.y += sin(_Time.y*.47)*.025;

				float a = 0.,b = 0.;
				for(int i=0;i<80;i++)
				{
					float x=z.x*z.x-z.y*z.y+c.x,y=z.y*z.x*2.+c.y;
					if(x*x+y*y>3.)
						break;
					z.x=x;z.y=y;
					a += .01;
					b += x*y;
				}
				b += sin(_Time.y*.5)*6.28;
				gl_FragColor = vec4(vec3(a*b,a*b*.1,tan(b)*.05),1);
			}

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}