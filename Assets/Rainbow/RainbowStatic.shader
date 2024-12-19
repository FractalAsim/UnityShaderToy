Shader "GLSL/ RainbowStatic" 
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

			float rand(vec2 co){
			return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
			}

			vec3 rand3(vec2 co){
				return vec3(rand(co),rand(co+vec2(213,2151)),rand(co+vec2(123124,2323)));
			}

			vec2 hexify(vec2 p,float hexCount){
				p*=hexCount;
				vec3 p2=floor(vec3(p.x/0.86602540378,p.y+0.57735026919*p.x,p.y-0.57735026919*p.x));
				float y=floor((p2.y+p2.z)/3.0);
				float x=floor((p2.x+(1.0-mod(y,2.0)))/2.0);
				return vec2(x,y)/hexCount;
			}

			vec2 cMul(vec2 a,vec2 b){
				return vec2(a.x*b.x-a.y*b.y,a.x*b.y+a.y*b.x);
			}

			void main( void ) {
				vec2 p=gl_FragCoord.xy/resolution.xy;
				p.x*=resolution.x/resolution.y;
				p=hexify(p,20.0);
				gl_FragColor = vec4(rand3(p),1);
			}

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}