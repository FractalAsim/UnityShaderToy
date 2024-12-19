Shader "GLSL/ RainbowStaticNoise" 
{
	Properties
	{
		mouse ("Mouse", Vector) = (0,0,0,0)
		backbuffer ("Backbuffer", 2D) = "BackBuffer"
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
			uniform sampler2D backbuffer;

			#ifdef VERTEX // Begin vertex program/shader

			void main()
			{
				gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex; // Draws the Vertex at the correct position in world
			}

			#endif // Ends vertex program/shader

			#ifdef FRAGMENT // Begin fragment program/shader


			void main()
			{
				gl_FragColor = vec4(0,0,0,0);
				if(gl_FragCoord.x <= 2.){
					int mx3 = int(mod(gl_FragCoord.x*mouse.y+gl_FragCoord.y*mouse.x, 3.));
					gl_FragColor.g += .25+.5*float(mx3 == 1);
					gl_FragColor.r += .25+.5*float(mx3 == 2);
					gl_FragColor.b += .25+.5*float(mx3 == 0);
					
					gl_FragColor += float(
						(int(mod(gl_FragCoord.y, 3.)) == 1)
						&& (mx3 == 1)
					);
					return;
				}
				
				for(int i = 0; i <= 2; i++){
					vec2 sp = vec2(gl_FragCoord.x-1., gl_FragCoord.y+gl_FragCoord.x)/_ScreenParams;
					vec4 sc = texture2D(backbuffer, fract(sp));
					gl_FragColor[i] += 1.-sc[i];
				}
				
				for(int i = 0; i <= 2; i++){
					vec2 sp = vec2(gl_FragCoord.x-1., gl_FragCoord.y-gl_FragCoord.x)/_ScreenParams;
					vec4 sc = texture2D(backbuffer, fract(sp));
					gl_FragColor[i] = fract(gl_FragColor[i]+sc[i]);
				}
				if(gl_FragCoord.x > _ScreenParams.x/2.) gl_FragColor.a = 1.;
			}

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}