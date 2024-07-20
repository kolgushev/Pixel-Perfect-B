#include "/common_defs.glsl"

/* DRAWBUFFERS:0 */
layout(location = 0) out vec4 b0;

in vec2 texcoord;

#include "/lib/use.glsl"

void main() {
    vec4 albedo = texture(colortex0, texcoord);

    vec3 tonemapped = albedo.rgb;

    #if INVISIBILITY_DISTORTION != 0
        const vec2 colorOffsets[3] = vec2[3](
            vec2(0.565, 0.825),
            vec2(0.432, -0.902),
            vec2(-0.997, 0.076)
        );
        vec3 magentaSample;
        vec3 cyanSample;
        vec3 yellowSample;
        if(invisibility > 0.0) {
            vec2 texcoordNormalized = texcoord * 2 - 1;
            
            float distortion = invisibility * (pow(texcoordNormalized.x, 2) + pow(texcoordNormalized.y, 2));
            distortion = abs(distortion);
            
            #if INVISIBILITY_DISTORTION == 2
                float displacement = distortion * INVISIBILITY_DISTORT_STRENGTH * 0.75;
            #else
                float displacement = distortion * INVISIBILITY_DISTORT_STRENGTH;
            #endif

            magentaSample = texture(colortex0, texcoord + colorOffsets[0] * displacement).rgb;
            cyanSample = texture(colortex0, texcoord + colorOffsets[1] * displacement).rgb;
            yellowSample = texture(colortex0, texcoord + colorOffsets[2] * displacement).rgb;

            #if INVISIBILITY_DISTORTION == 1
                float k = RGBToCMYK(tonemapped).w;
                float c = RGBToCMYK(cyanSample).x;
                float m = RGBToCMYK(magentaSample).y;
                float y = RGBToCMYK(yellowSample).z;

                tonemapped = CMYKToRGB(vec4(c, m, y, k));
            #elif INVISIBILITY_DISTORTION == 2
                tonemapped = (cyanSample + magentaSample + yellowSample + tonemapped) * 0.25;
            #endif
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
        #define LMT_MODE_EXPOSURE_WEIGHT 1.4
        #define LMT_MODE_CONTRAST_BIAS 0.1
        #define LMT_MODE_LUMINANCE_CONTRAST_BIAS 0.0
    #elif LMT_MODE == 5
        #define LMT_MODE_EXPOSURE_WEIGHT 1.3
        #define LMT_MODE_CONTRAST_BIAS 0.0
        #define LMT_MODE_LUMINANCE_CONTRAST_BIAS 0.1
    #else
        #define LMT_MODE_EXPOSURE_WEIGHT 1.0
        #define LMT_MODE_CONTRAST_BIAS 0.0
        #define LMT_MODE_LUMINANCE_CONTRAST_BIAS 0.0
    #endif

    #define ADJUSTED_CONTRAST (CONTRAST + LMT_MODE_CONTRAST_BIAS)
    #define ADJUSTED_LUMINANCE_CONTRAST (LUMINANCE_CONTRAST + LMT_MODE_LUMINANCE_CONTRAST_BIAS)

    tonemapped *= EXPOSURE * LMT_MODE_EXPOSURE_WEIGHT;

    #if !defined DYNAMIC_EXPOSURE_LIGHTING
        tonemapped *= EXPOSURE_WEIGHT;
    #endif

    // tonemap image
    #if LMT_MODE == 1
        tonemapped = reinhard(tonemapped, LUMINANCE_COEFFS_AP1);
    #elif LMT_MODE == 2
        tonemapped = hlg(tonemapped);
        // bring it back into linear space (HLG doubles as gamma-correction, and we are 99% chance displaying the output on an SDR screen)
        // and we will be applying a gamma-correction separately later
        tonemapped = gammaCorrection(tonemapped, GAMMA);
    #elif LMT_MODE == 3
        tonemapped = uncharted2_filmic(tonemapped);
    #elif LMT_MODE == 4
        tonemapped = aces_fitted(tonemapped);
    #elif LMT_MODE == 5
        tonemapped *= 2.0;
        bvec3 applyTone = greaterThan(tonemapped, vec3(0.1));
        vec3 tonemappedMod = 0.1 - tonemapped;
        tonemapped = mix(100.0 * tonemapped * tonemappedMod * tonemappedMod + tonemapped, tonemapped, applyTone);
        tonemapped *= 0.5;
        tonemapped = aces_fitted(tonemapped);
    #endif

    // restrict colors to a 0-1 range to prevent weirdness with contrast/saturation formulas
    vec3 colorCorrected = clamp(tonemapped, vec3(0), vec3(1));

    // TODO: remaster LUT input/output colorspace controls
    #if defined USE_LUT
        vec3 noBorder = removeBorder(colorCorrected, LUT_SIZE_RCP);

        // vec3 lutApplied = texture(shadowcolor1, removeBorder(vec3(texcoord, 1.0))).rgb;
        vec3 lutApplied = texture(shadowcolor1, noBorder).rgb;
                
        colorCorrected = vec3(lutApplied * LUT_RANGE_MULT);
    #endif

    // apply contrast
    if(ADJUSTED_CONTRAST != 0.0) {
        // equation for contrast is x+(1-|2x-1|)(2x-1)a
        // where "x" is the color channel and "a" is the contrast
        vec3 b = 2 * colorCorrected - 1;

        colorCorrected = colorCorrected + (1 - abs(b)) * b * ADJUSTED_CONTRAST;
    }

    // apply luma contrast
    if(ADJUSTED_LUMINANCE_CONTRAST != 0.0) {
        float luminance = dot(colorCorrected, LUMINANCE_COEFFS_AP1);

        float b = 2 * luminance - 1;
        colorCorrected = changeLuminance(colorCorrected, luminance, luminance + (1 - abs(b)) * b * ADJUSTED_LUMINANCE_CONTRAST);
    }

    if(POST_SATURATION != 1.0) {
        colorCorrected = saturateRGB(POST_SATURATION) * max(colorCorrected, vec3(0));
    }

    // colorCorrected = vec3(texcoord.x);

    // Convert back to desired color primaries
    #if OUTPUT_COLORSPACE == 0
        colorCorrected = colorCorrected * AP1_to_RGB;
        #define GAMMA_TRANSFORM_SRGB
    #elif OUTPUT_COLORSPACE == 1
        colorCorrected = colorCorrected * AP1_to_RGB;
    #elif OUTPUT_COLORSPACE == 2
        colorCorrected = colorCorrected * AP1_to_RGB;
        #define GAMMA_TRANSFORM_REGULAR
    #elif OUTPUT_COLORSPACE == 4
        #define GAMMA_TRANSFORM_REGULAR
    #elif OUTPUT_COLORSPACE == 5
        colorCorrected = colorCorrected * AP1_to_AP0;
    #elif OUTPUT_COLORSPACE == 6
        colorCorrected = colorCorrected * AP1_to_AP0;
        #define GAMMA_TRANSFORM_REGULAR
    #elif OUTPUT_COLORSPACE == 7
        colorCorrected = colorCorrected * AP1_to_XYZ;
    #endif

    #if defined GAMMA_TRANSFORM_SRGB
        #define gammaTransform(x) linear_to_srgb(x)
        #define gammaTransformInverse(x) srgb_to_linear(x)
    #elif defined GAMMA_TRANSFORM_REGULAR
        #define gammaTransform(x) gammaCorrection((x), RCP_GAMMA)
        #define gammaTransformInverse(x) gammaCorrection((x), GAMMA)
    #else
        #define gammaTransform(x) x
        #define gammaTransformInverse(x) x
    #endif

    colorCorrected = gammaTransform(colorCorrected);

    // dithering
    #if DITHERING_MODE != 0
        // const float mult = 2;
        // const float inverseMult = 0.5;
        const float mult = 256;
        const float inverseMult = RCP_256;

        /*
            This dithering uses the current color and a noise texture to randomly
            decrease the color by one bit based on its proximity to either
            the original or decreased color.
            This happens per every color channel individually.
        */

        colorCorrected = colorCorrected + inverseMult;

        vec3 noiseToSurpass = sampleNoise(texcoord * vec2(viewWidth, viewHeight), 0, NOISE_BLUE_3D, true).rgb;
        
        vec3 interPrecisionGradient = mod(colorCorrected * mult, vec3(1));

        /*
            Do a custom half-float -> 8bit sRGB conversion
            to avoid dealing with the (presumably) driver-dependent one done by openGL
        */
        colorCorrected = colorCorrected - mod(colorCorrected, vec3(inverseMult));

        vec3 factor = ceil(interPrecisionGradient - noiseToSurpass);

        colorCorrected = mix(colorCorrected - vec3(inverseMult), colorCorrected, factor);
    #endif

    vec4 finalColor = opaque(colorCorrected);

    #ifdef DEBUG_VIEW
        b0 = albedo;
    #else
        b0 = finalColor;
    #endif
}