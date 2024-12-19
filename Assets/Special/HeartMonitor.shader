Shader "GLSL/ HeartMonitor" 
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

			void main1( void ) 
			{
				vec2 position = ( gl_FragCoord.xy / resolution.xy ) + mouse / 4.0;

				float color = 0.0;
				color += sin( position.x * cos( time / 15.0 ) * 80.0 ) + cos( position.y * cos( time / 15.0 ) * 10.0 );
				color += sin( position.y * sin( time / 10.0 ) * 40.0 ) + cos( position.x * sin( time / 25.0 ) * 40.0 );
				color += sin( position.x * sin( time / 5.0 ) * 10.0 ) + sin( position.y * sin( time / 35.0 ) * 80.0 );
				color *= sin( time / 10.0 ) * 0.5;

				gl_FragColor = vec4( vec3( color, color * 0.5, sin( color + time / 3.0 ) * 0.75 ), 1.0 );

			}


			float sinc(float x)
			{
				return (x == 0.0) ? 1.0 : sin(x) / x;
			}

			float triIsolate(float x)
			{
				return abs(-1.0 + fract(clamp(x, -0.5, 0.5)) * 2.0);
			}

			float waveform(float x)
			{
				float prebeat = -sinc((x - 0.37) * 40.0) * 0.6 * triIsolate((x - 0.4) * 1.0);
				float mainbeat = (sinc((x - 0.5) * 60.0)) * 1.2 * triIsolate((x - 0.5) * 0.7) * 1.5;
				float postbeat = sinc((x - 0.91) * 15.0) * 0.85;
				return (prebeat + mainbeat + postbeat) * triIsolate((x - 0.625) * 0.8);
			}

			void main()
			{
				vec2 uv = ( gl_FragCoord.xy / resolution.xy );
				
				float wave = waveform(uv.x * 1.1 + 0.2) * 1.5;
				
				//wave -= sin(fract(iTime * 1.2 - 0.25)) * 0.1;
				
				float light = 1.0 - fract((1.0 - uv.x) + fract(time * 1.2));
				light *= 4.0;
				
				
				float dist = pow(abs((uv.y * 4.0  - 1.5) - wave), 0.05);

				gl_FragColor = vec4(vec3(light, 0.0, 0.0) * (1.0 - dist),1.0);
				
				uv.x *= resolution.x / resolution.y;
				if (fract(uv.x * 10.0) < 0.03 || fract(uv.y * 10.0) < 0.03) 
				{
					gl_FragColor = max(gl_FragColor, vec4(0.1));
				}
			}

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}