Shader "GLSL/ DoubleSpiral1" 
{
	// Double Spiral 2017-11-28 modified by @hintz
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

			#ifdef VERTEX // Begin vertex program/shader

			void main()
			{
				gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex; // Draws the Vertex at the correct position in world
			}

			#endif // Ends vertex program/shader

			#ifdef FRAGMENT // Begin fragment program/shader

			#define pi 3.141592653589793238462643383279
			#define pi_inv 0.318309886183790671537767526745
			#define pi2_inv 0.159154943091895335768883763372

			vec2 complex_div(vec2 numerator, vec2 denominator)
			{
				return vec2(numerator.x*denominator.x + numerator.y*denominator.y, numerator.y*denominator.x - numerator.x*denominator.y)/ vec2(denominator.x*denominator.x + denominator.y*denominator.y);
			}

			float sigmoid(float x) 
			{
				return sin(x*.01)*exp(-x*x);
			}

			float smoothcircle(vec2 uv, vec2 center, vec2 aspect, float radius, float sharpness)
			{
				return sigmoid((length((uv - center) * aspect) - radius) * sharpness);
			}


			vec2 spiralzoom(vec2 domain, vec2 center, float n, float spiral_factor, float zoom_factor, vec2 pos)
			{
				vec2 uv = domain - center;
				float angle = atan(uv.y, uv.x);
				float d = length(uv);
				
				return vec2(angle*n*pi2_inv + log(d)*spiral_factor, -log(d)*zoom_factor) + pos;
			}

			vec2 mobius(vec2 domain, vec2 zero_pos, vec2 asymptote_pos)
			{
				return complex_div(domain - zero_pos, domain - asymptote_pos);
			}

			float gear(vec2 domain, float phase, vec2 pos)
			{
				float angle = atan(domain.y - pos.y, domain.x - pos.x);
				float d = 0.2 + sin((angle + phase) * 2.)*0.08;
				
				return smoothcircle(domain, pos, vec2(1), d, 40.);
			}

			float geartile(vec2 domain, float phase)
			{
				domain = fract(domain);

				return 
					gear(domain, -phase, vec2(-0.25,0.25)) + 
					gear(domain, phase, vec2(-0.25,0.75)) + 
					gear(domain, phase, vec2(1.25,0.25)) + 
					gear(domain, -phase, vec2(1.25,0.75)) + 
					gear(domain, -phase, vec2(0.25,-0.25)) + 
					gear(domain, phase, vec2(0.75,-0.25)) + 
					gear(domain, phase, vec2(0.25,1.25)) + 
					gear(domain, -phase, vec2(0.75,1.25)) + 
					gear(domain, phase, vec2(0.25,0.25)) + 
					gear(domain, -phase, vec2(0.25,0.75)) + 
					gear(domain, -phase, vec2(0.75,0.25)) + 
					gear(domain, phase, vec2(0.75,0.75));		
			}

			void main(void)
			{
				vec2 uv = (gl_FragCoord.xy - .5*_ScreenParams) / _ScreenParams.x;
					
				float phase = (_Time.y+10.)*0.5;
				float dist = 0.5;
				vec2 uv_bipolar = mobius(uv, vec2(-dist*0.5, 0.), vec2(dist*0.5, 0.));
				uv_bipolar = spiralzoom(uv_bipolar, vec2(0.0), 5., -0.125*pi, 0.8, vec2(0.125,0.125)*phase*5.);
				vec2 uv2 = vec2(-uv_bipolar.y,uv_bipolar.x); // 90° rotation 
				
				vec2 uv_spiral = spiralzoom(uv, vec2(0.5), 5., -0.125*pi, 0.8, vec2(-0.,0.25)*phase);
				vec2 uv_tilt = uv_spiral;
				float z = 1./(1.-uv_tilt.y)/(uv_tilt.y);
				uv_tilt = 0.5 + (uv_tilt - 0.5) * log(z);
				
				float grid = geartile(uv_bipolar, -phase);

				gl_FragColor = vec4(1,1,1,1.0);
				
				gl_FragColor = 1.* mix(vec4(0,0,0,0), gl_FragColor, sin((uv2.y+uv_bipolar.y) * pi * 10.0));
				gl_FragColor += 5.*vec4(0.6*abs(uv_bipolar.x-uv2.y),0.8,1.0+((uv_bipolar.y-uv2.x) * pi * 5.0),1.0)* -grid*500.0;
				gl_FragColor.a = 1.0;
			}

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}