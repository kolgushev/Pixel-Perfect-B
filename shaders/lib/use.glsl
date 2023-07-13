// lib dependency defs - imports are above their dependencies
#if defined use_anti_banding
#endif

#if defined use_basic_direct_shading
#endif

// depends on: use_color_manipulation, use_to_viewspace, use_lightning_flash
#if defined use_calculate_lighting
	#define use_color_manipulation
	#define use_to_viewspace
	#define use_lightning_flash
#endif

#if defined use_calculate_sky
#endif

#if defined use_color_manipulation
#endif

#if defined use_distortion
#endif

#if defined use_fogify
	#define use_boss_battle
#endif

#if defined use_generate_wind
#endif

#if defined use_get_samples
#endif

// depends on: to_viewspace, basic_diret_shading
#if defined use_get_shadow
	#define use_to_viewspace
	#define use_basic_direct_shading
#endif

#if defined use_get_terrain_mask
#endif

#if defined use_hdr_mapping
#endif

// depends on: use_sample_noisetex
#if defined use_lava_noise
	#define use_sample_noisetex
#endif

#if defined use_lightning_flash
#endif

#if defined use_linearize_depth
#endif

// depends on: use_sample_noisetex
#if defined use_sample_noise
	#define use_sample_noisetex
#endif

#if defined use_sample_noisetex
	#define use_noisetex
#endif

#if defined use_sampling_algorithms
#endif

#if defined use_switch_fog_color
#endif

#if defined use_to_viewspace
#endif

#if defined use_tonemapping
#endif


// use uniforms
#include "/lib/use_uniforms.glsl"



// libs - imports are below their dependencies
#if defined use_anti_banding
#include "/lib/anti_banding.glsl"
#endif

#if defined use_basic_direct_shading
#include "/lib/basic_direct_shading.glsl"
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

// depends on: use_color_manipulation, use_to_viewspace
#if defined use_calculate_lighting
#include "/lib/calculate_lighting.glsl"
#endif

#if defined use_distortion
#include "/lib/distortion.glsl"
#endif

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

#if defined use_sampling_algorithms
#include "/lib/sampling_algorithms.glsl"
#endif

#if defined use_switch_fog_color
#include "/lib/switch_fog_color.glsl"
#endif

#if defined use_to_viewspace
#include "/lib/to_viewspace.glsl"
#endif

// depends on: to_viewspace
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