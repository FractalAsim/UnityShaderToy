Shader "GLSL/ YellowToBlack" 
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

			//uniform vec2 mouse;
			//uniform vec2 _ScreenParams; 
			uniform vec4 _Time; // (t/20, t, t*2, t*3)
			//uniform  vec4 unity_DeltaTime //  (dt, 1/dt, smoothDt, 1/smoothDt).
			//uniform  vec4 _SinTime // (t/8, t/4, t/2, t).
			//uniform  vec4 _CosTime // (t/8, t/4, t/2, t).

			#ifdef VERTEX // Begin vertex program/shader

			out vec4 texcoord;//add this texcoord as position to project to model
			void main()
			{
				texcoord = gl_MultiTexCoord0;//add this texcoord as position to project to model
				gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex; // Draws the Vertex at the correct position in world
			}

			#endif // Ends vertex program/shader

			#ifdef FRAGMENT // Begin fragment program/shader

			float color = 0.0;
			float color2=0.;

			in vec4 texcoord;//add this texcoord as position to project to model
			void main( void ) 
			{
				vec2 position = texcoord.yx;//add this texcoord as position to project to model
				color=0.5-position.x+abs(sin(_Time.y));	
				if (position.x>0.5)
				{
					//color=0.5+position.x-abs(sin(time+3.14/2.));
					
					color=0.5-position.x+abs(sin(_Time.y));	
				}
				else
				{
					color=0.5-(color-0.5);
				}
				
				gl_FragColor=vec4(color,color,0.,1.);
			}

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}