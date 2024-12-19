Shader "GLSL/ GraphPlot" 
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

			float f(float x)
			{ /** you can change the plot function here **/
				return sin(x+time);
			}

			bool cmp(float a, float b, float epsilon)
			{
				return (abs(a-b))<epsilon;
			}

			void main( void ) {

				vec2 p = gl_FragCoord.xy / resolution.xy * 8.0 - 4.;
				vec2 plot = gl_FragCoord.xy / resolution.xy;
				
				if(cmp(p.y, f(p.x), 0.03))
					gl_FragColor = vec4(1., 0., 0., 1.);
				
				else if (cmp(0.5, plot.x, 0.002) || cmp(0.5, plot.y, 0.004)) gl_FragColor = vec4(0.0, 1.0, 0.0, 1.0);
				else if(cmp(mod(.5007-plot.x, 0.0625), 0., 0.0014) || cmp(mod(.5007-plot.y, 0.125), 0., 0.003))
				gl_FragColor = vec4(1.);
					
				else gl_FragColor = vec4(.0);

			}

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}