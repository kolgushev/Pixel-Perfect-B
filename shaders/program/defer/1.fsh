#include "/common_defs.glsl"

/* DRAWBUFFERS:01 */
layout(location=0) out vec4 b0;
layout(location=1) out vec4 b1;

in vec2 texcoord;


// uniforms

#define use_colortex0
#define use_colortex1
#define use_colortex2
#define use_depthtex1
#define use_noisetex

#define use_gbuffer_projection_inverse
#define use_gbuffer_model_view_inverse
#define use_far
#define use_fog_color
#define use_is_eye_in_water
#define use_night_vision
#define use_blindness_smooth
#define use_is_spectator
#define use_fog_weather_sky
#define use_fog_weather
#define use_in_sky
#define use_eye_brightness_smooth_float
#define use_camera_position
#define use_frame_time_counter

#define use_switch_fog_color
#define use_fogify
#define use_to_viewspace
#define use_tonemapping
#define use_lava_noise

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
#endif

#include "/lib/use.glsl"

void main() {
    vec3 sky = texture(colortex0, texcoord).rgb;
    vec4 albedo = texture(colortex1, texcoord);

    float depth = texture(depthtex1, texcoord).r;

    bool isSky = albedo.a == 0;
    #if OUTLINE_COLOR == -1
        bool isOutline = sky.rgb == vec3(-1);
    #endif

    // the nether doesn't render sky
    #if !defined HAS_SKY
        #if defined ATMOSPHERIC_FOG
            vec3 skyColorProcessed = ATMOSPHERIC_FOG_COLOR;
        #else
            vec3 skyColorProcessed = gammaCorrection(fogColor * 2, GAMMA) * RGB_to_ACEScg;
            #if defined FOG_ENABLED
                skyColorProcessed = mix(skyColorProcessed, ATMOSPHERIC_FOG_COLOR, fogWeather);
            #endif
        #endif

        skyColorProcessed = getFogColor(isEyeInWater, skyColorProcessed);
    #else
        vec3 skyColorProcessed = sky.rgb;
    #endif

    vec3 composite = albedo.rgb;

    vec3 position = getWorldSpace(gbufferProjectionInverse, gbufferModelViewInverse, texcoord, depth).xyz;
    float fog = fogifyDistanceOnly(position, far, blindnessSmooth, 1 / far);

    // fade out around edges of world
    composite = isSky ? skyColorProcessed : mix(composite, skyColorProcessed, fog);
    
    #if OUTLINE_COLOR == -1
        if(isOutline) {
            float luma = luminance(composite);
            composite = changeLuminance(composite, luma, 1 - luma);
        }
    #endif

    // manually clear for upcoming transparency pass
    #if WATER_MIX_MODE == 1
        b1 = vec4(1.0);
    #else
        // only clear alpha, keep color for proper mixing
        b1 = vec4(albedo.rgb, 0.0);
    #endif

    #ifdef DEBUG_VIEW
        b0 = albedo;
    #else
        b0 = opaque(composite);
    #endif
}