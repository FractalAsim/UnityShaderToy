Shader "GLSL/ Mandelbrot2" 
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
			uniform vec2 _ScreenParams; 
			uniform vec4 _Time; // (t/20, t, t*2, t*3)
			//uniform  vec4 unity_DeltaTime //  (dt, 1/dt, smoothDt, 1/smoothDt).
			//uniform  vec4 _SinTime // (t/8, t/4, t/2, t).
			//uniform  vec4 _CosTime // (t/8, t/4, t/2, t).

			#define SIDES 10
			#define maxIter 100

			#ifdef VERTEX // Begin vertex program/shader

			void main()
			{
				gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex; // Draws the Vertex at the correct position in world
			}

			#endif // Ends vertex program/shader

			#ifdef FRAGMENT // Begin fragment program/shader

			vec2 getPos() {
					vec2 pos = ( gl_FragCoord.xy / _ScreenParams.xy ) - vec2(0.5);
					pos.x *= _ScreenParams.x / _ScreenParams.y;
					return pos;
			}

			vec2 cmult(vec2 a, vec2 b){
					return vec2(a.x*b.x-a.y*b.y,a.x*b.y+a.y*b.x);                
			}

			float length2(vec2 v){
					return v.x*v.x+v.y*v.y;               
			}

			vec2 map(vec2 pos){
				return pos;	
				
			}

			vec2 iterate(vec2 p, vec2 c){
				vec2 p2 = cmult(p,p);
				
				return p2 + c; //Mandelbrot set
					//return p2 + vec2(.36,.085); //Julia Set
				//return p-(p2+tan(time*.2))/(p-cos(time*.2));
				//return tan(vec2(p.x+sin(time),p.y+cos(time)))-.52;
				//return tan(p2)-.52;
			}

			bool checkAbort(vec2 p, vec2 c){	
					return length2(p) > 400.; //Mandelbrot set
				//return length2(p) > 20.; //Julia set
				//return length2(p) > 15100.;
				//return length2(p) > 30.;
				//return length2(p) > 30.;
			}

			float l2 = log(2.);
			vec4 color(int iterations, vec2 p){
				//float col = (log(float(iterations))-.5) / (log(float(maxIter))+1.);	
				//float col = 1./log(length2(bailout));
				float col = .75-(float(iterations) - log(log(length2(p)))/l2 )/ float(maxIter);
				return vec4(col*1.2,col*1.1,col,1.);
			}
			//vec4 defaultColor = vec4(1., 0.85, 0.8, 1.);
			vec4 defaultColor = vec4(.05,0.025,0., 1.);

			void main()
			{
				vec2 c = map(getPos())*3. - vec2(0.5,0);//+vec2(sin(_Time.y)-1.1,0);
				vec2 p = c;
				float m;
						
				for(int i = 0; i < maxIter ;i++) {
					p = iterate(p,c);
					if(checkAbort(p,c)){        
							gl_FragColor = color(i,p);
							return;
					}
				}
						
				gl_FragColor = defaultColor;          
			}

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}