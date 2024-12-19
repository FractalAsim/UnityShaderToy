Shader "GLSL/ BlueGrid" 
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
				vec2 position = ( gl_FragCoord.xy / resolution.xy );
	 
				float div = 2.*-1.+ 40.+40.0*mouse.x,
				
				color = 0.0,
				
				mx = mod(gl_FragCoord.x+(time*100.), div+2.0),// just x 
				my = mod(gl_FragCoord.y, div+2.0); 
				
				//  my = mod(gl_FragCoord.y-gl_FragCoord.x, div+2.0); 
			
				color = mx < div && my<div ? 0.0 : 1.0; // annunaki code ! gtr
				
				

				gl_FragColor = vec4(  color*sin(time), color*0.6, color*0.8, 1.0 );
			}

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}