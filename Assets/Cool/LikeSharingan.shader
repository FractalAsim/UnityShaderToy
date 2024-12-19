Shader "GLSL/ LikeSharingan" 
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

			uniform vec2 _ScreenParams; 
			uniform vec2 mouse;
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

			float _OutlineWidth = 0.02;
			float _LineWidth = 0.08;
			vec4 _OutlineColor = vec4(0.,0.,0.,0.);
			vec4 _FrontColor = vec4(1.0,1.0,1.0,1.0);

			// Noise
			float hash( vec2 p ) {
				float h = dot(p,vec2(127.1,311.7));	
				return fract(sin(h)*4758.5453123);
			}

			float noise( in vec2 p ) {
				vec2 i = floor( p );
				vec2 f = fract( p );	
				vec2 u = f*f*(3.0-2.0*f);
				return -1.0+2.0*mix( mix( hash( i + vec2(0.0,0.0) ), 
								hash( i + vec2(1.0,0.0) ), u.x),
							mix( hash( i + vec2(0.0,1.0) ), 
								hash( i + vec2(1.0,1.0) ), u.x), u.y);
			}

			//======================
			// Line functions
			//======================
			float line(vec2 pos, vec2 point1, vec2 point2, float width) {
				vec2 dir0 = point2 - point1;
				vec2 dir1 = pos - point1;
				float h = clamp(dot(dir0, dir1)/dot(dir0, dir0), 0.0, 1.0);
				float d = (length(dir1 - dir0 * h) - width * 0.5);
				return d;
			}

			vec4 line_with_color(vec2 pos, vec2 point1, vec2 point2, float width) {   		

				float d = line(pos, point1, point2, width);
				float w = fwidth(0.5*d) * 2.0;
				vec4 layer0 = vec4(_OutlineColor.rgb, 1.-smoothstep(-w, w, d - _OutlineWidth));
				vec4 layer1 = vec4(_FrontColor.rgb, 1.-smoothstep(-w, w, d));
				
				return mix(layer0, layer1, layer1.a);
			}

			void main()
			{
				float z=1.0+mouse.x*16.0;
				vec2 p = z*( gl_FragCoord.xy / _ScreenParams.xy ) - z/2.0;

				vec2 c = p;
				float iter = 0.0;
				vec4 color = vec4(0.0);
				vec2 oldp=vec2(0.0,0.0);
				
				gl_FragColor=vec4(0.0);
				
				for (int i = 0; i < 8; i++) {
					float an = atan(c.y, c.x)+ _Time.y*0.04*iter;
					float r = dot(c,c);
					if (r < 128.0)
					{
						c.x = ((cos(2.0*an))/r) + p.x;
						c.y = (-sin(2.0*an)/r) + p.y;
						
						vec2 p2=vec2(c.x,c.y);
						
						vec4 linea=line_with_color(p,oldp,p2,0.05);
				
						oldp=p2;
						
						gl_FragColor = mix(gl_FragColor,linea,linea.a*0.9);			
						
						iter+=2.0;
					}
				}
			}

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}