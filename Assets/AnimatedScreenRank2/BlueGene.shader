Shader "GLSL/ BlueGene" 
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

			float field(in vec3 p) 
			{
				float strength = 7. + .03 * log(1.e-6 + fract(sin(time) * 4373.11));
				float accum = 0.;
				float prev = 0.;
				float tw = 0.;
				for (int i = 0; i < 32; ++i) 
				{
					float mag = dot(p, p);
					p = abs(p) / mag + vec3(-.5, -.4, -1.5);
					float w = exp(-float(i) / 7.);
					accum += w * exp(-strength * pow(abs(mag - prev), 2.3));
					tw += w;  prev = mag;
				}
				return max(0., 5. * accum / tw - .7);
			}

			void main() 
			{
				vec2 uv = 2. * gl_FragCoord.xy / resolution.xy - 1.;
				vec2 uvs = uv * resolution.xy / max(resolution.x, resolution.y);
				vec3 p = vec3(uvs / 4., 0) + vec3(1., -1.3, 0.);
				p += .2 * vec3(sin(time / 16.), sin(time / 12.), sin(time / 128.));
				float t = field(p);
				float v = (1. - exp((abs(uv.x) - 1.) * 6.)) * (1. - exp((abs(uv.y) - 1.) * 6.));
				gl_FragColor = mix(.4, 1., v) * vec4(0.8 * t * t * t, 1.4 * t * t, t, 1.0);
			}

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}