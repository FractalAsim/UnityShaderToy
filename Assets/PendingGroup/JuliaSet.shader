Shader "GLSL/ JuliaSet" 
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

			vec3 hsv2rgb(vec3 c) {
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
	
void main( void ) {

	vec2 p = ( gl_FragCoord.xy - resolution.xy/2.0)/ resolution.y*4.0;
	
	vec2 c = vec2(0.7885*cos(time/2.0), 0.7885*sin(time/2.0));
	//vec2 c = (mouse-vec2(0.5))*2.0;
	
	float x = p.x, y = p.y;

	int nIter=0;
	for (int i=0; i<=40; i++) {
		float x_temp = x*x-y*y;
		y = 2.0*x*y;
		x = x_temp;
		x += c.x;
		y += c.y;
		nIter = i;
		if (sqrt(x*x+y*y) > 4.0) {
			break;
		}
	}
	
	vec3 col;
	if (nIter!=40) {
		float hueRate = 1.0;
		col = hsv2rgb(vec3((float(nIter)/40.0)*hueRate, 1.0, 0.8));
	}

	gl_FragColor = vec4( vec3(col), 1.0 );

}

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}