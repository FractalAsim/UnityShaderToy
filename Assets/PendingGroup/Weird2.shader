Shader "GLSL/ Weird2" 
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

			vec2 rot(vec2 p, float a) {
	float c = cos(a);
	float s = sin(a);
	
	return mat2(c, s, -s, c)*p;
}

float field(in vec3 p) {
	float accum = 0.;
	float prev = 0.;
	float tw = 0.;
	for (int i = 0; i < 40; ++i) {
		float mag = dot(p, p);
		p = abs(p) / mag + vec3(-0.1, -.5, -1.5);
		
		p.xy = rot(p.xy, 0.4*time);
		float w = exp(-float(i) / 20.);
		accum += w * exp(-(20.0 - 2.0*sin(1.0*p.x*p.y + time))*pow(abs(mag - prev), 2.9));
		tw += w;  
		prev = mag*0.7;
	}
	
	return max(0., 3.8 * accum / tw - 0.2);
}

void main() {
	vec2 suv = (-resolution + 2.0*gl_FragCoord.xy)/resolution.y;
	
	
	float t = field(vec3(suv, 1.0));
	vec3 col = vec3(0.8 * t * t * t, 1.4 * t * t, t);
	col = pow(abs(col), vec3(1.0/2.2));
	
	gl_FragColor = vec4(col, 1);
}

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}