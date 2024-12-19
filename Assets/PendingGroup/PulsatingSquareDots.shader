Shader "GLSL/ PulsatingSquareDots" 
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

			float hex(vec2 p) 
			{
				p.x *= 0.57735*2.0;
				p.y += mod(floor(p.x), 2.0)*0.5;
				p = abs((fract(p) - 0.5));
				float par = 0.5;
				return abs(max(p.x*1.5 + p.y + par, p.y*2.0 + par) - 1.0);
			}

			float sqr(vec2 p) 
			{
				float s = 1.0;
				float a = mod(p.x, s);
				float b = mod(p.y, s);
				return (a<0.3 || b<0.3) ? 1.0 : 0.0;
			}

			float Koef(vec2 offset) 
			{
				float t = time*2.0;
				vec2 p = 50. * offset / resolution.x;
				float s = sin(dot(p, p) / -128. + t * 2.);
				s = pow(abs(s), 2.5) * sign(s);
				float  r = .15 + .3 * s;
				return smoothstep(r - 0.1, r + 0.1, sqr(p + p * r + 0.5));
			}

			void main( void ) {

				vec2 pos = gl_FragCoord.xy - resolution / 2.;
				//vec2 mouseKoef = (mouse -.5);
				vec2 epsi = pos / 128.;
				epsi = epsi*0.5;
				gl_FragColor = vec4(Koef(pos - epsi), Koef(pos), Koef(pos + epsi), 1.0);
			}

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}