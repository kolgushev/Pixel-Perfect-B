// lib dependency defs - imports are above their dependencies
#if defined use_anti_banding
#endif

#if defined use_basic_direct_shading
#endif

#if defined use_bicubic_filter
#endif

// depends on: color_manipulation, to_viewspace, lightning_flash, hosek_wilkie_sky
#if defined use_calculate_lighting
	#define use_gbuffer_model_view_inverse

	#define use_color_manipulation
	#define use_to_viewspace
	#define use_lightning_flash
	#define use_hosek_wilkie_sky

	#if defined SPECULAR_ENABLED
		#define use_super_sample_offsets_cross
	#endif
#endif

#if defined use_calculate_sky
	#define use_rain_strength
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
#endif

#if defined use_tonemapping
#endif


// use custom values
#include "/lib/use_custom_values.glsl"

// use uniforms
#include "/lib/use_uniforms.glsl"


// libs - imports are below their dependencies
#if defined use_anti_banding
#include "/lib/anti_banding.glsl"
#endif

#if defined use_basic_direct_shading
#include "/lib/basic_direct_shading.glsl"
#endif

#if defined use_bilinear_filter
#include "/lib/bilinear_filter.glsl"
#endif

#if defined use_bicubic_filter
#include "/lib/bicubic_filter.glsl"
#endif

#if defined use_calculate_sky
#include "/lib/calculate_sky.glsl"
#endif

#if defined use_color_manipulation
#include "/lib/color_manipulation.glsl"
#endif

#if defined use_lightning_flash
#include "/lib/lightning_flash.glsl"
#endif

#if defined use_hosek_wilkie_sky
	#include "/lib/atmospherics/hosek_wilkie_sky.glsl"
#endif

#if defined use_calculate_lighting
#include "/lib/calculate_lighting.glsl"
#endif

#if defined use_distortion
#include "/lib/distortion.glsl"
#endif

// depends on: rain_strength
#if defined use_fogify
#include "/lib/fogify.glsl"
#endif

#if defined use_generate_wind
#include "/lib/generate_wind.glsl"
#endif

#if defined use_get_terrain_mask
#include "/lib/get_terrain_mask.glsl"
#endif

#if defined use_hdr_mapping
#include "/lib/hdr_mapping.glsl"
#endif

#if defined use_linearize_depth
#include "/lib/linearize_depth.glsl"
#endif

#if defined use_sample_noisetex
#include "/lib/sample_noisetex.glsl"
#endif

// depends on: use_sample_noisetex
#if defined use_sample_noise
#include "/lib/sample_noise.glsl"
#endif

#if defined use_switch_fog_color
#include "/lib/switch_fog_color.glsl"
#endif

#if defined use_texture_filter
#include "/lib/texture_filter.glsl"
#endif

#if defined use_to_viewspace
#include "/lib/to_viewspace.glsl"
#endif

#if defined use_get_shadow
#include "/lib/get_shadow.glsl"
#endif

#if defined use_tonemapping
#include "/lib/tonemapping.glsl"
#endif

// depends on: use_sample_noisetex
#if defined use_lava_noise
#include "/lib/lava_noise.glsl"
#endif