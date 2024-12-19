Shader "GLSL/ Weird6" 
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

			//uniform sampler2D fft;

			#ifdef VERTEX // Begin vertex program/shader

			void main()
			{
				gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex; // Draws the Vertex at the correct position in world
			}

			#endif // Ends vertex program/shader

			#ifdef FRAGMENT // Begin fragment program/shader

			float freqs[4];

			#define PI 3.1415926535898
			#define max_ray_steps 12
			#define max_de_steps 14

			/*
			mat4 M = mat4
				(
					-5.740254e-01,
					4.547220e-01,
					1.309093e+00,
					0.000000e+00,
					-4.547220e-01,
					1.276698e+00,
					-6.428610e-01,
					0.000000e+00,
					-1.309093e+00,
					-6.428610e-01,
					-3.507233e-01,
					-0.000000e+00,
					3.896400e-01,
					-1.814425e-01,
					-5.258469e-02,
					1.000000e+00
				);
			*/

			float aspect_ratio = resolution.y / resolution.x;
			float ray_scale = (1. / max(resolution.x, resolution.y)) * .47;
			float fov = tan(45. * 0.17453292 * .7);


			float de(vec3 p){
				float r =0.,power = 8.,dr = 1.;
				vec3 z = p;
				for(int i=0;i<10;i++){
					r = length(z);
					if(r > 4.) break;
					float theta = acos(z.z / r) ;//+ fract(t/20.) * 6.3;
					float phi = atan(z.y,z.x);
					
					dr = pow(r,power-1.)*power*dr+1.;
					float zr =  pow(r,power);
					theta = theta * power;
					phi = phi*power;
					z =  zr*vec3(sin(theta) * cos(phi),sin(phi) * sin(theta),cos(theta)) ;
					z += p;
					
					
				}
				
				return .5 * log(r) * r / dr;
				
			}

			float det=0.;
			const float detail=.1;
			vec3 lightdir=normalize(vec3(-0.,-0.5,-1.));


			float shadow(vec3 pos, vec3 sdir) {
					float totalDist =2.0*det, sh=1.;
					for (int steps=0; steps<30; steps++) {
						if (totalDist<1.) {
							vec3 p = pos - totalDist * sdir;
							float dist = de(p)*1.5;
							if (dist < detail)  sh=0.;
							totalDist += max(0.05,dist);
						}
					}
					return max(0.,sh);	
			}

			float calcAO( const vec3 pos, const vec3 nor ) {
				float aodet=detail*10.;
				float totao = 0.0;
				float sca = 10.0;
				for( int aoi=0; aoi<5; aoi++ ) {
					float hr = aodet + aodet*float(aoi*aoi);
					vec3 aopos =  nor * hr + pos;
					float dd = de( aopos );
					totao += -(dd-hr)*sca;
					sca *= 0.15;
				}
				return clamp( 1.0 - 5.0*totao, 0.0, 1.0 );
			}



			vec3 raymarch(in vec3 from, in vec3 dir) {
					
				float l = 0.; 
				float d = 0.; 
				float e = 0.00001; 
				float it = 0.;
				
				for(int i=0;i<12;i++){
					d = de(from);
					
					from += d * dir;
					l += d;
					if(d<e) break;
					
					e = ray_scale * l;
					it++;	
				}	
				float f = 1. - (it / float(12));
				return  vec3(f);
			}

			// FFT alpha blend lines
			vec3 blenders(vec2 p){
				
				
				/*
				no audio data here at glsl sandbox
				freqs[0] = texture2D( fft, vec2( 0.01, 0.0 ) ).x;
				freqs[1] = texture2D( fft, vec2( 0.07, 0.0 ) ).x;
				freqs[2] = texture2D( fft, vec2( 0.15, 0.0 ) ).x;
				freqs[3] = texture2D( fft, vec2( 0.30, 0.0 ) ).x;
				*/
				float a = abs(fract(sin(time)*1.))*6.284;
				float b = abs(fract(sin(time)*.5))*6.284;
				float c = abs(fract(sin(time)*0.2))*6.284;
					
				vec2 pa = p + normalize(vec2(sin(a),-sin(a))) * 0.1;
				vec2 pb = p+ normalize(vec2(sin(b),-sin(c))) * 0.2;
				
				vec2 q = pb  + mod(fract(pa) * pa*1000.,14. + 0.5);
				
				float blenders = abs(length(pa/q) * 0.1);
				
				
				return vec3(1.0,1.0,1.) * blenders;		    
				
			}

			vec3 camPath(float t){
			
			
				
				float a = sin(t * 1.11);
				float b = cos(t * 1.14);
				return vec3(a*4. -b*1.5, b*1.7 + a*1.5, t);
				
			}



			void main(){
				
				vec2 tx = (gl_FragCoord.xy / resolution) - .5;
				
				
				float a =  time ;
				float sa = sin(a);
				float ca = cos(a);
				
				float fov  = tan(6. * 0.17453292 * .66);
				
				vec3 dir = vec3(tx.x * fov, tx.y * fov * aspect_ratio, 1.);
				
				
				dir.xy = vec2(dir.x * ca - dir.y * sa,dir.x * sa + dir.y * ca);
				dir.xz = vec2(dir.x * ca - dir.z * sa, dir.x  * sa + dir.z * ca); 
				
				vec3 cam = vec3(0.0,0.,-4.5 );
					cam.xz = vec2(cam.x * ca - cam.z * sa, cam.x * sa + cam.z * ca);
				
				float ao=calcAO(cam,dir);
				
				
				vec3 col = raymarch(cam,dir);
				
				
				vec3 r = reflect(lightdir,col);
				
				col =  col + r * ao;
				
				
				col = mix(col,blenders(tx),.6);
				
				gl_FragColor = vec4(  col  ,1.0);
			}
			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}