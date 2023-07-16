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
#define use_depthtex0
#define use_depthtex1

#define use_gbuffer_projection_inverse
#define use_gbuffer_model_view_inverse
#define use_fog_weather
#define use_far
#define use_is_eye_in_water
#define use_night_vision
#define use_blindness_smooth
#define use_is_spectator
#define use_fog_color
#define use_camera_position
#define use_frame_time_counter
#define use_lava_noise
#define use_camera_position
#define use_in_sky
#define use_eye_brightness_smooth_float
#define use_fog_weather_sky

#if defined DIM_END
    #define use_boss_battle
#endif

#if defined RIMLIGHT_ENABLED
    #define use_colortex3

    #define use_near
    #define use_aspect_ratio
    #define use_view_width
    #define use_view_height

    #define use_linearize_depth
    #define use_tonemapping
#endif

#define use_fogify
#define use_to_viewspace

#include "/lib/use.glsl"

void main() {
    vec3 composite = texture(colortex0, texcoord).rgb;

    float depth = texture(depthtex1, texcoord).r;
    float depthWater = texture(depthtex0, texcoord).r;

    vec3 position = getWorldSpace(gbufferProjectionInverse, gbufferModelViewInverse, texcoord, depth).xyz;
    vec3 positionWater = getWorldSpace(gbufferProjectionInverse, gbufferModelViewInverse, texcoord, depthWater).xyz;

    if(isEyeInWater == 1) {
        float atmosPhog = 1.0;

        atmosPhog = ATMOSPHERIC_FOG_DENSITY_WATER;
        if(isSpectator) {
            atmosPhog *= ATMOSPHERIC_FOG_SPECTATOR_MULT_WATER;
        }

        atmosPhog = length(positionWater) * atmosPhog * (1 - nightVision * NIGHT_VISION_AFFECTS_FOG_WATER);

        atmosPhog = exp(-atmosPhog);

        composite = mix(ATMOSPHERIC_FOG_BRIGHTNESS_WATER * ATMOSPHERIC_FOG_COLOR_WATER, composite, atmosPhog);
    }


    vec4 transparency = texture(colortex1, texcoord);
    #if WATER_MIX_MODE != 0
        vec3 multiplied = composite * mix(vec3(1), saturateRGB(3.0) * transparency.rgb, transparency.a);
    #endif
    #if WATER_MIX_MODE != 1
        // divide by alpha since color is darker than usual due to transparency buffer being cleared to 0
        vec3 mixed = mix(composite, transparency.rgb / max(transparency.a, EPSILON), transparency.a);
    #endif

    #if WATER_MIX_MODE == 1
        composite = multiplied;
    #elif WATER_MIX_MODE == 0
        composite = mixed;
    #else
        composite = mix(mixed, multiplied, WATER_MULT_STRENGTH);
    #endif

    #if defined FAST_GI || defined DYNAMIC_EXPOSURE_LIGHTING
        b1 = opaque(composite);
    #endif

    #if defined DEBUG_VIEW
        b0 = opaque(albedo);
    #else
        b0 = opaque(composite);
    #endif
}