Shader "GLSL/ RainbowPostprocess" 
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

			float sphere(in vec3 position, in float radius)
			{
				return length(position)-radius;
			}


			float cube(vec3 p, vec3 s)
			{
				vec3 d 	= (abs(p) - s);
				return min(max(d.x,max(d.y,d.z)),0.0) + length(max(d,0.0));
			}


			mat2 rmat(float theta)
			{
				float c = cos(theta);
				float s = sin(theta);
				
				return mat2(c, s, -s, c);	
			}


			float map(in vec3 position)
			{
				float sphere_radius	= .25;	
				vec3 sphere_position 	= vec3(0., 0., 2.);
				sphere_position		+= -position;
				float sphere_distance	= sphere(sphere_position, sphere_radius);
				
				
				vec3 cube_radius	= vec3(.025, .025, .025);	
				vec3 cube_position 	= vec3(0., 0., 2.);
				float cube_velocity	= time * .5;
				cube_position.xy	+= vec2(0., .25) * rmat(cube_velocity);
				cube_position.xz	+= vec2(0., .25) * rmat(cube_velocity);
				cube_position		+= -position;
				cube_position.xz	*= rmat(time);
				cube_position.xy	*= rmat(time);
				float cube_distance	= cube(cube_position, cube_radius);
				
					
				
				float floor_plane_height	= .5 + cos(position.x * 8. + time * .25) * .1;
				float floor_plane_distance	= position.y + floor_plane_height;
				
				
				float back_plane_range		= 6.;
				float back_plane_distance	= back_plane_range-position.z;
				
				
				
				float surface_distance 	= min(min(min(sphere_distance, cube_distance), floor_plane_distance), back_plane_distance);	
				return surface_distance;
			}



			///////////////////////////////////////////////////////////////////////////////////////////////

			struct Ray
			{
				vec3 origin;
				vec3 position;	
				vec3 direction;
				vec3 color;
				float length;
				float distance;
				float curvature;
				bool intersection;
			};


			float derive_curvature(in vec3 p, in float w);
			vec3 derive_gradient(in vec3 position, in float range);
			void trace(inout Ray ray);
			float distribution(const in float r, const in float ndh);
			float shadow(in vec3 position, in vec3 direction, in float light_range);
			vec3 hsv(float h,float s,float v);
			void shade(inout Ray ray);
			mat2 rmat(float theta);

			void main( void ) 
			{
				vec2 pixel_coordinate	= gl_FragCoord.xy;
				vec2 aspect		= resolution/min(resolution.x, resolution.y);
				vec2 view_coordinate	= (pixel_coordinate/resolution - .5) * aspect;	
				float view_curvature	= 1.6;
				
				
				
				Ray ray;
				ray.origin		= vec3(0.);
				ray.position		= ray.origin;
				ray.direction		= normalize(vec3(view_coordinate, view_curvature));;
				ray.distance		= map(ray.position);
				ray.length		= 0.;
				ray.intersection	= false;
				
				trace(ray);
				shade(ray);
				
					
				
				gl_FragColor.rgb 		= ray.color;
				gl_FragColor.a			= 1.; 	
			}


			void trace(inout Ray ray)
			{	
				const float max_length	=65.;
				const float iterations	= 512.;
				float threshold		= 1./max(resolution.x, resolution.y);
				for(float i = 0.; i < iterations; i++)
				{
					if(ray.intersection == false && ray.length < max_length)
					{
						ray.position 		= ray.origin + ray.direction * ray.length;
						ray.distance 		= map(ray.position);				
						
						float curvature		= derive_curvature(ray.position, ray.distance * 2.);
						ray.length		+= ray.distance * .25;
						
						if(ray.distance <= threshold)
						{
							ray.intersection 	= true;
						}

						
						ray.curvature		+= curvature;
					}
				}
			}


			float derive_curvature(in vec3 p, in float w)
			{
				vec3 e = vec3(w, 0, 0);
				
				float t1 = map(p + e.xyy), t2 = map(p - e.xyy);
				float t3 = map(p + e.yxy), t4 = map(p - e.yxy);
				float t5 = map(p + e.yyx), t6 = map(p - e.yyx);
				
				return .25/e.x*(t1 + t2 + t3 + t4 + t5 + t6 - 6.0*map(p));
			}


			vec3 derive_gradient(in vec3 position, in float range)
			{
				vec2 offset     = vec2(0., range);
				vec3 normal     = vec3(0.);
				normal.x    	= map(position+offset.yxx)-map(position-offset.yxx);
				normal.y    	= map(position+offset.xyx)-map(position-offset.xyx);
				normal.z    	= map(position+offset.xxy)-map(position-offset.xxy);
				return normalize(normal);
			}


			float distribution(const in float r, const in float ndh)
			{  
				float m     = 2./(r*r) - 1.;
				return (m+r)*pow(abs(ndh), m)*.5;
			}
			


			float shadow(in vec3 position, in vec3 direction, in float light_range)
			{
				float exposure 	= 1.0;
				float penumbra 	= 0.25;
				float umbra	= .01;
				
					for(int i = 1; i < 12; ++i)
					{
					float range	= map(position - direction * penumbra);
					
					if (range < umbra) return umbra;
					
					exposure 	= min( exposure, light_range * range / penumbra);
					penumbra 	+= range;
				}
				
				return exposure;
			}



			vec3 hsv(float h,float s,float v)
			{
				return mix(vec3(1.),clamp((abs(fract(h+vec3(3.,2.,1.)/3.)*6.-3.)-1.),0.,1.),s)*v;
			}




			void shade(inout Ray ray)
			{
				if(ray.intersection)
				{						
					
					float threshold		= 4./max(resolution.x, resolution.y);
					vec3 surface_gradient 	= derive_gradient(ray.position, ray.distance-threshold);
					float surface_curvature = derive_curvature(ray.position, .0025);
					vec3 surface_normal	= normalize(surface_gradient);
					
					vec3 surface_color	= vec3(.25, .25, .25);
					ray.color		= surface_color;
					
					vec3 light_position		= vec3(12., 16., -5.);		
					float light_range		= length(light_position-ray.position);
					vec3 light_color		= vec3(.85, .85, .75);
					vec3 light_direction		= normalize(ray.position - light_position);
					vec3 bounce_direction		= normalize(ray.direction + light_direction);
					float diffuse_light		= distribution(.975, max(dot(surface_normal, bounce_direction), 0.));

					float specular_light		= distribution(.05, max(dot(surface_normal, bounce_direction), 0.));
					specular_light			= clamp(specular_light,0., 1.);
						
					float shadows			= shadow(ray.position, light_direction, light_range);
					

					vec3 field_curvature_color	= hsv(ray.curvature * .125, 1.5, .85) * .25;
					float field_curvature_lines	= 1.-clamp(dot(abs(fract(ray.curvature*.5)-.5), 24.), 0., 1.);					
					
					light_color			*= shadows;
					
					ray.color			= field_curvature_color;
					ray.color			+= light_color * diffuse_light;
					ray.color			+= light_color * specular_light;

					ray.color			+= light_color * surface_curvature * .125;
					ray.color			+= field_curvature_lines * .5;
				}	
				else
				{
					vec3 background_color 	= vec3(.5, .5, .45) + ray.direction.y * 2.;
					ray.color 		= background_color;	
				}
			}


			#endif // Ends fragment program/shader

			ENDGLSL // End GLSL
		}
	}
}