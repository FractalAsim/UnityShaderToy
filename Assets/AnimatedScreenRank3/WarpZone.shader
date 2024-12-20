﻿Shader "GLSL/ WarpZone" 
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

			float offset=0.0;
			void main()
			{
				
				vec2 uv = gl_FragCoord.xy / resolution.xy *2.0-1.0;
				
				
				float s = 0.0, v = 0.0;
				
				// wait ~6 sec !!
					offset = time*time/200.;
			
				
				float speed2 = (cos(offset)+1.0)*2.0;
				float speed = speed2+.1;
				
				offset += sin(offset)*.56;
				offset *= 0.6;
				vec3 col = vec3(0);
				vec3 init = vec3(sin(offset * .002)*.3, .35 + cos(offset * .005)*.3, offset * 0.2);
				for (int r = 0; r < 90; r++) 
				{
					vec3 p = init + s * vec3(uv, 0.05);
					p.z = fract(p.z);
					// Thanks to Kali's little chaotic loop...
					for (int i=0; i < 9; i++)	p = abs(p * 2.04) / dot(p, p) - .9;
					v += pow(dot(p, p), .7) * .06;
					col +=  vec3(v * 0.2+.4, 12.-s*2., .1 + v * 1.) * v * 0.00003;
					s += .025;
				}
				gl_FragColor = vec4(clamp(col, 0.0, 1.0), 1.0);
			}

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}