// use custom values
#include "/lib/use_custom_values.glsl"

// use uniforms
#include "/lib/use_uniforms.glsl"


// libs - imports are below their dependencies
#if defined g_vsh
#include "/lib/space_conversion/gbuffer_conversion.glsl"
#endif
#include "/lib/texture/bilinear_filter.glsl"
#if defined g_fsh
#include "/lib/texture/texture_filter.glsl"
#endif

#include "/lib/shading/basic_direct_shading.glsl"
#include "/lib/texture/bicubic_filter.glsl"
#include "/lib/atmospherics/calculate_sky.glsl"
#include "/lib/color/color_manipulation.glsl"
#include "/lib/shading/cook_torrance.glsl"
#include "/lib/effects/lightning_flash.glsl"
#include "/lib/color/tonemapping.glsl"
#include "/lib/atmospherics/hosek_wilkie_sky.glsl"
#include "/lib/atmospherics/pixel_perfect_sky.glsl"
#include "/lib/shading/calculate_lighting.glsl"
#include "/lib/space_conversion/distortion.glsl"
#include "/lib/atmospherics/fogify.glsl"
#include "/lib/effects/generate_wind.glsl"
#include "/lib/effects/get_terrain_mask.glsl"
#include "/lib/color/hdr_mapping.glsl"
#include "/lib/space_conversion/linearize_depth.glsl"
#include "/lib/texture/sample_noisetex.glsl"
#include "/lib/texture/sample_noise.glsl"
#include "/lib/atmospherics/switch_fog_color.glsl"
#include "/lib/space_conversion/to_viewspace.glsl"
#include "/lib/shading/get_shadow.glsl"
#include "/lib/effects/lava_noise.glsl"