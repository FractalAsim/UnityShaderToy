Shader "GLSL/ TwoSpirals" 
{
	// Two Spirals 2017-11-30 by @hintz
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

			void main()
			{
				vec2 p = (gl_FragCoord.xy-0.5*_ScreenParams)/_ScreenParams.y;
				p = vec2(cos(p.x+0.1*_Time.y),p.y); 
				float y0 = p.y + 0.2*sin(4.0*p.x+_Time.y-1.0+0.5*cos(_Time.y));
				float y1 = p.y + 0.2*cos(4.0*p.x+_Time.y+1.0+0.5*sin(_Time.y));
				y0 *= y0;
				y1 *= y1;
				y0 = sqrt(1.0 - y0 * 100.0);
				y1 = sqrt(1.0 - y1 * 100.0);
				float y2 = cos(4.0*p.x+_Time.y-1.0+0.5*cos(_Time.y));
				float y3 = -sin(4.0*p.x+_Time.y+1.0+0.5*sin(_Time.y));
				float y = max(y0+y2,y1+y3);
				float c = y;
				vec3 color = c*normalize(vec3(c,p.x+c,c+p.y));
				gl_FragColor = vec4(color.zxy,1.0);
  			}	

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}