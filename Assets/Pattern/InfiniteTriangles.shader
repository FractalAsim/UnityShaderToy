Shader "GLSL/ InfiniteTriangles" 
{
	Properties
	{
	}
	SubShader
	{	
		Pass
		{
			GLSLPROGRAM // Begin GLSL

			uniform vec2 _ScreenParams; 
			uniform vec4 _Time; // (t/20, t, t*2, t*3)

			#ifdef VERTEX // Begin vertex program/shader

			void main()
			{
				gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex; // Draws the Vertex at the correct position in world
			}

			#endif // Ends vertex program/shader

			#ifdef FRAGMENT // Begin fragment program/shader

			float pattern(vec2 p)
			{
				p.x*=.866;
				p.x-=p.y*.5;
				p=mod(p,1.);
				return p.x+p.y<1.?0.:1.;
			}

			void main()
			{
				vec2 uv=(gl_FragCoord.xy*2.-_ScreenParams.xy)/min(_ScreenParams.x,_ScreenParams.y); 
				float a=0.,d=dot(uv,uv),s=0.,t=fract(_Time.y*.1),v=0.;
				for(int i=0;i<8;i++){s=fract(t+a);v+=pattern(uv*(pow(2.,(1.-s)*8.))*.5)*sin(s*3.14);a+=.125;}
				gl_FragColor = vec4(mix(vec3(.7,.8,1),vec3(.8,.8,.9),d)*v*.25,1);
			}

			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}