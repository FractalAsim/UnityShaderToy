﻿Shader "GLSL/ IntertwineBars" 
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

			vec3 mod289(vec3 x) {
			return x - floor(x * (1.0 / 289.0)) * 289.0;
			}

			vec2 mod289(vec2 x) {
			return x - floor(x * (1.0 / 289.0)) * 289.0;
			}

			vec3 permute(vec3 x) {
			return mod289(((x*34.0)+1.0)*x);
			}

			float snoise(vec2 v)
			{
			const vec4 C = vec4(0.211324865405187,  // (3.0-sqrt(3.0))/6.0
								0.366025403784439,  // 0.5*(sqrt(3.0)-1.0)
								-0.577350269189626,  // -1.0 + 2.0 * C.x
								0.024390243902439); // 1.0 / 41.0
			// First corner
			vec2 i  = floor(v + dot(v, C.yy) );
			vec2 x0 = v -   i + dot(i, C.xx);

			// Other corners
			vec2 i1;
			//i1.x = step( x0.y, x0.x ); // x0.x > x0.y ? 1.0 : 0.0
			//i1.y = 1.0 - i1.x;
			i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
			// x0 = x0 - 0.0 + 0.0 * C.xx ;
			// x1 = x0 - i1 + 1.0 * C.xx ;
			// x2 = x0 - 1.0 + 2.0 * C.xx ;
			vec4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;

			// Permutations
			i = mod289(i); // Avoid truncation effects in permutation
			vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 ))
					+ i.x + vec3(0.0, i1.x, 1.0 ));

			vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
			m = m*m ;
			m = m*m ;

			// Gradients: 41 points uniformly over a line, mapped onto a diamond.
			// The ring size 17*17 = 289 is close to a multiple of 41 (41*7 = 287)

			vec3 x = 2.0 * fract(p * C.www) - 1.0;
			vec3 h = abs(x) - 0.5;
			vec3 ox = floor(x + 0.5);
			vec3 a0 = x - ox;

			// Normalise gradients implicitly by scaling m
			// Approximation of: m *= inversesqrt( a0*a0 + h*h );
			m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );

			// Compute final noise value at P
			vec3 g;
			g.x  = a0.x  * x0.x  + h.x  * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot(m, g);
			}

			void main( void ) {
				vec2 fc = gl_FragCoord.xy;
				vec2 fp = fc / resolution;
				
				float shade = 0.5;
				float light = 1.;
				float dark = 0.;
				float gap = -2.;
				
				float sbase = 50.;
				vec2 s = resolution / floor(0.5 + resolution/vec2(sbase, sbase));
				
				vec2 b = vec2(8., 4.)*fract(fc/s);
				float c = -1.;
				if (b.y < 1.) {
					if (b.x < 1.) {
						c = shade;
					} else if (b.x < 3.) {
						c = mix(shade, dark, smoothstep(1., 3., b.x));
					} else if (b.x < 4.) {
						c = light;
					} else if (b.x < 5.) {
						c = shade;
					} else if (b.x < 7.) {
						c = mix(dark, light, smoothstep(5., 7., b.x));
					} else if (b.x <= 8.) {
						c = light;
					}
				} else if (b.y < 2.) {
					if (b.x < 1.) {
						c = shade;
					} else if (b.x < 3.) {
						c = gap;
					} else if (b.x < 4.) {
						c = light;
					} else if (b.x < 5.) {
						c = shade;
					} else if (b.x < 7.) {
						c = gap;
					} else if (b.x <= 8.) {
						c = light;
					}
				} else if (b.y < 3.) {
					if (b.x < 1.) {
						c = shade;
					} else if (b.x < 3.) {
						c = mix(dark, light, smoothstep(1., 3., b.x));
					} else if (b.x < 4.) {
						c = light;
					} else if (b.x < 5.) {
						c = shade;
					} else if (b.x < 7.) {
						c = mix(shade, dark, smoothstep(5., 7., b.x));
					} else if (b.x <= 8.) {
						c = light;
					}
				} else if (b.y <= 4.) {
					if (b.x < 1.) {
						c = shade;
					} else if (b.x < 3.) {
						c = gap;
					} else if (b.x < 4.) {
						c = light;
					} else if (b.x < 5.) {
						c = shade;
					} else if (b.x < 7.) {
						c = gap;
					} else if (b.x <= 8.) {
						c = light;
					}
				}
				
				if (c == -1.) {
					gl_FragColor = vec4(0.7, 0.2, 0.2, 1.);
				} else {
					float g = 0.;
					if (c == gap) {
						g = 0.15;
					} else {
						g = mix(0.2, 0.6, c) * mix(0.97, 1.0, snoise(fc/40.) + snoise(fc/20.) + snoise(fc/10.) + snoise(fc/5.));
					}
					g *= mix(0.4, 1., fp.y);
					gl_FragColor = vec4(g, g, g, 1.);
				}
			}

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}