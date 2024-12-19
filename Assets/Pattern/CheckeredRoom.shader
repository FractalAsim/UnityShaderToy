Shader "GLSL/ Template" 
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

			void main( void ) 
			{
				vec2 pos = ( gl_FragCoord.xy / resolution.xy ) - vec2(0.5,0.5);	
				float horizon = 0.0; 
				float fov = 0.5; 
				float scaling = 0.1;
				
				vec3 p = vec3(pos.x, fov, pos.y - horizon);      
				vec2 s = vec2(p.x/p.z, p.y/p.z) * scaling;
				
				//checkboard texture
				float color = sign((mod(s.x, 0.1) - 0.05) * (mod(abs(s.y)+time*0.03, 0.1) - 0.05));	
				//fading
				color *= p.z*p.z*10.0;
				
				gl_FragColor = vec4( vec3(color), 1.0 );
			}

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}