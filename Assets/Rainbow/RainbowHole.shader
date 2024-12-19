Shader "GLSL/ RainbowHole" 
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

			vec2 hexify(vec2 p,float hexCount){
				p*=hexCount;
				vec3 p2=floor(vec3(p.x/0.86602540378,p.y+0.57735026919*p.x,p.y-0.57735026919*p.x));
				float y=floor((p2.y+p2.z)/3.0);
				float x=floor((p2.x+(1.0-mod(y,2.0)))/2.0);
				return vec2(x,y)/hexCount;
			}

			void main( void ) {
				
				vec2 p = gl_FragCoord.xy / _ScreenParams.xy -0.5;
				p /= dot(p,p);
				
				p=hexify(p,2.0 );
				
				
				float vr = 0.5*sin(40.* ( p.y+p.x*0.2)+time*2.)+0.5 ;
				
				float vg = 0.5*sin(30.* ( p.y+p.x*0.3)+time*3.)+0.5 ;
				
				float vb = 0.5*sin(20.* ( p.y+p.x*0.4)+time*4.)+0.5 ;
					
				gl_FragColor = vec4(vr,vg,vb,1);
			}

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}