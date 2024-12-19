Shader "GLSL/ RaisingSun" 
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

			mat3 rotationMatrix(vec3 axis, float angle)
			{
				axis = normalize(axis);
				float s = sin(angle);
				float c = cos(angle);
				float oc = 1.0 - c;

				return mat3(oc * axis.x * axis.x + c, oc * axis.x * axis.y - axis.z * s, oc * axis.z * axis.x + axis.y * s,
					oc * axis.x * axis.y + axis.z * s, oc * axis.y * axis.y + c, oc * axis.y * axis.z - axis.x * s,
					oc * axis.z * axis.x - axis.y * s, oc * axis.y * axis.z + axis.x * s, oc * axis.z * axis.z + c);
			}

			float rand2s(vec2 co){
				return fract(sin(dot(co.xy,vec2(12.9898,78.233))) * 43758.5453);
			}

			//afl_ext 2017
			vec3 extra_cheap_atmosphere(float raylen, float sunraylen, float sunraydot){
				//sundir.y = max(sundir.y, -0.07);
				float special_trick = raylen;
				float special_trick2 = sunraylen;
				float raysundt = pow(abs(sunraydot), 2.0);
				float sundt = pow(max(0.0, sunraydot), 8.0);
				float mymie = sundt * special_trick * 0.2;
				vec3 suncolor = mix(vec3(1.0), max(vec3(0.0), vec3(1.0) - vec3(5.5, 13.0, 22.4) / 22.4), special_trick2);
				vec3 bluesky= vec3(5.5, 13.0, 22.4) / 22.4 * suncolor;
				vec3 bluesky2 = max(vec3(0.0), bluesky - vec3(5.5, 13.0, 22.4) * 0.004 * (special_trick));
				bluesky2 *= special_trick * (0.24 + raysundt * 0.24);
				return bluesky2 + mymie * suncolor;
			}
			void main( void ) {

				vec2 position = ( gl_FragCoord.xy / resolution.xy );
				mat3 roty = rotationMatrix(vec3(0.0, 1.0, 0.0), -position.x * 3.1415 * 2.0);
				mat3 rotx = rotationMatrix(vec3(1.0, 0.0, 0.0), (position.y * 2.0 - 1.0) * 3.1415 * 0.5);
				vec3 ray = roty * rotx * normalize(vec3(0.0, 0.0, 1.0));
				vec3 sd = normalize(mix(vec3(1.0, -0.07, 0.0), vec3(0.0, 1.0, 0.0), mouse.y));
				
				vec3 atm = extra_cheap_atmosphere(1.0 / (0.1 + ray.y), 1.0 / (3.1 + sd.y), dot(sd, ray));
				//atm = normalize(atm) * sqrt(length(atm)); // tonemap if you want
				atm += smoothstep(0.998, 0.999, dot(ray, sd));
				
				gl_FragColor =  vec4(atm , 1.0 );

			}

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}