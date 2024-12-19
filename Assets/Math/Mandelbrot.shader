Shader "GLSL/ Mandelbrot" 
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

			float set_distance(float cx,float cy)
			{
				vec2 c=vec2(cx,cy);
				vec2 z=vec2(0.0);
				vec2 dz=vec2(1.0,0.0);
					float iters=0.0;
					vec2 z_new=vec2(0.0);
					vec2 dz_new=vec2(0.0);
					for(int i=0;i<maxIter;i++)
					{
						z_new=vec2(z.x*z.x-z.y*z.y,2.0*z.x*z.y)+c;
						dz_new=vec2(1.0,0.0)+2.0*vec2(z.x*dz.x-z.y*dz.y,z.x*dz.y+z.y*dz.x);
						z=z_new;
						dz=dz_new;
						if (length(z)>2.0)
						{
							break;
						}	
					}
				return length(z)*log(length(z))/length(dz);
			}

			void main()
			{
				vec2 r = _ScreenParams,
				o = gl_FragCoord.xy - r/2.;
				float realLen=length(o)/r.y/2.0-0.2;
				float len=0.0;
				float sidesS=3.0+abs(mod(_Time.y/10.0*2.0,2.0)-1.0)*2.0;
				float t=_Time.y/2.0;
				for(int i=0;i<SIDES;i++){
					if(i<int(floor(sidesS))+1){
					len=max(len,dot(o,vec2(cos(atan(0.0,-1.0)/float(sidesS)*float(i)*2.0+t),sin(atan(0.0,-1.0)/float(sidesS)*float(i)*2.0+t))));
					}
				}
				len=set_distance(o.x/r.y*2.0,o.y/r.y*2.0);
				o = vec2(len-0.03 , atan(o.y,o.x));    
				vec4 s = .03*cos(1.5*atan(0.0,-1.0)*vec4(0,1,2,3) + _Time.y + o.y + cos(o.y*3.0) * cos(_Time.y*1.0)*0.0),
				e = s.yzwx, 
				f = max(o.x-s,e-o.x);
				gl_FragColor = dot(clamp(f*r.y,0.,2.), 72.*(s-e)) * (s-.1) + f;
			}

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}