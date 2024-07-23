#include "/common_defs.glsl"

/* DRAWBUFFERS:0 */
layout(location = 0) out vec4 b0;

in vec2 texcoord;

#include "/lib/use.glsl"

void main() {
    vec4 albedo = texture(colortex0, texcoord);

    vec3 colorCorrected = albedo.rgb;

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
                float k = RGBToCMYK(colorCorrected).w;
                float c = RGBToCMYK(cyanSample).x;
                float m = RGBToCMYK(magentaSample).y;
                float y = RGBToCMYK(yellowSample).z;

                colorCorrected = CMYKToRGB(vec4(c, m, y, k));
            #elif INVISIBILITY_DISTORTION == 2
                colorCorrected = (cyanSample + magentaSample + yellowSample + colorCorrected) * 0.25;
            #endif
        }
    #endif

    #if defined BOSS_BATTLE_COLORS
        // color effects for boss battles
        switch(bossBattle) {
            // ender dragon
            case 2:
                // TODO: write a satureateACES function
                colorCorrected = saturateRGB(OVERLAY_SATURATION_ENDER_DRAGON) * colorCorrected;
                colorCorrected *= OVERLAY_COLOR_ENDER_DRAGON;
                break;
            // wither
            case 3:
                colorCorrected = saturateRGB(OVERLAY_SATURATION_WITHER) * colorCorrected;
                colorCorrected *= OVERLAY_COLOR_WITHER;
                break;
            // raid
            case 4:
                colorCorrected = saturateRGB(OVERLAY_SATURATION_RAID) * colorCorrected;
                colorCorrected *= OVERLAY_COLOR_RAID;
                break;
            default:
                break;
        }
    #endif

    // white balance
    #if POST_TEMP != 6550
        vec3 tempColor = kelvinToColor(POST_TEMP);
        colorCorrected *= changeLuminance(tempColor, dot(tempColor, LUMINANCE_COEFFS_AP1), 1.0);
    #endif

    colorCorrected *= EXPOSURE;

    #if !defined DYNAMIC_EXPOSURE_LIGHTING
        colorCorrected *= EXPOSURE_WEIGHT;
    #endif

    #if TONEMAP == REINHARD_TONEMAP
        colorCorrected = reinhard(colorCorrected, LUMINANCE_COEFFS_AP1);
    #elif TONEMAP == HABLE_TONEMAP
        colorCorrected = uncharted2_filmic(colorCorrected);
    #elif TONEMAP == ACES_FITTED_TONEMAP
        colorCorrected = aces_fitted(colorCorrected);
    #elif TONEMAP == ACES_APPROX_TONEMAP
        colorCorrected = aces_approx(colorCorrected);
    #elif TONEMAP == CUSTOM_TONEMAP
        colorCorrected *= 2.4;
        bvec3 applyTone = greaterThan(colorCorrected, vec3(0.1));
        vec3 colorCorrectedMod = 0.1 - colorCorrected;
        colorCorrected = mix(100.0 * colorCorrected * colorCorrectedMod * colorCorrectedMod + colorCorrected, colorCorrected, applyTone);
        colorCorrected *= 0.5;
        colorCorrected = aces_fitted(colorCorrected);
    #endif

    #if defined USE_LUT
        vec3 noBorder = removeBorder(colorCorrected * LUT_DOMAIN_MULT - LUT_DOMAIN_SUBTRACT, LUT_SIZE_RCP);
        
        vec3 lutApplied = texture(shadowcolor1, noBorder).rgb;
        colorCorrected = lutApplied * LUT_RANGE_MULT;
    #endif

    colorCorrected = clamp(colorCorrected, 0.0, 1.0);

    // TODO: Contrast, saturation

    #if OUTPUT_COLORSPACE == -1
        #if defined IS_IRIS
            colorCorrected = ACEScgToColorspace(colorCorrected, currentColorSpace);
        #else
            colorCorrected = ACEScgToColorspace(colorCorrected, SRGB_COLORSPACE);
        #endif
    #else
        colorCorrected = ACEScgToColorspace(colorCorrected, OUTPUT_COLORSPACE);
    #endif

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