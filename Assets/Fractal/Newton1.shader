Shader "GLSL/ Newton1" 
{
	// Newtow Fractal 1-z^3 with abs() by @hintz
	// v2 HSV2RGB changed
	// What about to go 3d like http://www.josleys.com/show_gallery.php?galid=338 ?
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

			float deltax = 12.0 + sin(_Time.y*0.4) * 10.0;
			float deltay = _ScreenParams.y / _ScreenParams.x * deltax;

			float theta = _Time.y*0.1;
			float cosThetaPi = cos(theta);
			float sinThetaPi = sin(theta);

			// for pretty colors: Hue-Saturation-Value to Red-Green-Blue
			vec4 HSV2RGB(vec3 hsv) 
			{ vec3 rgb = ((clamp(abs(fract(hsv.x +vec3(0.,2./3.,1./3.))*2.-1.)*3.-1.,0.,1.)-1.)*hsv.y+1.)*hsv.z;
			return vec4 (rgb,1.0);
			}

			// complex number multiplication: a * b
			vec2 mul(vec2 a, vec2 b)
			{
			return vec2(a.x*b.x - a.y*b.y, 
					a.y*b.x + a.x*b.y);
			}

			// complex number division: a / b 
			vec2 div(vec2 a, vec2 b)
			{
			return vec2((a.x*b.x + a.y*b.y) / (b.x*b.x + b.y*b.y), 
					(a.y*b.x - a.x*b.y) / (b.x*b.x + b.y*b.y));
			}

			vec2 znext(vec2 z)       //     1 - z^3
			{                        // z - -------
			vec2 z2 = mul(z,z);    //     3 * z^2
			return z - div(vec2(1.0,0.0)+mul(z2,z), 3.0*z2);
			}

			vec2 newtonfractal(vec2 z)
			{
			for (int n=0; n<100; n++)
			{
				vec2 old = z;
				z = znext(z);
				vec2 d = z - old;
				d *= 22.*d;
				d = abs(d);
				if (d.x+d.y < 0.01)
				return vec2(z.x +z.y +_Time.y*0.1, float(n)*0.06);
			}
			return z;
			}


			void main()
			{
				float real = deltax * (gl_FragCoord.x / _ScreenParams.x - 0.5);
				float imag = deltay * (gl_FragCoord.y / _ScreenParams.y - 0.5);
				
				float realR = real*cosThetaPi - imag*sinThetaPi;
				float imagR = real*sinThetaPi + imag*cosThetaPi;
					
				vec2 results = newtonfractal(vec2(realR, imagR));

				float h = results.x;
				float v = 1.0-results.y;
				float s = 0.8;

				gl_FragColor = HSV2RGB(vec3(h, s, v));
			}

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}