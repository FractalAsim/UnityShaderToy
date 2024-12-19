Shader "GLSL/ Nebula1" 
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

			
			void main()
			{
				//vec3 light_color = vec3(1.2,0.8,0.6);
				vec3 light_color = vec3(2,2,2);
				
				float t = time*-5.0;
				vec2 position = ( gl_FragCoord.xy -  resolution.xy*.5 ) / resolution.x;

				// 256 angle steps
				float angle = atan(position.y,position.x)/(1.5*3.14159265359);
				angle -= floor(angle);
				float rad = length(position);
				
				float color = 0.0;

				float angleFract = fract(angle*256.);
				float angleRnd = floor(angle*256.)+100.;
				float angleRnd1 = fract(angleRnd*fract(angleRnd*.7235)*45.1);
				float angleRnd2 = fract(angleRnd*fract(angleRnd*.82657)*13.724);
				float t2 = t+angleRnd1*100000.;
				float radDist = sqrt(angleRnd2);
				
				float adist = radDist/rad*.063;
				float dist = (t2*.1+adist);
				dist = abs(fract(dist)-1.0);
				color +=  (1.0 / (dist))*cos(0.7*(sin(t)))*adist/radDist/30.0;

				angle = fract(angle+.61);
				
				gl_FragColor = vec4(color,color,color,1.0)*vec4(light_color,1.0);
			}

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}