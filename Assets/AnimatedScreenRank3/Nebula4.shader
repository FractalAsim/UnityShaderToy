Shader "GLSL/ Nebula4" 
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

			#define PI 3.14159265359


			float random(float n) 
			{
				return fract(abs(sin(n * 55.753) * 367.34));
			}

			mat2 rotate2d(float angle)
			{
				return mat2(cos(angle), -sin(angle),  sin(angle), cos(angle));
			}

			void main( void ) 
			{
				vec2 uv = (gl_FragCoord.xy * 2.0 -  resolution.xy) / resolution.x;

				uv *= rotate2d(time * 1.2); //time * 0.2

				float direction = -2.0;
				float speed = time * direction * .5;
				float distanceFromCenter = length(uv);

				float meteorAngle = atan(uv.y, uv.x) * (180.0 / PI);

				float flooredAngle = floor(meteorAngle);
				float randomAngle = pow(random(flooredAngle), 0.7);
				float t = speed + randomAngle;

				float lightsCountOffset = 0.4;
				float adist = randomAngle / distanceFromCenter * lightsCountOffset;
				float dist = t + adist;
				float meteorDirection = (direction < 0.0) ? -1.0 : 0.0;
				dist = abs(fract(dist) + meteorDirection);

				float lightLength = 100.0;
				float meteor = (6.0 / dist) * cos(sin(speed)) / lightLength;
				meteor *= distanceFromCenter * 4.0;

				vec3 color = vec3(0.);
				color.gb += meteor;

				gl_FragColor = vec4(color, 1.0);
			}

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}