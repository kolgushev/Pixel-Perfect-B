#define use_atmospheric_fog_brightness_water

#include "/common_defs.glsl"

/* DRAWBUFFERS:014 */
layout(location = 0) out vec4 b0;
#if defined FAST_GI || defined DYNAMIC_EXPOSURE_LIGHTING
    layout(location = 1) out vec4 b1;
#endif
#if AA_MODE == 1
    layout(location = 2) out vec3 b4;
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

#define use_fogify
#define use_to_viewspace

#if defined DIM_END
    #define use_boss_battle
#endif

#if AA_MODE == 1
	#define use_colortex4
	#define use_colortex5

    #define use_frame_counter
    #define use_view_width
    #define use_view_height
#endif

#include "/lib/use.glsl"

void main() {
    vec3 albedo = texture(colortex0, texcoord).rgb;
    vec3 composite = albedo;

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

        atmosPhog = min(length(positionWater), far) * atmosPhog * (1 - nightVision * NIGHT_VISION_AFFECTS_FOG_WATER);

        atmosPhog = exp(-atmosPhog);

        composite = mix(ATMOSPHERIC_FOG_BRIGHTNESS_WATER * ATMOSPHERIC_FOG_COLOR_WATER, composite, atmosPhog);
    }


    #if defined DISABLE_WATER
        // divide by alpha since color is darker than usual due to transparency buffer being cleared to 0
        vec3 mixed = composite;
        vec3 multiplied = composite;
    #else
        vec4 transparency = texture(colortex1, texcoord);

        #if WATER_MIX_MODE != 0
            vec3 multiplied = composite * mix(vec3(1), saturateRGB(3.0) * transparency.rgb, transparency.a);
        #endif
        #if WATER_MIX_MODE != 1
            vec3 mixed = mix(composite, transparency.rgb / max(transparency.a, EPSILON), transparency.a);
        #endif
    #endif

    #if WATER_MIX_MODE == 1
        composite = multiplied;
    #elif WATER_MIX_MODE == 0
        composite = mixed;
    #else
        composite = mix(mixed, multiplied, WATER_MULT_STRENGTH);
    #endif

    #if AA_MODE == 1
        vec2 texcoordPrev = texcoord + texture2D(colortex5, texcoord).xy;

        // write the diffuse color
        vec3 prevFrame = texture2D(colortex4, texcoordPrev).rgb;

        vec3 minFrame = composite;
        vec3 maxFrame = composite;

        for(int i = 0; i < 4; i++) {
            vec3 neighborSample = texture2D(colortex0, texcoord + superSampleOffsets4[i].xy * 2 / vec2(viewWidth, viewHeight)).rgb;
            minFrame = min(minFrame, neighborSample);
            maxFrame = max(maxFrame, neighborSample);
        }

        prevFrame = clamp(prevFrame, minFrame, maxFrame);

        composite = mix(composite, prevFrame, frameCounter == 1 ? 0.0 : 0.9);
        b4 = composite;
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