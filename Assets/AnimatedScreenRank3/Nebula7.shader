Shader "GLSL/ Nebula7" 
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

			vec2 rand2(vec2 p)
			{
				p = vec2(dot(p, vec2(102.9898,78.233)), dot(p, vec2(26.65125, 83.054543))); 
				return fract(sin(p) * 43758.5453);
			}

			float rand(vec2 p)
			{
				return fract(sin(dot(p.xy ,vec2(505.90898,18.233))) * 43037.5453);
			}

			// Thanks to David Hoskins https://www.shadertoy.com/view/4djGRh
			float stars(in vec2 x, float numCells, float size, float br)
			{
				vec2 n = x * numCells;
				vec2 f = floor(n);

				float d = 1.0e10;
				for (float i = -1.; i <= 1.; ++i)
				{
					for (float j = -1.; j <= 1.; ++j)
					{
						vec2 g = f + vec2(i, j);
						g = n - g - rand2(mod(g, numCells)) + rand(g);
						// Control size
						g *= 1. / (numCells * size);
						d = min(d, dot(g, g));
					}
				}
				
				return br * (smoothstep(.98, 1., (1. - sqrt(d))));
			}
			

			void main()
			{
				float res  = max(resolution.x, resolution.y);

				vec2 coord = gl_FragCoord.xy / res;
					
				vec3 result = vec3(0.);
				
				float s = 1.;
				float n = 5.;
				
				for(int i = 0; i<9; i++){
					float t = time / 2.;
					result +=
						stars(
							vec2(
								coord.x/2. + time/6. * s,
								coord.y/2. - sin(time/6.) * s
								),
							n,
							s/4.,
							1.
							)
						* vec3(s*2., s*2., 1); 

					s /= 1.33;
					n *= 1.5;
				}

				gl_FragColor = vec4(result,1.);
			}

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}