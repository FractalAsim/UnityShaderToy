Shader "GLSL/ NaziFlag" 
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

			const float cross_width = 0.07;
			
			vec2 rotate(vec2 p, float ang)
			{
				float c = cos(ang), s = sin(ang);
				return vec2(p.y * c - p.x * s, p.y * s + p.x * c);
			}

			void main( void ) 
			{

				vec2 p = 1.0*( gl_FragCoord.xy / _ScreenParams.xy )-0.5;
			//	p=rotate(p,time);
				p*=(20.0+80.0*mouse.x);
				p*=sin(p.x)+cos(p.y);
				vec2 pp=vec2(p.x,p.y);
				pp=rotate(pp,_Time.y*2.0);
				
				vec3 cc=vec3(sin(pp.x),cos(pp.y),pp.x+pp.y);
				
				gl_FragColor = vec4( cc, 1.0 );

			}

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}