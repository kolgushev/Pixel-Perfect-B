// lib dependency defs - imports are above their dependencies
#if defined use_basic_direct_shading
#endif

#if defined use_bicubic_filter
#endif

// depends on: color_manipulation, to_viewspace, lightning_flash, hosek_wilkie_sky
#if defined use_calculate_lighting
	#define use_gbuffer_model_view_inverse

	#define use_tonemapping
	#define use_color_manipulation
	#define use_to_viewspace
	#define use_lightning_flash
	#define use_hosek_wilkie_sky
	#define use_sun_position
	#define use_moon_position
	#define use_sky_time
	#define use_direct_light_mult
	#define use_night_vision
	#define use_darkness_factor
	#define use_darkness_light_factor
	#define use_is_lightning


	#if defined SPECULAR_ENABLED
		#define use_super_sample_offsets_cross
	#endif
#endif

#if defined use_calculate_sky
	#define use_rain_strength
#endif

#if defined use_pixel_perfect_sky
	#define use_direct_light_mult

	#define use_hosek_wilkie_sky
	#define use_color_manipulation
#endif

#if defined use_color_manipulation
#endif

#if defined use_fogify
	#define use_boss_battle
	#define use_rain_strength
#endif

#if defined use_generate_wind
#endif

#if defined use_get_samples
#endif

// depends on: sample_noise, to_viewspace, basic_direct_shading, distortion
#if defined use_get_shadow
	#define use_frame_counter

	#define use_sample_noise
	#define use_to_viewspace
	#define use_basic_direct_shading
	#define use_distortion

	#if SHADOW_FILTERING == 4 || SHADOW_FILTERING == 5
		#define use_super_sample_offsets_4
	#endif
#endif

#if defined use_distortion
	#define use_shadow_offsets
#endif

#if defined use_get_terrain_mask
#endif

#if defined use_hdr_mapping
#endif

#if defined use_hosek_wilkie_sky
#endif

// depends on: sample_noisetex
#if defined use_lava_noise
	#define use_sample_noisetex
#endif

#if defined use_lightning_flash
#endif

#if defined use_linearize_depth
	#define use_far
	#define use_near
#endif

// depends on: sample_noisetex
#if defined use_sample_noise
	#define use_sample_noisetex
	#define use_view_width
	#define use_view_height
#endif

#if defined use_sample_noisetex
	#define use_noisetex_3d
#endif

#if defined use_switch_fog_color
#endif

#if defined use_texture_filter
	#define use_bilinear_filter
#endif

#if defined use_bilinear_filter
	#define use_super_sample_offsets_4
#endif

#if defined use_to_viewspace
	#define use_gbuffer_model_view_inverse
	#define use_gbuffer_projection_inverse
#endif

#if defined use_tonemapping
#endif

#if defined use_gbuffer_conversion
	#define use_projection_matrix
	#define use_projection_matrix_inverse
	#define use_gbuffer_model_view
	#define use_gbuffer_projection

	#if defined gc_terrain
		#define use_chunk_offset
	#else
		#define use_model_view_matrix
		#define use_gbuffer_model_view_inverse
	#endif
#endif


// use custom values
#include "/lib/use_custom_values.glsl"

// use uniforms
#include "/lib/use_uniforms.glsl"


// libs - imports are below their dependencies
#if defined use_gbuffer_conversion
#include "/lib/space_conversion/gbuffer_conversion.glsl"
#endif

#if defined use_basic_direct_shading
#include "/lib/shading/basic_direct_shading.glsl"
#endif

#if defined use_bilinear_filter
#include "/lib/texture/bilinear_filter.glsl"
#endif

#if defined use_bicubic_filter
#include "/lib/texture/bicubic_filter.glsl"
#endif

#if defined use_calculate_sky
#include "/lib/atmospherics/calculate_sky.glsl"
#endif

#if defined use_color_manipulation
#include "/lib/color/color_manipulation.glsl"
#endif

#if defined use_lightning_flash
#include "/lib/effects/lightning_flash.glsl"
#endif

#if defined use_tonemapping
#include "/lib/color/tonemapping.glsl"
#endif

#if defined use_hosek_wilkie_sky
	#include "/lib/atmospherics/hosek_wilkie_sky.glsl"
#endif

#if defined use_pixel_perfect_sky
	#include "/lib/atmospherics/pixel_perfect_sky.glsl"
#endif

#if defined use_calculate_lighting
#include "/lib/shading/calculate_lighting.glsl"
#endif

#if defined use_distortion
#include "/lib/space_conversion/distortion.glsl"
#endif

// depends on: rain_strength
#if defined use_fogify
#include "/lib/atmospherics/fogify.glsl"
#endif

#if defined use_generate_wind
#include "/lib/effects/generate_wind.glsl"
#endif

#if defined use_get_terrain_mask
#include "/lib/effects/get_terrain_mask.glsl"
#endif

#if defined use_hdr_mapping
#include "/lib/color/hdr_mapping.glsl"
#endif

#if defined use_linearize_depth
#include "/lib/space_conversion/linearize_depth.glsl"
#endif

#if defined use_sample_noisetex
#include "/lib/texture/sample_noisetex.glsl"
#endif

// depends on: use_sample_noisetex
#if defined use_sample_noise
#include "/lib/texture/sample_noise.glsl"
#endif

#if defined use_switch_fog_color
#include "/lib/atmospherics/switch_fog_color.glsl"
#endif

#if defined use_texture_filter
#include "/lib/texture/texture_filter.glsl"
#endif

#if defined use_to_viewspace
#include "/lib/space_conversion/to_viewspace.glsl"
#endif

#if defined use_get_shadow
#include "/lib/shading/get_shadow.glsl"
#endif

// depends on: use_sample_noisetex
#if defined use_lava_noise
#include "/lib/effects/lava_noise.glsl"
#endif