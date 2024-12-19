﻿Shader "GLSL/ Nebula5" 
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

			#define iterations 17
			#define formuparam 0.53

			#define volsteps 20
			#define stepsize 0.1

			#define zoom   0.800
			#define tile   0.850
			#define speed  0.010 

			#define brightness 0.0015
			#define darkmatter 0.300
			#define distfading 0.730
			#define saturation 0.850

			void main()
			{
				//get coords and direction
				vec2 uv=gl_FragCoord.xy/resolution.xy-.001;
				uv.y*=resolution.y/resolution.x;
				vec3 dir=vec3(uv*zoom,1.);
				float rtime=time*speed+.25;
				vec3 from=vec3(1.,.5,0.5);
				from+=vec3(rtime*2.,rtime,-2.);
				
				//volumetric rendering
				float s=0.2,fade=1.5;
				vec3 v=vec3(0.);
				for (int r=0; r<volsteps; r++) {
					vec3 p=from+s*dir*.5;
					p = abs(vec3(tile)-mod(p,vec3(tile*1.5))); // tiling fold
					float pa,a=pa=1.;
					for (int i=0; i<iterations; i++) { 
						p=abs(p)/dot(p,p)-formuparam; // the magic formula
						a+=abs(length(p)-pa); // absolute sum of average change
						pa=length(p);
					}
					float dm=max(0.183764372039847189,darkmatter-a*a*.1); //dark matter
					a*=a*a; // add contrast
					if (r>6) fade*=1.2-dm; // dark matter, don't render near
					//v+=vec3(dm,dm*.5,0.);
					v+=fade;
					v+=vec3(s,s*s,s*s*s*s)*a*brightness*fade; // coloring based on distance
					fade*=distfading; // distance fading
					s+=stepsize;
				}
				v=mix(vec3(length(v)),v,saturation); //color adjust
				gl_FragColor = vec4(v*.006,1000.);	
			}

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}