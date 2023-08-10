#include "/common_defs.glsl"

/* DRAWBUFFERS:01 */
layout(location = 0) out vec4 b0;
#if defined FAST_GI || defined DYNAMIC_EXPOSURE_LIGHTING
    layout(location = 1) out vec4 b1;
#endif

in vec2 texcoord;


// uniforms


#define use_colortex0
#define use_colortex1
#define use_colortex2
#define use_depthtex0
#define use_shadowcolor1
#define use_noisetex

#define use_shadow_projection
#define use_shadow_model_view
#define use_gbuffer_projection_inverse
#define use_gbuffer_model_view_inverse
#define use_sky_time
#define use_frame_counter
#define use_view_width
#define use_view_height

#define use_sample_noisetex
#define use_sample_noise
#define use_get_shadow

#if defined RIMLIGHT_ENABLED
    #define use_colortex3
#endif

#if defined PIXELATED_SHADOWS
    #define use_colortex3
    #define use_camera_position
#endif

#include "/lib/use.glsl"

void main() {
    vec3 diffuse = texture(colortex0, texcoord).rgb;
    vec3 directLighting = texture(colortex1, texcoord).rgb;

    float skyLightmap = texture(colortex2, texcoord).g;
    float depth = texture(depthtex0, texcoord).r;
    
    vec3 position = getWorldSpace(texcoord, depth);

    vec3 pixelatedPosition = position;

    #if PIXELATED_SHADOWS != 0
        vec3 normal = texture(colortex3, texcoord).rgb;

        pixelatedPosition = floor((position + cameraPosition) * PIXELATED_SHADOWS - 0.5 * normal) / PIXELATED_SHADOWS;
        position = mix(pixelatedPosition - cameraPosition, position, ceil(abs(normal)));
    #endif

    float shadow = getShadow(
            position,
            pixelatedPosition,
            shadowProjection,
            shadowModelView,
            texcoord,
            shadowcolor1,
            noisetex,
            skyLightmap,
            skyTime);

    vec3 final = diffuse + directLighting * shadow;

    #if defined FAST_GI || defined DYNAMIC_EXPOSURE_LIGHTING
        b1 = opaque(final);
    #endif

    #if defined DEBUG_VIEW
        b0 = opaque(diffuse);
    #else
        b0 = opaque(final);
    #endif
}