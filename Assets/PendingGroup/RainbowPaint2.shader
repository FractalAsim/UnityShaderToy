﻿Shader "GLSL/ Template" 
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

			const int   complexity      = 40;    // More points of color.
			const float mouse_factor    = 25.0;  // Makes it more/less jumpy.
			const float mouse_offset    = 5.0;   // Drives complexity in the amount of curls/cuves.  Zero is a single whirlpool.
			const float fluid_speed     = 45.0;  // Drives speed, higher number will make it slower.
			const float color_intensity = 0.7;

			const float Pi = 3.14159;

			float sinApprox(float x) {
				x = Pi + (2.0 * Pi) * floor(x / (2.0 * Pi)) - x;
				return (4.0 / Pi) * x - (4.0 / Pi / Pi) * x * abs(x);
			}

			float cosApprox(float x) {
				return sinApprox(x + 0.5 * Pi);
			}

			void main()
			{
			vec2 p=(2.0*gl_FragCoord.xy-resolution)/max(resolution.x,resolution.y);
			for(int i=1;i<complexity;i++)
			{
				vec2 newp=p;
				newp.x+=0.6/float(i)*sin(float(i)*p.y+time/fluid_speed+0.3*float(i))+mouse.y/mouse_factor+mouse_offset;
				newp.y+=0.6/float(i)*sin(float(i)*p.x+time/fluid_speed+0.3*float(i+10))-mouse.x/mouse_factor+mouse_offset;
				p=newp;
			}
			vec3 col=vec3(color_intensity*sin(3.0*p.x)+color_intensity,color_intensity*sin(3.0*p.y)+color_intensity,sin(p.x+p.y));
			gl_FragColor=vec4(col, 1.0);
			}


			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}