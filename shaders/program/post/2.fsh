#include "/common_defs.glsl"

/* DRAWBUFFERS:0 */
layout(location = 0) out vec4 b0;

in vec2 texcoord;

#if defined USE_LUT
    #define use_shadowcolor1_3d
#endif
#include "/lib/use.glsl"

void main() {

    #if defined FREEZING_DISTORTION || INVISIBILITY_DISTORTION != 0
        vec2 texcoordNormalized = texcoord * 2 - 1;
    #endif

    vec2 texcoordMod = texcoord;
    #if defined FREEZING_DISTORTION
        float freezeDistortion;
        if(freezing > 0.0) {
            float noiseSample = tile(texcoord * vec2(viewWidth, viewHeight) * 0.2 + frameTimeCounter * 0.5, NOISE_PERLIN_4D, false).x;

            freezeDistortion = freezing * pow(noiseSample, 7) * (pow(texcoordNormalized.x, 2) + pow(texcoordNormalized.y, 2)) * FREEZING_DISTORT_STRENGTH;

            texcoordMod += vec2(-dFdx(freezeDistortion), -dFdy(freezeDistortion));
        }
    #endif

    #if defined UNDERWATER_DISTORTION
        if(isEyeInWater == 1) {
            texcoordMod += vec2(sin((texcoord.y * UNDERWATER_DISTORT_FREQUENCY + frameTimeCounter * UNDERWATER_DISTORT_SPEED) * 2.0 * PI) * UNDERWATER_DISTORT_STRENGTH * 0.01 * (1.0 / UNDERWATER_DISTORT_FREQUENCY), 0.0);
        }
    #endif

    vec3 colorCorrected = texture(colortex0, texcoordMod).rgb;

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
            float distortion = invisibility * (pow(texcoordNormalized.x, 2) + pow(texcoordNormalized.y, 2));
            distortion = abs(distortion);
            
            #if INVISIBILITY_DISTORTION == 2
                float displacement = distortion * INVISIBILITY_DISTORT_STRENGTH * 0.75;
            #else
                float displacement = distortion * INVISIBILITY_DISTORT_STRENGTH;
            #endif

            magentaSample = texture(colortex0, texcoordMod + colorOffsets[0] * displacement).rgb;
            cyanSample = texture(colortex0, texcoordMod + colorOffsets[1] * displacement).rgb;
            yellowSample = texture(colortex0, texcoordMod + colorOffsets[2] * displacement).rgb;

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

    #if defined FREEZING_DISTORTION
        if(freezing > 0.0) {
            colorCorrected = mix(colorCorrected, ATMOSPHERIC_FOG_COLOR_POWDER_SNOW, 1.0 - exp(freezeDistortion * -ATMOSPHERIC_FOG_DENSITY_POWDER_SNOW));
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

    #if !defined DYNAMIC_EXPOSURE_LIGHTING
        colorCorrected *= EXPOSURE_WEIGHT;
    #endif

    // expose, also map from 0-(LUT domain max) to 0-1
    #if defined USE_LUT && !defined LUT_NO_MAPPING
        colorCorrected *= EXPOSURE * LUT_DOMAIN_MAX_RCP;
    #else
        colorCorrected *= EXPOSURE;
    #endif

    #if TONEMAP == TONEMAP_REINHARD
        colorCorrected = reinhard(colorCorrected, LUMINANCE_COEFFS_AP1);
    #elif TONEMAP == TONEMAP_HABLE
        colorCorrected = uncharted2_filmic(colorCorrected);
    #elif TONEMAP == TONEMAP_ACES_FITTED
        colorCorrected = aces_fitted(colorCorrected);
    #elif TONEMAP == TONEMAP_ACES_APPROX
        colorCorrected = aces_approx(colorCorrected);
    #elif TONEMAP == TONEMAP_CUSTOM
        colorCorrected *= 2.4;
        bvec3 applyTone = greaterThan(colorCorrected, vec3(0.1));
        vec3 colorCorrectedMod = 0.1 - colorCorrected;
        colorCorrected = mix(100.0 * colorCorrected * colorCorrectedMod * colorCorrectedMod + colorCorrected, colorCorrected, applyTone);
        colorCorrected *= 0.5;
        colorCorrected = aces_fitted(colorCorrected);
    #elif TONEMAP == TONEMAP_HLG
        colorCorrected = hlg(colorCorrected * RCP_12);
    #endif

    #if defined USE_LUT
        #if COLORSPACE_LUT_INPUT != COLORSPACE_ACESCG
            colorCorrected = ACEScgToColorspace(colorCorrected, COLORSPACE_LUT_INPUT);
        #endif

        #if !defined LUT_NO_MAPPING
            // map from 0-1 to 0-(LUT domain max), then (LUT domain min)-(LUT domain max) to 0-1
            colorCorrected = (colorCorrected * LUT_DOMAIN_MAX - LUT_DOMAIN_MIN) * LUT_DOMAIN_RANGE_RCP;
        #endif

        // map from 0-1 to texture sampling coordinates
        vec3 noBorder = removeBorder(colorCorrected, LUT_SIZE_RCP);
        
        vec3 lutApplied = texture(shadowcolor1, noBorder).rgb;
        colorCorrected = lutApplied * LUT_RANGE_MULT;

        #if COLORSPACE_LUT_OUTPUT != COLORSPACE_ACESCG
            colorCorrected = ColorspaceToACEScg(colorCorrected, COLORSPACE_LUT_OUTPUT);
        #endif
    #endif


    if(CONTRAST != 1.0 || SATURATION != 1.0) {
        // Convert to OKLab

        // effectively converts to XYZ with D65 whitepoint
        colorCorrected = ACEScgToOKLab(colorCorrected);

        if(CONTRAST != 1.0) {
            // equation for contrast is x+(1-|2x-1|)(2x-1)a
            // where "x" is the color channel and "a" is the contrast
            float b = 2.0 * colorCorrected.r - 1.0;

            colorCorrected.r = colorCorrected.r + (1.0 - abs(b)) * b * CONTRAST;
        }

        // same formula as contrast to preserve detail in vibrant colors
        if(SATURATION != 1.0) {
            colorCorrected.gb *= SATURATION;
        }

        colorCorrected = OKLabToACEScg(colorCorrected);
    }

    #if COLORSPACE_OUTPUT == -1
        #if defined IS_IRIS
            colorCorrected = ACEScgToColorspace(colorCorrected, currentColorSpace);
        #else
            colorCorrected = ACEScgToColorspace(colorCorrected, COLORSPACE_SRGB);
        #endif
    #else
        colorCorrected = ACEScgToColorspace(colorCorrected, COLORSPACE_OUTPUT);
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