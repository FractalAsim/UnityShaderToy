Shader "GLSL/ LightTail" 
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

			void main()
			{
				vec2 uPos = ( gl_FragCoord.xy / _ScreenParams.xy );//normalize wrt y axis
				//uPos -= vec2((_ScreenParams.x/resolution.y)/2.0, 0.0);//shift origin to center
				
				uPos.x -= 0.5;
				
				float vertColor = 0.0;
				for( float i = 0.0; i < 1.0; ++i )
				{
					float t = _Time.y * (i + 0.9);
				
					uPos.x += sin( uPos.y + t ) * 0.3;
				
					float fTemp = abs(1.0 / uPos.x / 100.0);
					vertColor += fTemp;
				}
					vec4 color = vec4( vertColor, vertColor, vertColor * 2.5, 1.0 );

				gl_FragColor = color;
  			}	

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}