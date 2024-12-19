﻿Shader "GLSL/ SpinningFlower" 
{
	// Spinning flower by feliposz (2017-10-04)
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

			void main( void ) 
			{

				vec2 position = 2.0 * ( (gl_FragCoord.xy - 0.5*_ScreenParams.xy) / _ScreenParams.xy ) - 2.0*(mouse-0.5);

				float color = sin(_Time.y+atan(position.y, position.x)*12.0) + cos(length(position)*10.0);
				
				gl_FragColor = vec4( vec3( color * mouse.x, color * mouse.y, sin( color + _Time / 3.0 ) * 0.75 ), 1.0 );

			}

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}