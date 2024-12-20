﻿Shader "GLSL/ Nebula2" 
{
	// MODS BY NRLABS
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

			// Component wise blending
			#define Blend(base, blend, funcf)       vec3(funcf(base.r, blend.r), funcf(base.g, blend.g), funcf(base.b, blend.b))
			// Blend Funcs
			#define BlendScreenf(base, blend)       (1.0 - ((1.0 - base) * (1.0 - blend)))
			#define BlendMultiply(base, blend)       (base * blend)
			#define BlendScreen(base, blend)       Blend(base, blend, BlendScreenf)

			#ifdef VERTEX // Begin vertex program/shader

			void main()
			{
				gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex; // Draws the Vertex at the correct position in world
			}

			#endif // Ends vertex program/shader

			#ifdef FRAGMENT // Begin fragment program/shader

			vec3 nrand3( vec2 co )
			{
				vec3 a = fract( cos( co.x*8.3e-3 + co.y )*vec3(1.3e5, 4.7e5, 2.9e5) );
				vec3 b = fract( sin( co.x*0.3e-3 + co.y )*vec3(8.1e5, 1.0e5, 0.1e5) );
				vec3 c = mix(a, b, 0.5);
				return c;	
			}

			float snoise(vec3 uv, float res)
			{
				const vec3 s = vec3(1e0, 1e2, 1e4);
				
				uv *= res;
				
				vec3 uv0 = floor(mod(uv, res))*s;
				vec3 uv1 = floor(mod(uv+vec3(1.), res))*s;
				
				vec3 f = fract(uv); f = f*f*f*(3.0-2.0*f);

				vec4 v = vec4(uv0.x+uv0.y+uv0.z, uv1.x+uv0.y+uv0.z,
								uv0.x+uv1.y+uv0.z, uv1.x+uv1.y+uv0.z);

				vec4 r = fract(sin(v*1e-3)*1e5);
				float r0 = mix(mix(r.x, r.y, f.x), mix(r.z, r.w, f.x), f.y);
				
				r = fract(sin((v + uv1.z - uv0.z)*1e-3)*1e5);
				float r1 = mix(mix(r.x, r.y, f.x), mix(r.z, r.w, f.x), f.y);
				
				return mix(r0, r1, f.z)*2.-0.3;
			}

			vec3 clouds(vec2 tc,float iter)
			{
				tc /= 10000.0;
				float color = 0.0;
				for(int i = 0; i <= 2; i++)
				{
					float power = pow(2.0, float(i));
					color += (0.5 / power) * snoise(vec3(tc,0.0), power*16.0);
				}
				return vec3(color,color,color);
			}

			vec3 getcolor(vec2 coords,float intensity)
			{
				coords = coords/6000.0;
				return normalize(vec3(snoise(vec3(coords,0.0),intensity),
							snoise(vec3(coords,0.1),intensity),
							snoise(vec3(coords,0.2),intensity)   ));
			}

			vec3 genstars(float starsize, float density, float intensity, vec2 seed)
			{
				vec3 rnd = nrand3( floor(seed*(1.0/starsize)) );
				vec3 stars = vec3(pow(rnd.y,density))*intensity;
				rnd = clouds(seed,1.0);
				return BlendMultiply(stars,rnd);
			}

			void main()
			{
				vec2 offset = vec2(_Time.y*cos(_Time.y/100.0),_Time.y*sin(_Time.y/100.0));
				float n = 30.0;
				
				vec2 p = 2.0 * (gl_FragCoord.xy / _ScreenParams) - 1.0 ;
				p.x *= _ScreenParams.x/_ScreenParams.y;
				
				p *= 500.0;
				
				vec3 stars = clouds(p.xy+offset*n,5.0);
				vec3 color = getcolor(p.xy+offset*n,11.0)*0.2;
				color = BlendMultiply(stars,color);
				stars = genstars(3.0,16.0,2.0+sin(_Time.y/1.0),p.xy+offset*n);
				color = BlendScreen(color,stars);
				n=20.0;
				stars = genstars(2.0,16.0,1.0,p.xy+offset*n);
				n=10.0;
				color = BlendScreen(color,stars);
				stars = genstars(1.0,16.0,1.0,p.xy+offset*n)*0.8;
				color = BlendScreen(color,stars);
				gl_FragColor = vec4(color,1);
			}

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}