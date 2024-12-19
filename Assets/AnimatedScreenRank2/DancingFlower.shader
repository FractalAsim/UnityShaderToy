Shader "GLSL/ DancingFlower" 
{
	// Dancing Flower 2017-11-30 by @hintz
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
				float n = 2.5;
				vec2 p = 2.0*(gl_FragCoord.xy-0.5*_ScreenParams)/_ScreenParams.y;
				p = vec2(7.0*atan(p.y,p.x),0.4*cos((9.0+6.0*sin(_Time.y)+2.0*sin(0.88*_Time.y))*length(p)));
				vec2 p2 = vec2(n*cos(p.x+0.1*_Time.y),p.y); 
				float y0 = p.y + 0.31*sin(p.x+_Time.y+10.5*cos(_Time.y));
				float y1 = p.y + 0.3*cos(p.x+_Time.y+12.5*sin(_Time.y));
				y0 *= y0;
				y1 *= y1;
				y0 = sqrt(1.0 - y0 * 60.0 * (sin(8.0*p.x+1.4*_Time.y) + 1.4));
				y1 = sqrt(1.0 - y1 * 60.0 * (sin(6.0*p.x-1.5*_Time.y) + 1.5));
				float y2 =  cos(p.x+_Time.y-1.0+0.5*cos(_Time.y));
				float y3 = -sin(p.x+_Time.y+1.0+0.5*sin(_Time.y));
				float y = max(y0+y2,y1+y3);
				float c = y;
				vec3 color = 0.001*pow(c*c*0.4,10.0)+c*normalize(vec3(c,c+p2.x,-c+p2.x));
				gl_FragColor = vec4(color.yxz,1.0);
			}
			// void main(void) v2
			// {	
			// 	float n = 2.5;
			// 	vec2 p = 2.2*(gl_FragCoord.xy-0.5*resolution)/resolution.y;
			// 	p = vec2(3.0*atan(p.y,p.x),0.08+0.4*cos(5.0*length(p)));
			// 	vec2 p2 = vec2(n*cos(p.x+0.1*time),p.y); 
			// 	float y0 = p.y + 0.2*sin(p.x+time-1.0+0.5*cos(time));
			// 	float y1 = p.y + 0.2*cos(p.x+time+1.0+0.5*sin(time));
			// 	y0 *= y0;
			// 	y1 *= y1;
			// 	y0 = sqrt(1.0 - y0 * 100.0 * (sin(6.0*p.x+1.4*time) + 1.4));
			// 	y1 = sqrt(1.0 - y1 * 100.0 * (sin(6.0*p.x-1.5*time) + 1.5));
			// 	float y2 = cos(p.x+time-1.0+0.5*cos(time));
			// 	float y3 = -sin(p.x+time+1.0+0.5*sin(time));
			// 	float y = max(y0+y2,y1+y3);
			// 	float c = y;
			// 	vec3 color = 0.002*pow(c,10.0)+c*normalize(vec3(c,c+p2.x,-c+p2.x));
			// 	gl_FragColor = vec4(color.yxz,1.0);
			// }

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}