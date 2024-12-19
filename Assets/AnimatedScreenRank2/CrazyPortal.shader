Shader "GLSL/ CrazyPortal" 
{
	// Crazy Portal
	// By: Brandon Fogerty
	// bfogerty at gmail dot com
	// xdpixel.com
	// taken from xdpixel.com, credit to Brandon Fogerty for making this.
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

			//uniform vec2 mouse;
			uniform vec2 _ScreenParams; 
			uniform vec4 _Time; // (t/20, t, t*2, t*3)
			//uniform  vec4 unity_DeltaTime //  (dt, 1/dt, smoothDt, 1/smoothDt).
			//uniform  vec4 _SinTime // (t/8, t/4, t/2, t).
			//uniform  vec4 _CosTime // (t/8, t/4, t/2, t).

			#ifdef VERTEX // Begin vertex program/shader

			void main()
			{
				gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex; // Draws the Vertex at the correct position in world
			}

			#endif // Ends vertex program/shader

			#ifdef FRAGMENT // Begin fragment program/shader

			// I didn't write this random function but I don't know who did... so thanks to whoever wrote this!
			vec2 random2f(vec2 p) 
			{
				p = mod( p, 4.0 );
				
				vec2 tmp = fract(vec2(sin(p.x * 591.32 + p.y * 154.077), cos(p.x * 391.32 + p.y * 49.077)));
				
				return vec2(.5+.5*sin(tmp.x*_Time.y+ p.y),.5+.5*cos(tmp.y*_Time.y + p.x));
			}

			float voronoi( vec2 uv )
			{
				
				uv.x = mod(uv.x,4.0);
				
				vec2 p = floor( uv );
				vec2 f = fract( uv );
				
				float res = 8.0;
				const float i = 1.0;
				
				for( float y = -i; y <= i; ++y )
				{
					for( float x = -i; x <= i; ++x )
					{
						vec2 b = vec2( x, y );
						vec2 r = b - f + random2f( p + b );
						float d = length( r );
						
						res = min( res, d );
					}
				}
				
				return res;
			}

			void main()
			{
				vec2 uv = ( gl_FragCoord.xy / _ScreenParams.xy ) * 2.0 - 1.0;
				uv.x *= _ScreenParams.x / _ScreenParams.y;

				vec2 originalUV = uv;
				
				float a = 2.0 * atan( uv.x, uv.y );
				a *= (3.0 / 3.141596);
				
				float r = length( uv ) * 0.5;
				
				float t = sin( _Time.y * 0.2 ) * 0.5 + 0.5;
				
				float z = mix( 2.5, 3.5, t );
				uv = vec2( r * z, a );
				
				vec3 finalColor = vec3(0.0);
				finalColor += vec3( voronoi(uv * 4.0), voronoi(uv * 3.0), voronoi(uv * 7.0) );
				finalColor -= length(originalUV) * 0.3;
				finalColor *= 1.0-length(originalUV);
				
				gl_FragColor = vec4( finalColor, 1.0 );
			}

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}