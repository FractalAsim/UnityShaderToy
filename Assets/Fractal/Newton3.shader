﻿Shader "GLSL/ Newton3" 
{
	// Smooth_Newton_Fractal_v4.glsl              
	// v1 Newton Fractal 1-z^3 by @hintz
	// v2 http://glslsandbox.com/e#39430.1   HSV2RGB changed                     
	// v3 http://glslsandbox.com/e#42786.3   2017-10-02 @hintz
	//    added smooth iteration value, which is needed for future 3D conversion.
	// v4 rotate2d(angle), z4next(z) and z5next added 
	//    
	// What about to go 3D like http://www.josleys.com/show_gallery.php?galid=338 ?
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

			float deltax = 12.0 + sin(_Time.y*0.4) * 10.0;   // scale
			float deltay = _ScreenParams.y / _ScreenParams.x * deltax;
			float theta = _Time.y*0.1;         // rotation speed

			mat2 rotate2d (float angle)    // create 2d rotation matrix
			{
				float ca = cos(angle),  sa = sin(angle);    
				return mat2(ca, -sa, sa, ca);
			}

			// for pretty colors: Hue-Saturation-Value to Red-Green-Blue
			vec4 hsvToRgb(vec3 hsv) 
			{
				vec3 rgb = ((clamp(abs(fract(hsv.x +vec3(0.,2./3.,1./3.))*2.-1.)*3.-1.,0.,1.)-1.)*hsv.y+1.)*hsv.z;
				return vec4 (rgb,1.0);
			}

			// complex number multiplication: a * b
			vec2 mul(vec2 a, vec2 b)
			{
				return vec2(a.x*b.x - a.y*b.y, a.y*b.x + a.x*b.y);
			}

			// complex number division: a / b 
			vec2 div(vec2 a, vec2 b)
			{
				return vec2((a.x*b.x + a.y*b.y) / (b.x*b.x + b.y*b.y), (a.y*b.x - a.x*b.y) / (b.x*b.x + b.y*b.y));
			}

			//     1 - z^3
			// z - -------
			//     3 * z^2
			vec2 z3next(vec2 z)
			{
				vec2 z2 = mul(z,z);
				vec2 z3 = mul(z2,z);
				return z - div(vec2(1.0,0.0)+z3, 3.0*z2);
			}

			//     1 - z^4
			// z - -------
			//     4 * z^3
			vec2 z4next(vec2 z)
			{
				vec2 z2 = mul(z,z);
				vec2 z3 = mul(z2,z);
				vec2 z4 = mul(z2,z2);	
				return z - div(vec2(1.0,0.0)+z4, 4.0*z3);
			}

			//     1 - z^5
			// z - -------
			//     5 * z^4
			vec2 z5next(vec2 z)
			{
				vec2 z2 = mul(z,z);
				vec2 z3 = mul(z2,z);
				vec2 z4 = mul(z2,z2);	
				vec2 z5 = mul(z3,z2);	
				return z - div(vec2(1.0,0.0)+z5, 5.0*z4);
			}

			//--- please select function ---
			//#define zFunc(z) z = z3next(z)
			//#define zFunc(z) z = z4next(z)
			#define zFunc(z) z = z5next(z)

			vec2 newtonFractal(vec2 z)
			{
				for (int n=0; n<1000; n++)
				{
					vec2 old = z;
					zFunc(z);
					float d = length(z - old);
					if (d < 0.01)
					{
						float u = float(n) + log2(log(0.01) / log(d));
						return vec2(z.x + z.y + _Time.y*0.1, u*0.03);
					}
				}
				return z;
			}

			void main()
			{
				vec2 uv = vec2(deltax,deltay) * (gl_FragCoord.xy / _ScreenParams.xy - 0.5);
				uv *= rotate2d (theta);

				vec2 results = newtonFractal(uv);  // calulate newton fractal 

				vec3 hsv = vec3(results.x + results.y, 0.8, 1.0 - results.y);
					
				gl_FragColor = hsvToRgb(hsv);
			}

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}