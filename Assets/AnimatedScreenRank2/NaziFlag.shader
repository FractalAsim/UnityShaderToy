Shader "GLSL/ NaziFlag" 
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

			const float cross_width = 0.07;
			
			float diamond(vec2 pos) 
			{
				return float(pos.x + pos.y < cross_width && pos.x - pos.y > -cross_width
					&& pos.x + pos.y > -cross_width && pos.x - pos.y < cross_width);	
			}
			vec3 rotate(vec3 vec, vec3 axis, float ang)
			{
				return vec * cos(ang) + cross(axis, vec) * sin(ang) + axis * dot(axis, vec) * (1.0 - cos(ang));
			}

			void main()
			{
				const float pi = 3.141592653589793;
	
				vec3 red = vec3(1.0, 0.0, 0.0);
				vec3 white = vec3(1.0, 1.0, 1.0);
				vec3 black = vec3(0.0, 0.0, 0.0);
				
				// fixed your aspect, you fucking nazi
				vec2 pos = vec3(gl_FragCoord.xy / _ScreenParams - vec2(0.5, .5),0.).xy;
				pos.x *= _ScreenParams.x/_ScreenParams.y;
				pos = rotate(vec3(pos,0.),vec3(0.,0.0,1.0),(_Time.y)).xy;
				
				float r2 = pos.x*pos.x + pos.y*pos.y;
				
				vec3 color = mix(white, red, atan((r2 - 0.15)*1e3)/pi+0.5);
				
				color = mix(color, black, diamond(pos));
				color = mix(color, black, diamond(pos + vec2(cross_width, cross_width)));
				color = mix(color, black, diamond(pos + vec2(cross_width*2.0, cross_width*2.0)));
				color = mix(color, black, diamond(pos + vec2(-cross_width, cross_width)));
				color = mix(color, black, diamond(pos + vec2(-cross_width*2.0, cross_width*2.0)));
				color = mix(color, black, diamond(pos + vec2(-cross_width, -cross_width)));
				color = mix(color, black, diamond(pos + vec2(-cross_width*2.0, -cross_width*2.0)));
				color = mix(color, black, diamond(pos + vec2(cross_width, -cross_width)));
				color = mix(color, black, diamond(pos + vec2(cross_width*2.0, -cross_width*2.0)));
				color = mix(color, black, diamond(pos + vec2(cross_width, -cross_width*3.0)));
				color = mix(color, black, diamond(pos + vec2(-cross_width, cross_width*3.0)));
				color = mix(color, black, diamond(pos + vec2(cross_width*3.0, cross_width)));
				color = mix(color, black, diamond(pos + vec2(-cross_width*3.0, -cross_width)));
				color = mix(color, black, diamond(pos + vec2(0.0, -cross_width*4.0)));
				color = mix(color, black, diamond(pos + vec2(0.0, cross_width*4.0)));
				color = mix(color, black, diamond(pos + vec2(cross_width*4.0, 0.0)));
				color = mix(color, black, diamond(pos + vec2(-cross_width*4.0, 0.0)));
				
				gl_FragColor = vec4(color, 1.0);
			}

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}