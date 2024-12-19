Shader "GLSL/ RainbowPaintMix" 
{
	// Created by Robert Schuetze - trirop/2017
	// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
	// Original from https://www.shadertoy.com/view/MsScWD
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

			vec2 v(vec2 p,float s)
			{
				vec2 pos = gl_FragCoord.xy/_ScreenParams.xy;
				return vec2(sin(s*p.y+_Time.y*0.263423+pos.y*1.1423),cos(s*p.x-_Time.y*0.32364263+pos.x*1.4235));	//advection vector field
			}
			vec2 RK4(vec2 p,float s, float h)
			{
				vec2 k1 = v(p,s);
				vec2 k2 = v(p+0.5*h*k1,s);
				vec2 k3 = v(p+0.5*h*k2,s);
				vec2 k4 = v(p+h*k3,s);
				return h/3.*(0.5*k1+k2+k3+0.5*k4);
			}

			vec3 rainbow(float hue)
			{
				return abs(mod(hue * 6.0 + vec3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0;
			}

			void main()
			{
				vec2 uv = 2.*gl_FragCoord.xy/_ScreenParams.y-vec2(_ScreenParams.x/_ScreenParams.y,1);
				float s = 2.;
				float h = 1.0;
				for(int i = 0; i<30; i++) 
				{
					float hh = h * log(1./(exp(2.*sin(_Time.y*0.18345 + float(i) * 0.1))))/5.;
					uv+=RK4(uv,s,hh);
					float factor = 1.2;
					s*=factor;
					h/=factor;
				}
				gl_FragColor = vec4(rainbow(_Time.y*0.1 + floor(length(uv)*10.)/10.),1); //centered rainbow with 10 visible rings
			}

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}