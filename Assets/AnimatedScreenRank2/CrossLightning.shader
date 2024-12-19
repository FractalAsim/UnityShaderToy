Shader "GLSL/ CrossLightning" 
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

			float Hash( vec2 p)
			{
				vec3 p2 = vec3(p.xy,1.);
				return fract(sin(dot(p2,vec3(37.1,61.7, 12.4)))*3758.5453123);
			}

			float noise(in vec2 p)
			{
				vec2 i = floor(p);
				vec2 f = fract(p);
				f *= f * (3.-2.*f);

				return mix(mix(Hash(i + vec2(0.,0.)), Hash(i + vec2(1.,0.)),f.x),
						mix(Hash(i + vec2(0.,1.)), Hash(i + vec2(1.,1.)),f.x),
						f.y);
			}

			float fbm(vec2 p)
			{
				float v = 0.;	
				float n = 3.;
				for(float f = 1.; f<=3.; f++) v += noise(p*f)*(n-f)/(n*n);
				return v;
			}

			void main( void ) 
			{

				vec2 uv = ( gl_FragCoord.xy / resolution.xy ) * 2.0 - 1.0;
				uv.x *= resolution.x/resolution.y;
					
				vec3 finalColor = vec3( 0.0 );
				float i = 1.;
				float hh = .1;
				
				float t = abs(1. / ((uv.y - fbm( uv + (time*3.)/i))*75.));
				finalColor +=  t * vec3( hh+.1, .5, 2. );
				
				float u = abs(1. / ((uv.x - fbm( uv + (time*2.5)/i))*75.));
				finalColor +=  u * vec3( 2., .5, hh+.1 );
				
				float v = abs(1. / ((uv.x + uv.y - fbm( uv + (time*2.)/i))*75.));
				finalColor +=  v * vec3( hh+.1, 2., .5 );
				
				float w = abs(1. / ((uv.x - uv.y - fbm( uv + (time*1.5)/i))*75.));
				finalColor +=  w * vec3( .7, .7, hh+.1 );
				
				float x = abs(1. / ((uv.x*sin(time) - uv.y*cos(time) - fbm( uv + (time*4.)/i))*75.));
				finalColor +=  x * vec3( .5, hh, .5 );
				
				gl_FragColor = vec4( finalColor, 1.0 );

			}

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}