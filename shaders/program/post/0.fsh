#define use_atmospheric_fog_brightness_water

#include "/common_defs.glsl"

/* DRAWBUFFERS:01 */
layout(location = 0) out vec4 b0;
#if defined FAST_GI || defined DYNAMIC_EXPOSURE_LIGHTING
    layout(location = 1) out vec4 b1;
#endif


in vec2 texcoord;


#include "/lib/use.glsl"

void main() {
    vec3 albedo = texture(colortex0, texcoord).rgb;
    vec3 composite = albedo;

    float depth = texture(depthtex1, texcoord).r;
    float depthWater = texture(depthtex0, texcoord).r;
    #if defined DISTANT_HORIZONS
        float dhDepth = texture(dhDepthTex1, texcoord).r;
        float dhDepthWater = texture(dhDepthTex0, texcoord).r;
    #endif

    vec3 position = getWorldSpace(texcoord, depth);
    vec3 positionWater = getWorldSpace(texcoord, depthWater);
    
    #if defined DISTANT_HORIZONS
        if(depth == 1.0) {
            position = getWorldSpace(texcoord, dhDepth, dhProjectionInverse);
        }
        if(depthWater == 1.0) {
            positionWater = getWorldSpace(texcoord, dhDepthWater, dhProjectionInverse);
        }
    #endif

    if(isEyeInWater == 1) {
        float atmosPhog = 1.0;

        atmosPhog = ATMOSPHERIC_FOG_DENSITY_WATER;
        if(isSpectator) {
            atmosPhog *= ATMOSPHERIC_FOG_SPECTATOR_MULT_WATER;
        }

        #if defined DISTANT_HORIZONS
            #define FAR dhFarPlane
        #else
            #define FAR far
        #endif

        atmosPhog = min(length(positionWater), FAR) * atmosPhog * (1 - nightVision * NIGHT_VISION_AFFECTS_FOG_WATER);

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

    // hybrid tonemapping using a trick from UE4 TAA
    // https://de45xmedrsdbp.cloudfront.net/Resources/files/TemporalAA_small-59732822.pdf#page=19
    #if defined TAA_ENABLED && defined TAA_HYBRID_TONEMAP
        composite = reinhard(composite);
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