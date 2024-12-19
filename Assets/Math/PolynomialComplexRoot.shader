Shader "GLSL/ PolynomialComplexRoot" 
{
	Properties
	{
		mouse ("Mouse", Vector) = (0,0,0,0)
	}
	SubShader
	{	
		//Displays all complex roots of a set of polynomials.
		//Polynomial is of the form:

		//±z^8 ±z^7 ±z^6 ±z^5 ±z^4 ... ±z -C

		//0th-order coefficient, C, is a complex value that changes over time, favoring 0.

		//A somewhat less symmetrical pattern, but one which reveals more structure, is achieved 
		//by replacing all or most of the negative coefficients with 0.

		//Jonathan Lidbeck		
		
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


			// Configuration
			#define MULTICOLOR true
			#define MAP_DOTS true
			#define MAP_AXES true

			// Constants
			#define TWOPI 6.28318530718
			#define PI 3.14159265359
			const vec2 one=vec2(1.,0.);
			const vec4 purple = vec4(5., 1., 10., 1.);
			const vec4 red = vec4(10., 2., 1., 1.);
			const vec4 orange = vec4(9., 4., 0.3, 1.);
			const vec4 yellow = vec4(8., 5., 1., 1.);
			const vec4 green = vec4(3., 9., 1., 1.);
			const vec4 teal = vec4(1., 4., 10., 1.);
			mat4 colors = mat4(purple, teal, orange, green);

			float pulse1 = sin(_Time.y * 3.);
			float pulse2 = pulse1 * pulse1;
			float pulse4 = pulse2 * pulse2;
			float pulse = pulse4 * pulse4;

			#ifdef MAP_DOTS
			float dimness = (10000. );//* (1. - cos(time * 0.2)) );
			#else
			float dimness = (1000000. * mouse.y);
			#endif

			vec2 csq(vec2 v) 
			{
				return vec2(v.x*v.x - v.y*v.y, 2.*v.x*v.y);
			}

			vec2 cmul(vec2 a, vec2 b) 
			{
				return vec2(a.x*b.x - a.y*b.y, a.x*b.y + a.y*b.x);
			}

			// complex to integer exponent
			// computes all z^N for 1<=N<=9
			void cpowers(vec2 z, inout vec2 powers[10]) 
			{
				powers[8] = csq(powers[4] = csq(powers[2] = csq(z)));
				powers[6] = csq(powers[3] = cmul(z, powers[2]));
				powers[5] = cmul(z, powers[4]);
				powers[7] = cmul(z, powers[6]);
				powers[9] = cmul(z, powers[8]);
			}

			vec2 from_polar(vec2 zp) 
			{
				return zp.x * vec2(cos(zp.y), sin(zp.y));
			}

			// root rendering
			#ifdef MULTICOLOR
			#define PIP_TYPE vec4
			#else
			#define PIP_TYPE float
			#endif

			#ifdef MULTICOLOR
			vec4 pipcounter = vec4(1., 0., 0., 0.);
			#endif

			// color root
			PIP_TYPE pip(in vec2 v) 
			{
				float r;
				#ifdef MAP_DOTS
					r = dot(v, v);
				#else
					r = v.x*v.x;
				#endif
					
				#ifdef MULTICOLOR
					pipcounter = pipcounter.yzwx;
					return pipcounter / (1. + dimness * r);
				#else
					return 1. / (1. + dimness * r);
				#endif
			}

			#ifdef VERTEX // Begin vertex program/shader

			void main()
			{
				gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex; // Draws the Vertex at the correct position in world
			}

			#endif // Ends vertex program/shader

			#ifdef FRAGMENT // Begin fragment program/shader

			void main()
			{
				vec2 cc =   0.5 * (1. + cos(_Time.y * 0.2)) * vec2(cos(_Time.y * 0.5), sin(_Time.y * 0.3));
    
				// rough exposure adjustment: with C near zero, roots pile up and become too bright
				dimness /= distance(cc, vec2(0.));
				
				// complex value from pixel position
				vec2 z = 3. * (gl_FragCoord.xy - _ScreenParams.xy * 0.5) / _ScreenParams.y;
				
				vec2 zpow[10];
				cpowers(z, zpow);
				
				// aggregate proximities to all roots
				PIP_TYPE f = 
				pip(                                                                  -cc)
				+ pip(                                                               +z -cc)
				+ pip(                                                      +zpow[2]    -cc)
				+ pip(                                                      +zpow[2] +z -cc)
				+ pip(                                             +zpow[3]             -cc)
				+ pip(                                             +zpow[3]          +z -cc)
				+ pip(                                             +zpow[3] +zpow[2]    -cc)
				+ pip(                                             +zpow[3] +zpow[2] +z -cc)
				+ pip(                                    +zpow[4]                      -cc)
				+ pip(                                    +zpow[4]                   +z -cc)
				+ pip(                                    +zpow[4]          +zpow[2]    -cc)
				+ pip(                                    +zpow[4]          +zpow[2] +z -cc)
				+ pip(                                    +zpow[4] +zpow[3]             -cc)
				+ pip(                                    +zpow[4] +zpow[3]          +z -cc)
				+ pip(                                    +zpow[4] +zpow[3] +zpow[2]    -cc)
				+ pip(                                    +zpow[4] +zpow[3] +zpow[2] +z -cc)
				+ pip(                           +zpow[5]                               -cc)
				+ pip(                           +zpow[5]                            +z -cc)
				+ pip(                           +zpow[5]                   +zpow[2]    -cc)
				+ pip(                           +zpow[5]                   +zpow[2] +z -cc)
				+ pip(                           +zpow[5]          +zpow[3]             -cc)
				+ pip(                           +zpow[5]          +zpow[3]          +z -cc)
				+ pip(                           +zpow[5]          +zpow[3] +zpow[2]    -cc)
				+ pip(                           +zpow[5]          +zpow[3] +zpow[2] +z -cc)
				+ pip(                           +zpow[5] +zpow[4]                      -cc)
				+ pip(                           +zpow[5] +zpow[4]                   +z -cc)
				+ pip(                           +zpow[5] +zpow[4]          +zpow[2]    -cc)
				+ pip(                           +zpow[5] +zpow[4]          +zpow[2] +z -cc)
				+ pip(                           +zpow[5] +zpow[4] +zpow[3]             -cc)
				+ pip(                           +zpow[5] +zpow[4] +zpow[3]          +z -cc)
				+ pip(                           +zpow[5] +zpow[4] +zpow[3] +zpow[2]    -cc)
				+ pip(                           +zpow[5] +zpow[4] +zpow[3] +zpow[2] +z -cc)
				+ pip(                  +zpow[6]                                        -cc)
				+ pip(                  +zpow[6]                                     +z -cc)
				+ pip(                  +zpow[6]                            +zpow[2]    -cc)
				+ pip(                  +zpow[6]                            +zpow[2] +z -cc)
				+ pip(                  +zpow[6]                   +zpow[3]             -cc)
				+ pip(                  +zpow[6]                   +zpow[3]          +z -cc)
				+ pip(                  +zpow[6]                   +zpow[3] +zpow[2]    -cc)
				+ pip(                  +zpow[6]                   +zpow[3] +zpow[2] +z -cc)
				+ pip(                  +zpow[6]          +zpow[4]                      -cc)
				+ pip(                  +zpow[6]          +zpow[4]                   +z -cc)
				+ pip(                  +zpow[6]          +zpow[4]          +zpow[2]    -cc)
				+ pip(                  +zpow[6]          +zpow[4]          +zpow[2] +z -cc)
				+ pip(                  +zpow[6]          +zpow[4] +zpow[3]             -cc)
				+ pip(                  +zpow[6]          +zpow[4] +zpow[3]          +z -cc)
				+ pip(                  +zpow[6]          +zpow[4] +zpow[3] +zpow[2]    -cc)
				+ pip(                  +zpow[6]          +zpow[4] +zpow[3] +zpow[2] +z -cc)
				+ pip(                  +zpow[6] +zpow[5]                               -cc)
				+ pip(                  +zpow[6] +zpow[5]                            +z -cc)
				+ pip(                  +zpow[6] +zpow[5]                   +zpow[2]    -cc)
				+ pip(                  +zpow[6] +zpow[5]                   +zpow[2] +z -cc)
				+ pip(                  +zpow[6] +zpow[5]          +zpow[3]             -cc)
				+ pip(                  +zpow[6] +zpow[5]          +zpow[3]          +z -cc)
				+ pip(                  +zpow[6] +zpow[5]          +zpow[3] +zpow[2]    -cc)
				+ pip(                  +zpow[6] +zpow[5]          +zpow[3] +zpow[2] +z -cc)
				+ pip(                  +zpow[6] +zpow[5] +zpow[4]                      -cc)
				+ pip(                  +zpow[6] +zpow[5] +zpow[4]                   +z -cc)
				+ pip(                  +zpow[6] +zpow[5] +zpow[4]          +zpow[2]    -cc)
				+ pip(                  +zpow[6] +zpow[5] +zpow[4]          +zpow[2] +z -cc)
				+ pip(                  +zpow[6] +zpow[5] +zpow[4] +zpow[3]             -cc)
				+ pip(                  +zpow[6] +zpow[5] +zpow[4] +zpow[3]          +z -cc)
				+ pip(                  +zpow[6] +zpow[5] +zpow[4] +zpow[3] +zpow[2]    -cc)
				+ pip(                  +zpow[6] +zpow[5] +zpow[4] +zpow[3] +zpow[2] +z -cc)
				+ pip(         +zpow[7]                                                 -cc)
				+ pip(         +zpow[7]                                              +z -cc)
				+ pip(         +zpow[7]                                     +zpow[2]    -cc)
				+ pip(         +zpow[7]                                     +zpow[2] +z -cc)
				+ pip(         +zpow[7]                            +zpow[3]             -cc)
				+ pip(         +zpow[7]                            +zpow[3]          +z -cc)
				+ pip(         +zpow[7]                            +zpow[3] +zpow[2]    -cc)
				+ pip(         +zpow[7]                            +zpow[3] +zpow[2] +z -cc)
				+ pip(         +zpow[7]                   +zpow[4]                      -cc)
				+ pip(         +zpow[7]                   +zpow[4]                   +z -cc)
				+ pip(         +zpow[7]                   +zpow[4]          +zpow[2]    -cc)
				+ pip(         +zpow[7]                   +zpow[4]          +zpow[2] +z -cc)
				+ pip(         +zpow[7]                   +zpow[4] +zpow[3]             -cc)
				+ pip(         +zpow[7]                   +zpow[4] +zpow[3]          +z -cc)
				+ pip(         +zpow[7]                   +zpow[4] +zpow[3] +zpow[2]    -cc)
				+ pip(         +zpow[7]                   +zpow[4] +zpow[3] +zpow[2] +z -cc)
				+ pip(         +zpow[7]          +zpow[5]                               -cc)
				+ pip(         +zpow[7]          +zpow[5]                            +z -cc)
				+ pip(         +zpow[7]          +zpow[5]                   +zpow[2]    -cc)
				+ pip(         +zpow[7]          +zpow[5]                   +zpow[2] +z -cc)
				+ pip(         +zpow[7]          +zpow[5]          +zpow[3]             -cc)
				+ pip(         +zpow[7]          +zpow[5]          +zpow[3]          +z -cc)
				+ pip(         +zpow[7]          +zpow[5]          +zpow[3] +zpow[2]    -cc)
				+ pip(         +zpow[7]          +zpow[5]          +zpow[3] +zpow[2] +z -cc)
				+ pip(         +zpow[7]          +zpow[5] +zpow[4]                      -cc)
				+ pip(         +zpow[7]          +zpow[5] +zpow[4]                   +z -cc)
				+ pip(         +zpow[7]          +zpow[5] +zpow[4]          +zpow[2]    -cc)
				+ pip(         +zpow[7]          +zpow[5] +zpow[4]          +zpow[2] +z -cc)
				+ pip(         +zpow[7]          +zpow[5] +zpow[4] +zpow[3]             -cc)
				+ pip(         +zpow[7]          +zpow[5] +zpow[4] +zpow[3]          +z -cc)
				+ pip(         +zpow[7]          +zpow[5] +zpow[4] +zpow[3] +zpow[2]    -cc)
				+ pip(         +zpow[7]          +zpow[5] +zpow[4] +zpow[3] +zpow[2] +z -cc)
				+ pip(         +zpow[7] +zpow[6]                                        -cc)
				+ pip(         +zpow[7] +zpow[6]                                     +z -cc)
				+ pip(         +zpow[7] +zpow[6]                            +zpow[2]    -cc)
				+ pip(         +zpow[7] +zpow[6]                            +zpow[2] +z -cc)
				+ pip(         +zpow[7] +zpow[6]                   +zpow[3]             -cc)
				+ pip(         +zpow[7] +zpow[6]                   +zpow[3]          +z -cc)
				+ pip(         +zpow[7] +zpow[6]                   +zpow[3] +zpow[2]    -cc)
				+ pip(         +zpow[7] +zpow[6]                   +zpow[3] +zpow[2] +z -cc)
				+ pip(         +zpow[7] +zpow[6]          +zpow[4]                      -cc)
				+ pip(         +zpow[7] +zpow[6]          +zpow[4]                   +z -cc)
				+ pip(         +zpow[7] +zpow[6]          +zpow[4]          +zpow[2]    -cc)
				+ pip(         +zpow[7] +zpow[6]          +zpow[4]          +zpow[2] +z -cc)
				+ pip(         +zpow[7] +zpow[6]          +zpow[4] +zpow[3]             -cc)
				+ pip(         +zpow[7] +zpow[6]          +zpow[4] +zpow[3]          +z -cc)
				+ pip(         +zpow[7] +zpow[6]          +zpow[4] +zpow[3] +zpow[2]    -cc)
				+ pip(         +zpow[7] +zpow[6]          +zpow[4] +zpow[3] +zpow[2] +z -cc)
				+ pip(         +zpow[7] +zpow[6] +zpow[5]                               -cc)
				+ pip(         +zpow[7] +zpow[6] +zpow[5]                            +z -cc)
				+ pip(         +zpow[7] +zpow[6] +zpow[5]                   +zpow[2]    -cc)
				+ pip(         +zpow[7] +zpow[6] +zpow[5]                   +zpow[2] +z -cc)
				+ pip(         +zpow[7] +zpow[6] +zpow[5]          +zpow[3]             -cc)
				+ pip(         +zpow[7] +zpow[6] +zpow[5]          +zpow[3]          +z -cc)
				+ pip(         +zpow[7] +zpow[6] +zpow[5]          +zpow[3] +zpow[2]    -cc)
				+ pip(         +zpow[7] +zpow[6] +zpow[5]          +zpow[3] +zpow[2] +z -cc)
				+ pip(         +zpow[7] +zpow[6] +zpow[5] +zpow[4]                      -cc)
				+ pip(         +zpow[7] +zpow[6] +zpow[5] +zpow[4]                   +z -cc)
				+ pip(         +zpow[7] +zpow[6] +zpow[5] +zpow[4]          +zpow[2]    -cc)
				+ pip(         +zpow[7] +zpow[6] +zpow[5] +zpow[4]          +zpow[2] +z -cc)
				+ pip(         +zpow[7] +zpow[6] +zpow[5] +zpow[4] +zpow[3]             -cc)
				+ pip(         +zpow[7] +zpow[6] +zpow[5] +zpow[4] +zpow[3]          +z -cc)
				+ pip(         +zpow[7] +zpow[6] +zpow[5] +zpow[4] +zpow[3] +zpow[2]    -cc)
				+ pip(         +zpow[7] +zpow[6] +zpow[5] +zpow[4] +zpow[3] +zpow[2] +z -cc);
			f += pip(+zpow[8]                                                          -cc)
				+ pip(+zpow[8]                                                       +z -cc)
				+ pip(+zpow[8]                                              +zpow[2]    -cc)
				+ pip(+zpow[8]                                              +zpow[2] +z -cc)
				+ pip(+zpow[8]                                     +zpow[3]             -cc)
				+ pip(+zpow[8]                                     +zpow[3]          +z -cc)
				+ pip(+zpow[8]                                     +zpow[3] +zpow[2]    -cc)
				+ pip(+zpow[8]                                     +zpow[3] +zpow[2] +z -cc)
				+ pip(+zpow[8]                            +zpow[4]                      -cc)
				+ pip(+zpow[8]                            +zpow[4]                   +z -cc)
				+ pip(+zpow[8]                            +zpow[4]          +zpow[2]    -cc)
				+ pip(+zpow[8]                            +zpow[4]          +zpow[2] +z -cc)
				+ pip(+zpow[8]                            +zpow[4] +zpow[3]             -cc)
				+ pip(+zpow[8]                            +zpow[4] +zpow[3]          +z -cc)
				+ pip(+zpow[8]                            +zpow[4] +zpow[3] +zpow[2]    -cc)
				+ pip(+zpow[8]                            +zpow[4] +zpow[3] +zpow[2] +z -cc)
				+ pip(+zpow[8]                   +zpow[5]                               -cc)
				+ pip(+zpow[8]                   +zpow[5]                            +z -cc)
				+ pip(+zpow[8]                   +zpow[5]                   +zpow[2]    -cc)
				+ pip(+zpow[8]                   +zpow[5]                   +zpow[2] +z -cc)
				+ pip(+zpow[8]                   +zpow[5]          +zpow[3]             -cc)
				+ pip(+zpow[8]                   +zpow[5]          +zpow[3]          +z -cc)
				+ pip(+zpow[8]                   +zpow[5]          +zpow[3] +zpow[2]    -cc)
				+ pip(+zpow[8]                   +zpow[5]          +zpow[3] +zpow[2] +z -cc)
				+ pip(+zpow[8]                   +zpow[5] +zpow[4]                      -cc)
				+ pip(+zpow[8]                   +zpow[5] +zpow[4]                   +z -cc)
				+ pip(+zpow[8]                   +zpow[5] +zpow[4]          +zpow[2]    -cc)
				+ pip(+zpow[8]                   +zpow[5] +zpow[4]          +zpow[2] +z -cc)
				+ pip(+zpow[8]                   +zpow[5] +zpow[4] +zpow[3]             -cc)
				+ pip(+zpow[8]                   +zpow[5] +zpow[4] +zpow[3]          +z -cc)
				+ pip(+zpow[8]                   +zpow[5] +zpow[4] +zpow[3] +zpow[2]    -cc)
				+ pip(+zpow[8]                   +zpow[5] +zpow[4] +zpow[3] +zpow[2] +z -cc)
				+ pip(+zpow[8]          +zpow[6]                                        -cc)
				+ pip(+zpow[8]          +zpow[6]                                     +z -cc)
				+ pip(+zpow[8]          +zpow[6]                            +zpow[2]    -cc)
				+ pip(+zpow[8]          +zpow[6]                            +zpow[2] +z -cc)
				+ pip(+zpow[8]          +zpow[6]                   +zpow[3]             -cc)
				+ pip(+zpow[8]          +zpow[6]                   +zpow[3]          +z -cc)
				+ pip(+zpow[8]          +zpow[6]                   +zpow[3] +zpow[2]    -cc)
				+ pip(+zpow[8]          +zpow[6]                   +zpow[3] +zpow[2] +z -cc)
				+ pip(+zpow[8]          +zpow[6]          +zpow[4]                      -cc)
				+ pip(+zpow[8]          +zpow[6]          +zpow[4]                   +z -cc)
				+ pip(+zpow[8]          +zpow[6]          +zpow[4]          +zpow[2]    -cc)
				+ pip(+zpow[8]          +zpow[6]          +zpow[4]          +zpow[2] +z -cc)
				+ pip(+zpow[8]          +zpow[6]          +zpow[4] +zpow[3]             -cc)
				+ pip(+zpow[8]          +zpow[6]          +zpow[4] +zpow[3]          +z -cc)
				+ pip(+zpow[8]          +zpow[6]          +zpow[4] +zpow[3] +zpow[2]    -cc)
				+ pip(+zpow[8]          +zpow[6]          +zpow[4] +zpow[3] +zpow[2] +z -cc)
				+ pip(+zpow[8]          +zpow[6] +zpow[5]                               -cc)
				+ pip(+zpow[8]          +zpow[6] +zpow[5]                            +z -cc)
				+ pip(+zpow[8]          +zpow[6] +zpow[5]                   +zpow[2]    -cc)
				+ pip(+zpow[8]          +zpow[6] +zpow[5]                   +zpow[2] +z -cc)
				+ pip(+zpow[8]          +zpow[6] +zpow[5]          +zpow[3]             -cc)
				+ pip(+zpow[8]          +zpow[6] +zpow[5]          +zpow[3]          +z -cc)
				+ pip(+zpow[8]          +zpow[6] +zpow[5]          +zpow[3] +zpow[2]    -cc)
				+ pip(+zpow[8]          +zpow[6] +zpow[5]          +zpow[3] +zpow[2] +z -cc)
				+ pip(+zpow[8]          +zpow[6] +zpow[5] +zpow[4]                      -cc)
				+ pip(+zpow[8]          +zpow[6] +zpow[5] +zpow[4]                   +z -cc)
				+ pip(+zpow[8]          +zpow[6] +zpow[5] +zpow[4]          +zpow[2]    -cc)
				+ pip(+zpow[8]          +zpow[6] +zpow[5] +zpow[4]          +zpow[2] +z -cc)
				+ pip(+zpow[8]          +zpow[6] +zpow[5] +zpow[4] +zpow[3]             -cc)
				+ pip(+zpow[8]          +zpow[6] +zpow[5] +zpow[4] +zpow[3]          +z -cc)
				+ pip(+zpow[8]          +zpow[6] +zpow[5] +zpow[4] +zpow[3] +zpow[2]    -cc)
				+ pip(+zpow[8]          +zpow[6] +zpow[5] +zpow[4] +zpow[3] +zpow[2] +z -cc)
				+ pip(+zpow[8] +zpow[7]                                                 -cc)
				+ pip(+zpow[8] +zpow[7]                                              +z -cc)
				+ pip(+zpow[8] +zpow[7]                                     +zpow[2]    -cc)
				+ pip(+zpow[8] +zpow[7]                                     +zpow[2] +z -cc)
				+ pip(+zpow[8] +zpow[7]                            +zpow[3]             -cc)
				+ pip(+zpow[8] +zpow[7]                            +zpow[3]          +z -cc)
				+ pip(+zpow[8] +zpow[7]                            +zpow[3] +zpow[2]    -cc)
				+ pip(+zpow[8] +zpow[7]                            +zpow[3] +zpow[2] +z -cc)
				+ pip(+zpow[8] +zpow[7]                   +zpow[4]                      -cc)
				+ pip(+zpow[8] +zpow[7]                   +zpow[4]                   +z -cc)
				+ pip(+zpow[8] +zpow[7]                   +zpow[4]          +zpow[2]    -cc)
				+ pip(+zpow[8] +zpow[7]                   +zpow[4]          +zpow[2] +z -cc)
				+ pip(+zpow[8] +zpow[7]                   +zpow[4] +zpow[3]             -cc)
				+ pip(+zpow[8] +zpow[7]                   +zpow[4] +zpow[3]          +z -cc)
				+ pip(+zpow[8] +zpow[7]                   +zpow[4] +zpow[3] +zpow[2]    -cc)
				+ pip(+zpow[8] +zpow[7]                   +zpow[4] +zpow[3] +zpow[2] +z -cc)
				+ pip(+zpow[8] +zpow[7]          +zpow[5]                               -cc)
				+ pip(+zpow[8] +zpow[7]          +zpow[5]                            +z -cc)
				+ pip(+zpow[8] +zpow[7]          +zpow[5]                   +zpow[2]    -cc)
				+ pip(+zpow[8] +zpow[7]          +zpow[5]                   +zpow[2] +z -cc)
				+ pip(+zpow[8] +zpow[7]          +zpow[5]          +zpow[3]             -cc)
				+ pip(+zpow[8] +zpow[7]          +zpow[5]          +zpow[3]          +z -cc)
				+ pip(+zpow[8] +zpow[7]          +zpow[5]          +zpow[3] +zpow[2]    -cc)
				+ pip(+zpow[8] +zpow[7]          +zpow[5]          +zpow[3] +zpow[2] +z -cc)
				+ pip(+zpow[8] +zpow[7]          +zpow[5] +zpow[4]                      -cc)
				+ pip(+zpow[8] +zpow[7]          +zpow[5] +zpow[4]                   +z -cc)
				+ pip(+zpow[8] +zpow[7]          +zpow[5] +zpow[4]          +zpow[2]    -cc)
				+ pip(+zpow[8] +zpow[7]          +zpow[5] +zpow[4]          +zpow[2] +z -cc)
				+ pip(+zpow[8] +zpow[7]          +zpow[5] +zpow[4] +zpow[3]             -cc)
				+ pip(+zpow[8] +zpow[7]          +zpow[5] +zpow[4] +zpow[3]          +z -cc)
				+ pip(+zpow[8] +zpow[7]          +zpow[5] +zpow[4] +zpow[3] +zpow[2]    -cc)
				+ pip(+zpow[8] +zpow[7]          +zpow[5] +zpow[4] +zpow[3] +zpow[2] +z -cc)
				+ pip(+zpow[8] +zpow[7] +zpow[6]                                        -cc)
				+ pip(+zpow[8] +zpow[7] +zpow[6]                                     +z -cc)
				+ pip(+zpow[8] +zpow[7] +zpow[6]                            +zpow[2]    -cc)
				+ pip(+zpow[8] +zpow[7] +zpow[6]                            +zpow[2] +z -cc)
				+ pip(+zpow[8] +zpow[7] +zpow[6]                   +zpow[3]             -cc)
				+ pip(+zpow[8] +zpow[7] +zpow[6]                   +zpow[3]          +z -cc)
				+ pip(+zpow[8] +zpow[7] +zpow[6]                   +zpow[3] +zpow[2]    -cc)
				+ pip(+zpow[8] +zpow[7] +zpow[6]                   +zpow[3] +zpow[2] +z -cc)
				+ pip(+zpow[8] +zpow[7] +zpow[6]          +zpow[4]                      -cc)
				+ pip(+zpow[8] +zpow[7] +zpow[6]          +zpow[4]                   +z -cc)
				+ pip(+zpow[8] +zpow[7] +zpow[6]          +zpow[4]          +zpow[2]    -cc)
				+ pip(+zpow[8] +zpow[7] +zpow[6]          +zpow[4]          +zpow[2] +z -cc)
				+ pip(+zpow[8] +zpow[7] +zpow[6]          +zpow[4] +zpow[3]             -cc)
				+ pip(+zpow[8] +zpow[7] +zpow[6]          +zpow[4] +zpow[3]          +z -cc)
				+ pip(+zpow[8] +zpow[7] +zpow[6]          +zpow[4] +zpow[3] +zpow[2]    -cc)
				+ pip(+zpow[8] +zpow[7] +zpow[6]          +zpow[4] +zpow[3] +zpow[2] +z -cc)
				+ pip(+zpow[8] +zpow[7] +zpow[6] +zpow[5]                               -cc)
				+ pip(+zpow[8] +zpow[7] +zpow[6] +zpow[5]                            +z -cc)
				+ pip(+zpow[8] +zpow[7] +zpow[6] +zpow[5]                   +zpow[2]    -cc)
				+ pip(+zpow[8] +zpow[7] +zpow[6] +zpow[5]                   +zpow[2] +z -cc)
				+ pip(+zpow[8] +zpow[7] +zpow[6] +zpow[5]          +zpow[3]             -cc)
				+ pip(+zpow[8] +zpow[7] +zpow[6] +zpow[5]          +zpow[3]          +z -cc)
				+ pip(+zpow[8] +zpow[7] +zpow[6] +zpow[5]          +zpow[3] +zpow[2]    -cc)
				+ pip(+zpow[8] +zpow[7] +zpow[6] +zpow[5]          +zpow[3] +zpow[2] +z -cc)
				+ pip(+zpow[8] +zpow[7] +zpow[6] +zpow[5] +zpow[4]                      -cc)
				+ pip(+zpow[8] +zpow[7] +zpow[6] +zpow[5] +zpow[4]                   +z -cc)
				+ pip(+zpow[8] +zpow[7] +zpow[6] +zpow[5] +zpow[4]          +zpow[2]    -cc)
				+ pip(+zpow[8] +zpow[7] +zpow[6] +zpow[5] +zpow[4]          +zpow[2] +z -cc)
				+ pip(+zpow[8] +zpow[7] +zpow[6] +zpow[5] +zpow[4] +zpow[3]             -cc)
				+ pip(+zpow[8] +zpow[7] +zpow[6] +zpow[5] +zpow[4] +zpow[3]          +z -cc)
				+ pip(+zpow[8] +zpow[7] +zpow[6] +zpow[5] +zpow[4] +zpow[3] +zpow[2]    -cc)
				+ pip(+zpow[8] +zpow[7] +zpow[6] +zpow[5] +zpow[4] +zpow[3] +zpow[2] +z -cc);

			#ifdef MULTICOLOR
				gl_FragColor = colors * f;
			#else
				gl_FragColor = mix(teal, orange, mod(_Time.y*0.2/PI, 1.));
				gl_FragColor = gl_FragColor * f;
			#endif
			}

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}