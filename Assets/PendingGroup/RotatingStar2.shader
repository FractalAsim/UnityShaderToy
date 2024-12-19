Shader "GLSL/ RotatingStar2" 
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

			#define PI 3.141519

			float rmax = 0.8;
			float rmin = 0.01;
			float points = 5.0;

			void main( void ) {
				
				vec2 st = (gl_FragCoord.xy *2.0 - resolution.xy)  / resolution.y;
				
				gl_FragColor = vec4(0);
				for(float i = 0.; i <= 1.; i += 1./2.){
					float angle = atan(st.y, st.x) + time;
					float r = length(st);
				
					float pointangle = PI * 2.0 / points;
					
					float a = mod(angle, pointangle) / pointangle;
					a = a < 0.5 ? a : 1.0 - a;
					
					
					vec2 p0 = rmax * vec2(cos(0.0), sin(0.0));
					vec2 p1 = rmin * vec2(cos(pointangle / 2.0), sin(pointangle / 2.0));
					vec2 d0 = p1 - p0;
					vec2 d1 = r * vec2(cos(a), sin(a)) - p0;
					
					float isin = step(0.0, cross(vec3(d0, 0.0), vec3(d1, 0.0)).z);
					
					gl_FragColor = max(gl_FragColor, vec4(vec3(isin), 1.0));
					
					st += -d1*0.5;
					
				}
			}

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}