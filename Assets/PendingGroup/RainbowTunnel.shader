Shader "GLSL/ RainbowTunnel" 
{
	// side tunnel flashy color thingo
// kebugcheckex 12-7-2017

// mouse affects tunnel end
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

void main( void ) {

	vec2 pos = gl_FragCoord.xy + mouse.xy;
	float d = dot(pos, vec2(sin(pos.x / time ), tan(pos.y / time)));
	float col = atan(d);
	gl_FragColor = vec4(sin(col*time), cos(col*time), tan(col*time), 1.0);
}

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}