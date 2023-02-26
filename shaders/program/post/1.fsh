#include "/common_defs.glsl"

/* DRAWBUFFERS:0 */
layout(location = 0) out vec4 b0;

in vec2 texcoord;

uniform sampler2D colortex0;
uniform sampler2D depthtex1;
#if DITHERING_MODE != 0
    uniform sampler2D noisetex;

    uniform float viewWidth;
    uniform float viewHeight;
#endif

uniform float near;
uniform float far;

uniform sampler3D shadowcolor1;

uniform int isEyeInWater;
uniform int bossBattle;
uniform bool isInvisible;

#include "/lib/linearize_depth.fsh"
#include "/lib/tonemapping.glsl"
#include "/lib/color_manipulation.glsl"


#if DITHERING_MODE != 0
    #include "/lib/sample_noisetex.glsl"
    #include "/lib/sample_noise.glsl"
#endif

void main() {
    vec4 albedo = texture(colortex0, texcoord);

    const vec2 colorOffsets[2] = vec2[2](
        vec2(-1, 0),
        vec2(1, 0)
    );
    vec3 magentaSample;
    vec3 cyanSample;
    if(isInvisible) {
        float depth = linearizeDepth(texture(depthtex1, texcoord).r, near, far);
        float distortion = INVISIBILITY_DISTORT_STRENGTH * (0.1 + 0.9 / (depth));
        magentaSample = texture(colortex0, texcoord + colorOffsets[0] * distortion).rgb;
        cyanSample = texture(colortex0, texcoord + colorOffsets[1] * distortion).rgb;
    }

    vec3 tonemapped = albedo.rgb;
    
    if(isEyeInWater == 1) {
        tonemapped *= OVERLAY_COLOR_WATER;
        if(isInvisible) {
            magentaSample *= OVERLAY_COLOR_WATER;
            cyanSample *= OVERLAY_COLOR_WATER;
        }
    }

    if(isInvisible) {
        vec2 yk = RGBToCMYK(tonemapped).zw;
        float c = RGBToCMYK(cyanSample).x;
        float m = RGBToCMYK(magentaSample).y;

        tonemapped = CMYKToRGB(vec4(c + 0.1, m, yk.x * 0.95, yk.y + 0.02));

        tonemapped = saturateRGB(0.9) * tonemapped;
    }

    #if defined BOSS_BATTLE_COLORS
        // color effects for boss battles
        switch(bossBattle) {
            // ender dragon
            case 2:
                // TODO: write a satureateACES function
                tonemapped = saturateRGB(OVERLAY_SATURATION_ENDER_DRAGON) * tonemapped;
                tonemapped *= OVERLAY_COLOR_ENDER_DRAGON;
                break;
            // wither
            case 3:
                tonemapped = saturateRGB(OVERLAY_SATURATION_WITHER) * tonemapped;
                tonemapped *= OVERLAY_COLOR_WITHER;
                break;
            // raid
            case 4:
                tonemapped = saturateRGB(OVERLAY_SATURATION_RAID) * tonemapped;
                tonemapped *= OVERLAY_COLOR_RAID;
                break;
            default:
                break;
        }
    #endif

    // white balance
    #if POST_TEMP != 6550
        tonemapped *= kelvinToRGB(POST_TEMP);
    #endif

    tonemapped *= EXPOSURE * EXPOSURE_BIAS;

    // tonemap image
    #if LMT_MODE == 1
        tonemapped = tonemapped * RCP_16;
    #elif LMT_MODE == 2
        tonemapped = reinhard(tonemapped);
    #elif LMT_MODE == 3
        tonemapped = uncharted2_filmic(tonemapped);
    #elif LMT_MODE == 4
        tonemapped = rtt_and_odt_fit(tonemapped * ACEScg_to_RGB) * RGB_to_ACEScg;
    #endif

    // Convert back to desired colorspace
    #if OUTPUT_COLORSPACE == 0
        tonemapped = tonemapped * ACEScg_to_RGB;
    #elif OUTPUT_COLORSPACE == 2
        tonemapped = tonemapped * ACEScg_to_ACES2065_1;
    #endif

    // gamma correction
    vec3 colorCorrected = tonemapped;
    #if defined GAMMA_CORRECT
        colorCorrected = gammaCorrection(colorCorrected, RCP_GAMMA);
    #endif

    #if defined USE_LUT
        vec3 noBorder = removeBorder(colorCorrected, LUT_SIZE_RCP);

        // vec3 lutApplied = texture(shadowcolor1, removeBorder(vec3(texcoord, 1.0))).rgb;
        vec3 lutApplied = texture(shadowcolor1, noBorder).rgb;
                
        colorCorrected = vec3(lutApplied * LUT_RANGE_MULT);
    #endif

    // apply contrast
    if(CONTRAST != 0.0) {
        // equation for contrast is x+(1-|2x-1|)(2x-1)a
        // where "x" is the color channel and "a" is the contrast
        vec3 b = 2 * colorCorrected - 1;

        colorCorrected = colorCorrected + (1 - abs(b)) * b * CONTRAST;
    }

    if(POST_SATURATION != 1.0) {
        colorCorrected = saturateRGB(POST_SATURATION) * max(colorCorrected, vec3(0));
    }

    // dithering
    #if DITHERING_MODE != 0
        // TODO: rework to fix light loss bug
        // const float mult = 2;
        // const float inverseMult = 0.5;
        const float mult = 256;
        const float inverseMult = RCP_256;

        /*
            This dithering is unique, since it doesn't sample adjacent pixels.
            Instead, it uses the current color and a noise texture to randomly
            decrease the color by one bit based on its proximity to either
            the original or decreased color.
            This happens per every color channel individually.
        */

        vec3 noiseToSurpass = sampleNoise(texcoord, 0, vec2(0,1)).rgb;
        vec3 interPrecisionGradient = mod(colorCorrected * mult, 1);

        /*
            Do a custom half-float -> 8bit sRGB conversion
            to avoid dealing with the complicated one done by openGL
        */
        colorCorrected = floor(colorCorrected * mult) * inverseMult;

        vec3 factor = ceil(interPrecisionGradient - noiseToSurpass);

        colorCorrected = mix(colorCorrected - vec3(inverseMult), colorCorrected, factor);
    #endif

    // write the diffuse color
    vec4 finalColor = opaque(colorCorrected);

    #ifdef DEBUG_VIEW
        b0 = albedo;
    #else
        b0 = finalColor;
    #endif
}