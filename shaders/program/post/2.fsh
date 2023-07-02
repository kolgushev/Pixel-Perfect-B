#include "/common_defs.glsl"

/* DRAWBUFFERS:04 */
layout(location = 0) out vec4 b0;
layout(location = 4) out vec4 b4;

in vec2 texcoord;

#define use_colortex0

#define use_near
#define use_far
#define use_boss_battle
#define use_invisibility

#define use_linearize_depth
#define use_tonemapping
#define use_color_manipulation

#if defined USE_LUT
    #define use_shadowcolor1_3d
#endif

#if DITHERING_MODE != 0
    #define use_noisetex

    #define use_view_width
    #define use_view_height

    #define use_sample_noise
#endif

#include "/lib/use.glsl"

void main() {
    vec4 albedo = texture(colortex0, texcoord);

    vec3 tonemapped = albedo.rgb;

    #if defined INVISIBILITY_DISTORTION
        const vec2 colorOffsets[3] = vec2[3](
            vec2(0.565, 0.825),
            vec2(0.432, -0.902),
            vec2(-0.997, 0.076)
        );
        vec3 magentaSample;
        vec3 cyanSample;
        vec3 yellowSample;
        if(invisibility > 0) {
            vec2 texcoordNormalized = texcoord * 2 - 1;
            
            float distortion = invisibility * (pow(texcoordNormalized.x, 2) + pow(texcoordNormalized.y, 2));
            distortion = abs(distortion);
            
            float displacement = distortion * INVISIBILITY_DISTORT_STRENGTH;
            
            magentaSample = texture(colortex0, texcoord + colorOffsets[0] * displacement).rgb;
            cyanSample = texture(colortex0, texcoord + colorOffsets[1] * displacement).rgb;
            yellowSample = texture(colortex0, texcoord + colorOffsets[2] * displacement).rgb;


            float k = RGBToCMYK(tonemapped).w;
            float c = RGBToCMYK(cyanSample).x;
            float m = RGBToCMYK(magentaSample).y;
            float y = RGBToCMYK(yellowSample).z;

            tonemapped = CMYKToRGB(vec4(c, m, y, k));
        }
    #endif

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
        vec3 tempColor = kelvinToRGB(POST_TEMP);
        tonemapped *= changeLuminance(tempColor, luminance(tempColor), 1.0);
    #endif

    // if fast GI is enabled, balance exposure accounting for increased brightness
    #if defined FAST_GI
        tonemapped /= 1 + FAST_GI_EXPOSURE_CORRECT_GRAY * FAST_GI_STRENGTH;
    #endif

    // this is personal taste, but Hable has some desaturated/dark colors, so compensate for that through post-processing
    #if LMT_MODE == 3
    #define LMT_MODE_EXPOSURE_WEIGHT 1.2
        #define LMT_MODE_EXPOSURE_WEIGHT 1.2
        #define LMT_MODE_CONTRAST_BIAS 0.1
    #else
        #define LMT_MODE_EXPOSURE_WEIGHT 1.0
        #define LMT_MODE_CONTRAST_BIAS 0.0
    #endif

    #define ADJUSTED_CONTRAST (CONTRAST + LMT_MODE_CONTRAST_BIAS)

    tonemapped *= EXPOSURE * LMT_MODE_EXPOSURE_WEIGHT;

    #if !defined DYNAMIC_EXPOSURE_LIGHTING
        tonemapped *= EXPOSURE_BIAS;
    #endif

    // tonemap image
    #if LMT_MODE == 1
        tonemapped = tonemapped * RCP_16;
    #elif LMT_MODE == 2
        tonemapped = reinhard(tonemapped);
    #elif LMT_MODE == 3
        tonemapped = uncharted2_filmic(tonemapped);
    #elif LMT_MODE == 4
        tonemapped = aces_fitted(tonemapped);
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

    // un-gamma-correct
    #if defined GAMMA_CORRECT
        colorCorrected = gammaCorrection(colorCorrected, GAMMA);
    #endif

    // restrict colors to a 0-1 range to prevent weirdness with contrast/saturation formulas
    colorCorrected = clamp(colorCorrected, 0, 1);

    // apply contrast
    if(ADJUSTED_CONTRAST != 0.0) {
        // equation for contrast is x+(1-|2x-1|)(2x-1)a
        // where "x" is the color channel and "a" is the contrast
        vec3 b = 2 * colorCorrected - 1;

        colorCorrected = colorCorrected + (1 - abs(b)) * b * ADJUSTED_CONTRAST;
    }

    // apply luma contrast
    if(LUMINANCE_CONTRAST != 0.0) {
        float luminance = luminance(colorCorrected);

        float b = 2 * luminance - 1;
        colorCorrected = changeLuminance(colorCorrected, luminance, luminance + (1 - abs(b)) * b * LUMINANCE_CONTRAST);
    }

    if(POST_SATURATION != 1.0) {
        colorCorrected = saturateRGB(POST_SATURATION) * max(colorCorrected, vec3(0));
    }

    // re-gamma-correct
    #if defined GAMMA_CORRECT
        colorCorrected = gammaCorrection(colorCorrected, RCP_GAMMA);
    #endif


    // dithering
    #if DITHERING_MODE != 0
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

        colorCorrected = colorCorrected + inverseMult;

        vec3 noiseToSurpass = sampleNoise(texcoord, 0, vec2(0,1), true).rgb;

        // noiseToSurpass = gammaCorrection(noiseToSurpass, RCP_GAMMA);
        
        vec3 interPrecisionGradient = mod(colorCorrected * mult, 1);

        /*
            Do a custom half-float -> 8bit sRGB conversion
            to avoid dealing with the complicated one done by openGL
        */
        colorCorrected = colorCorrected - mod(colorCorrected, inverseMult);

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