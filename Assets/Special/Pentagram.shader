﻿Shader "GLSL/ Pentagram" 
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
			//#define time _Time.y

			#ifdef VERTEX // Begin vertex program/shader

			void main()
			{
				gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex; // Draws the Vertex at the correct position in world
			}

			#endif // Ends vertex program/shader

			#ifdef FRAGMENT // Begin fragment program/shader

			//varying vec3 positionSurface;
			//varying vec3 positionSize;

			vec3   iResolution = vec3(resolution, 1.0);
			float  iGlobalTime = _Time.y-60.;
			vec4   iMouse = vec4(mouse, 0.0, 1.0);
			uniform sampler2D iChannel0,iChannel1;

			//Oblivion by nimitz (twitter: @stormoid)

			/*
				Mostly showing off animated triangle noise, the idea is to just use	combinations
				of moving triangle waves to create animated noise. In practice, only very few
				layers of triangle wave basis are needed to produce animated noise that	is visually
				interesting (using 4 layers here), meaning that this runs considerably faster
				than equivalent animated perlin-style noise and without the need for value noise as input.
			*/

			#define ITR 50
			#define FAR 25.
			#define time (iGlobalTime)*0.2

			#define MSPEED 0.2
			#define ROTSPEED 0.2

			#define VOLSTEPS 13

			//#define PENTAGRAM_ONLY

			float hash(in float n){ return fract(log(n)*43758.5453); }
			mat2 mm2(in float a){float c = cos(a), s = sin(a);return mat2(c,-s,s,c);}

			float tri(in float x){return abs(fract(x)-mouse.x);}
			vec3 tri3(in vec3 p){return vec3( tri(p.z+tri(p.y*1.)), tri(p.z+tri(p.x*mouse.y)), tri(p.y+tri(p.x*mouse.y)));}                           

			vec3 path(in float t){return vec3(sin(t*.8),sin(t*0.25),0.)*0.3;}

			mat2 m2 = mat2( 0.970,  0.242, -0.242,  0.970 );
			float triNoise3d(in vec3 p)
			{
				float z=1.5;
				float rz = 0.;
				vec3 bp = p;
				for (float i=0.; i<=3.; i++ )
				{
					vec3 dg = tri3(bp*2.)*1.;
					p += (dg+time*0.25);

					bp *= 1.8;
					z *= 1.5;
					p *= 1.1;
					p.xz*= m2;
					
					rz+= (tri(p.z+tri(p.x+tri(p.y))))/z;
					bp += 0.14;
				}
				return rz;
			}

			float map(vec3 p)
			{
				p -= path(p.z);
				float d = 1.-length(p.xy);
				return d;
			}

			float march(in vec3 ro, in vec3 rd)
			{
				float precis = 0.001;
				float h=precis*2.0;
				float d = 0.;
				float id = 0.;;
				for( int i=0; i<ITR; i++ )
				{
					if( abs(h)<precis || d>FAR ) break;
					d += h;
					float res = map(ro+rd*d);
					h = res;
				}
				return d;
			}

			float mapVol(vec3 p)
			{
				p -= path(p.z);
				float d = 1.-length(p.xy);
				d -= triNoise3d(p*0.15)*1.2;
				return d*0.23;
			}

			vec4 marchVol( in vec3 ro, in vec3 rd )
			{
				vec4 rz = vec4(0);

				float t = 0.3;
				for(int i=0; i<VOLSTEPS; i++)
				{
					if(rz.a > 0.99)break;

					vec3 pos = ro + t*rd;
					float r = mapVol( pos );
					
					float gr =  clamp((r - mapVol(pos+vec3(.0,.1,.5)))/.5, 0., 1. );
					vec3 lg = vec3(0.7,0.5,.1)*1.2 + 3.*vec3(1)*gr;
					vec4 col = vec4(lg,r+0.55);
					
					col.a *= .2;
					col.rgb *= col.a;
					rz = rz + col*(1. - rz.a);
					t += 0.05;
				}
				rz.b += rz.w*0.2;
				rz.rg *= mm2(-rd.z*0.09);
				rz.rb *= mm2(-rd.z*0.13);
				return clamp(rz, 0.0, 1.0);
			}

			vec2 tri2(in vec2 p)
			{
				const float m = 1.5;
				return vec2(tri(p.x+tri(p.y*m)),tri(p.y+tri(p.x*m)));
			}

			float triNoise2d(in vec2 p)
			{
				float z=2.;
				float z2=1.5;
				float rz = 0.;
				vec2 bp = p;
				rz+= (tri(-time*0.5+p.x*(sin(-time)*0.3+.9)+tri(p.y-time*0.2)))*.7/z;
				for (float i=0.; i<=2.; i++ )
				{
					vec2 dg = tri2(bp*2.)*.8;
					dg *= mm2(time*2.);
					p += dg/z2;

					bp *= 1.7;
					z2 *= .7;
					z *= 2.;
					p *= 1.5;
					p*= m2;
					
					rz+= (tri(p.x+tri(p.y)))/z;
				}
				return rz;
			}


			vec3 shadePenta(in vec2 p, in vec3 rd)
			{   
				p*=4.5;    
				float rz= triNoise2d(p)*1.6;
				
				vec2 q = abs(p);
				float pen1 = max(max(q.x*1.176+p.y*0.385, q.x*0.727-p.y), p.y*1.237);
				float pen2 = max(max(q.x*1.176-p.y*0.385, q.x*0.727+p.y), -p.y*1.237);
				float d = abs(min(pen1,pen1-pen2*0.619)*4.28-.95)*1.2;
				d = min(d,abs(length(p)-1.)*3.);
				d = min(d,abs(pen2-0.37)*4.);
				d = pow(d,.7+sin(sin(time*4.1)+time)*0.15);
				rz = max(rz,d/(rz));
				
				vec3 col1 = vec3(.3,0.5,0.45)/(rz*rz);
				vec3 col2 = vec3(1.,0.5,0.25)/(rz*rz);
				vec3 col = mix(col1,col2,clamp(rd.z,0.,1.));
				
				return col;
			}

			void main(void)
			{	
				vec2 p = gl_FragCoord.xy/iResolution.xy-0.5;
				p.x*=iResolution.x/iResolution.y;
				p += vec2(hash(time),hash(time+1.))*0.008;
				float dz = sin(time*ROTSPEED)*8.+1.;
				vec3 ro = path(time*MSPEED+dz)*.7+vec3(0,0,time*MSPEED);
				ro.z += dz;
				ro.y += cos(time*ROTSPEED)*.4;
				ro.x += cos(time*ROTSPEED*2.)*.4;
				
				vec3 tgt = vec3(2,8,time*MSPEED+1.);
				vec3 eye = normalize( tgt - ro);
				vec3 rgt = normalize(cross( vec3(0.0,1.0,0.0), eye ));
				vec3 up = normalize(cross(eye,rgt));
				vec3 rd = normalize( p.x*rgt + p.y*up + .75*eye );
				
				#ifndef PENTAGRAM_ONLY
				
				float rz = march(ro,rd);
				
				vec3 pos = ro+rz*rd;
						
				vec4 col = marchVol(pos,rd);
				vec3 ligt = normalize( vec3(-.0, 0., -1.) );
				vec2 spi = vec2(sin(time),cos(time))*1.;
				float flick = clamp(1.-abs(((pos.z-time*MSPEED)*0.3+mod(time*5.,30.))-15.),0.,1.)*clamp(dot(pos.xy,spi),0.,1.)*1.7;
				flick += 	 clamp(1.-abs(((pos.z-time*MSPEED)*0.3+mod(time*5.+10.,30.))-15.),0.,1.)*clamp(dot(pos.xy,spi),0.,1.)*2.;
				flick += 	 clamp(1.-abs(((pos.z-time*MSPEED)*0.3+mod(time*5.+20.,30.))-15.),0.,1.)*clamp(dot(pos.xy,spi),0.,1.)*2.;
				col.rgb += flick*(step(mod(time,2.5),0.2))*.4;
				col.rgb += flick*(step(mod(time*1.5,3.2),0.2))*.4;
				
				col.rgb = mix(col.rgb*col.rgb*col.rgb,col.rgb*shadePenta(p,rd*rd)*9.0*1.2,(1.-col.w)*step(tri(time*40.25),1.1)*smoothstep(1.5,1.,2.*tri(time)));
				
				#else
				vec3  col = shadePenta(p,rd);
				col = pow(col,vec3(103.5))*100.4;
				#endif
				
				gl_FragColor = vec4( col.rgb, 1.0 );
			}


			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}