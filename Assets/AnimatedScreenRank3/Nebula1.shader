Shader "GLSL/ Nebula1" 
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
			uniform sampler2D backbuffer;

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
				float _t = _Time.y;
				vec3 _c = vec3(0);
				vec2 position = ( gl_FragCoord.xy -  _ScreenParams.xy*.5 ) / _ScreenParams.x;

				for(int i = 0; i < 3; i++)
				{
					float time = _t - float(i)*(float(i)*float(i)+2.)*0.01*(mouse.x-.5);
					
					//vec3 light_color = vec3(1.2,0.8,0.6);
					vec3 light_color = vec3(2,2,2);
					
					float t = time*-50.0*(mouse.x-.5)*(mouse.x-.5)*(mouse.x-.5);

					// 256 angle steps
					float angle = atan(position.y,position.x)/(1.5*3.14159265359);
					angle -= floor(angle);
					float rad = length(position);
					
					float color = 0.0;

					float angleFract = fract(angle*256.);
					float angleRnd = floor(angle*256.)+100.;
					float angleRnd1 = fract(angleRnd*fract(angleRnd*.7235)*45.1);
					float angleRnd2 = fract(angleRnd*fract(angleRnd*.82657)*13.724);
					float t2 = t+angleRnd1*100000.;
					float radDist = sqrt(angleRnd2);
					
					float adist = radDist/rad*.063;
					float dist = (t2*.1+adist)*(mouse.x-.5);
					dist = abs(fract(dist)-1.0);
					color +=  (1.0 / (dist))*cos(0.7*(sin(t)))*adist/radDist/30.0;

					angle = fract(angle+.61);
					
					gl_FragColor = vec4(color,color,color,1.0)*vec4(light_color,1.0);
					
					_c[i] = gl_FragColor.x;
				}
				gl_FragColor.rgb = _c*(1.-1.03/(1.+length(position)));
			}

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}