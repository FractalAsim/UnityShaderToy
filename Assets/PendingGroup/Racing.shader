Shader "GLSL/ Racing" 
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

			float circle(vec2 fc, vec3 pr)
{
	return step(distance(fc, pr.xy), pr.z);
}

float rectangle(vec2 fc, vec4 ltrb)
{
	ltrb.z += ltrb.x;
	ltrb.w += ltrb.y;
	return step(ltrb.x, fc.x) * step(fc.x, ltrb.z) * step(ltrb.y, fc.y) * step(fc.y, ltrb.w);
}

void main()
{
	vec2 fragCoord = gl_FragCoord.xy / resolution;
	vec2 coord = fragCoord * 2.0 - 1.0;
	
	float moon = circle(coord, vec3(cos(time * 0.5) * 0.9, sin(time * 0.5) * 0.5, 0.1)) * coord.y;
	
	coord.x += cos(time) * tan(1.0 + coord.y);
	coord = abs(coord);
	
	float road = mod(coord.y - time * 0.8, 0.1) * 0.5;
	
	vec3 ground = vec3(0.0, floor(coord.x / coord.y * 1.2) * 0.2 + road, 0.1);
	
	vec2 mouseCorrected = (mouse - 0.5) * 0.5;
	
	vec3 car = vec3(0.0);
	car += rectangle(fragCoord, vec4(mouseCorrected.x + 0.45, 0.12, 0.10, 0.08)) * vec3(1.0, 1.0, 1.0);
	car -= rectangle(fragCoord, vec4(mouseCorrected.x + 0.452, 0.13, 0.013, 0.06)) * vec3(0.0, 1.0, 1.0);
	car -= rectangle(fragCoord, vec4(mouseCorrected.x + 0.535, 0.13, 0.013, 0.06)) * vec3(0.0, 1.0, 1.0);
	car += rectangle(fragCoord, vec4(mouseCorrected.x + 0.45, 0.20, 0.10, 0.05)) * vec3(0.1, 0.2, 0.3);
	car -= rectangle(fragCoord, vec4(mouseCorrected.x + 0.525, 0.07, 0.020, 0.05)) * vec3(1.0, 1.0, 1.0);
	car -= rectangle(fragCoord, vec4(mouseCorrected.x + 0.455, 0.07, 0.020, 0.05)) * vec3(1.0, 1.0, 1.0);
	car -= circle(fragCoord, vec3(mouseCorrected.x + 0.5, 0.215, 0.015)) * vec3(0.0, 0.2, 1.0);
	
	gl_FragColor = vec4((step(fragCoord.y, 0.5) * (ground + car)) + (step(0.5, fragCoord.y) * moon), 1.0);
}

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}