Shader "GLSL/ RainbowRadicalWave" 
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

			const float pi=3.14159265359;

			vec2 tile_num = vec2(80.0,40.0);

			void main( void ) {
				vec2 p  = gl_FragCoord.xy/resolution.xy;
					// p.x *= resolution.x/resolution.y;
				
				vec2  p2 = floor(p*tile_num)/tile_num;
					
				p -= p2;
				
					p *= tile_num;

				p2 += vec2(step(p.y,p.x)/(2.0*tile_num.x),step(p.x,p.y)/(2.0*tile_num.y));
				
				float vr = 0.5*sin(40.* ( p2.y+p2.x*0.0)+time*2.)+0.5 ;
				
				float vg = 0.5*sin(30.* ( p2.y+p2.x*0.0)+time*3.)+0.5 ;
				
				float vb = 0.5*sin(20.* ( p2.y+p2.x*0.0)+time*4.)+0.5 ;
					
				gl_FragColor = vec4(vr,vg,vb,1);
			}

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}