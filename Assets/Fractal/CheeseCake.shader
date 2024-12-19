Shader "GLSL/ CheeseCake" 
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

			vec4 orb = vec4(1000);
			float de( vec3 p ,float s)
			{	
				float scale = 1.0;

				orb = vec4(1000.0); 
				
				for( int i=0; i<8;i++ )
				{
					p = -1.0 + 2.0*fract(0.5*p+0.5);

					float r2 = dot(p,p);
					
							orb = min( orb, vec4(abs(p),r2) );
					
					float k = s/r2;
					p     *= k;
					scale *= k;
				}
				
				return 0.25*abs(p.y)/scale;

			}


			vec3 normal( in vec3 pos, in float t, in float s )
			{
				float pre = 0.001 * t;
				vec2 e = vec2(1.0,-1.0)*pre;
				return normalize( e.xyy*de( pos + e.xyy, s ) + 
								e.yyx*de( pos + e.yyx, s ) + 
								e.yxy*de( pos + e.yxy, s ) + 
								e.xxx*de( pos + e.xxx, s ) );
			}


			float raymarch(in vec3 from, in vec3 dir,float s) {
				
				float maxd = 30.0;
				float t = 0.01;
				for( int i=0; i<250; i++ )
				{
					float precis = 0.001 * t;
					
				float h = de( from+dir*t, s );
					if( h<precis||t>maxd ) break;
					t += h;
				}

				if( t>maxd ) t=-1.0;
				return t;
			}

			float tri(in float x){return abs(fract(x)-.5);}
			vec3 tri3(in vec3 p){return vec3( tri(p.z+tri(p.y*1.)), tri(p.z+tri(p.x*1.)), tri(p.y+tri(p.x*1.)));}

			float triNoise3d(in vec3 p, in float spd)
			{
				float z=1.4;
				float rz = 0.;
				vec3 bp = p;
				for (float i=0.; i<=3.; i++ )
				{
					vec3 dg = tri3(bp*2.);
					p += (dg+time*spd);

					bp *= 1.8;
					z *= 1.5;
					p *= 1.2;
					
					rz+= (tri(p.z+tri(p.x+tri(p.y))))/z;
					bp += 0.14;
				}
				return rz;
			}

			float fogmap(in vec3 p, in float d)
			{
				p.x += time*2.5;
				p.z += sin(p.x*.5);
				return triNoise3d(p*2.2/(d+20.),0.2)*(1.-smoothstep(0.,.7,p.y));
			}

			vec3 fog(in vec3 col, in vec3 ro, in vec3 rd, in float mt)
			{
				float d = .5;
				for(int i=0; i<7; i++)
				{
					vec3  pos = ro + rd*d;
					float rz = fogmap(pos, d);
					float grd =  clamp((rz - fogmap(pos+.8-float(i)*0.1,d))*3., 0.1, 1. );
					
					vec3 col2 = (vec3(.8,0.8,.5)*.6 + .5*vec3(.5, .8, 1.)*(1.7-grd))*1.55;
					
					col = mix(col,col2,clamp(rz*smoothstep(d-0.4,d+2.+d*.75,mt),0.,1.) );
					d *= 1.5+0.3;
					if (d>mt)break;
				}
				return col;
			}



			vec3 postProcess(vec3 color){
				color*=vec3(1.,.94,.87);
				color=pow(color,vec3(1.3));
				color=mix(vec3(length(color)),color,.85)*0.95;
				return color;
			}


			void main( void ) {

				float tm = time*0.35 ;
				
				vec2 uv = (gl_FragCoord.xy / resolution) - .5;
				
				float anim = 1.1 + 0.5*smoothstep( -0.3, 0.3, cos(0.1*time) );
				
				
				vec3 ro = vec3( 2.8*cos(0.1+.33*tm), 0.4 + 0.30*cos(0.37*tm), 2.8*cos(0.5+0.35*tm) );
					vec3 ta = vec3( 1.9*cos(1.2+.41*tm), 0.4 + 0.10*cos(0.27*time), 1.9*cos(2.0+0.38*tm) );
					float roll =  0.2*cos(0.1*time);
					vec3 cw = normalize(ta-ro);
					vec3 cp = vec3(sin(roll), cos(roll),0.0);
					vec3 cu = normalize(cross(cw,cp));
					vec3 cv = normalize(cross(cu,cw));
					vec3 rd = normalize( uv.x*cu + uv.y*cv + 2.0*cw );

				float t = raymarch(ro,rd,anim);
				
				vec3 col = vec3(0.0);
				col+=vec3(1,.85,.7)*pow(max(0.,.3-length(uv-vec2(0.,.03)))/.3,1.5)*.35;
				
				vec3  light1 = vec3(  0.577, 0.577, -0.577 );
					vec3  light2 = vec3( -0.707, 0.000,  0.707 );
				
				if(t > 0.0){
				vec4 tra = orb;
					vec3 pos = ro + t*rd;
					vec3 nor = normal( pos, t, anim );

					
					float key = clamp( dot( light1, nor ), 0.0, 1.0 );
					float bac = clamp( 0.2 + 0.8*dot( light2, nor ), 0.0, 1.0 );
					float amb = (0.7+0.3*nor.y);
					float ao = pow( clamp(tra.w*2.0,0.0,1.0), 1.2 );
					
				vec3 ref = reflect (pos, nor);
					

					vec3 brdf  = 1.0*vec3(0.40,0.40,0.40)*amb*ao;
					brdf += 1.0*vec3(1.00,1.00,1.00)*key*ao;
					brdf += 1.0*vec3(0.40,0.40,0.40)*bac*ao;

					vec3 rgb = vec3(1.0);
					rgb = mix( rgb, vec3(1.0,0.80,0.2), clamp(6.0*tra.y,0.0,1.0) );
					rgb = mix( rgb, vec3(1.0,0.55,0.0), pow(clamp(1.0-2.0*tra.z,0.0,1.0),8.0) );

					col = rgb*brdf*exp(-0.0*t);
					
					
					
					col = sqrt(	col);
					}
				else{
					col = vec3(0);
					
						
				}
				
				col = fog(col,rd, ro, 3.5);

				gl_FragColor = vec4( postProcess(col),1.);
			}

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}