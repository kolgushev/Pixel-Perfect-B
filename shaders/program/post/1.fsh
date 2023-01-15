#include "/common_defs.glsl"

/* DRAWBUFFERS:0 */
layout(location = 0) out vec4 b0;

in vec2 texcoord;

uniform sampler2D colortex0;
#if DITHERING_MODE != 0
    uniform sampler2D noisetex;

    uniform float viewWidth;
    uniform float viewHeight;
#endif

uniform sampler3D shadowcolor1;

uniform int isEyeInWater;

#include "/lib/tonemapping.glsl"

#if DITHERING_MODE != 0
    #include "/lib/sample_noisetex.glsl"
#endif

void main() {
    vec4 albedo = texture(colortex0, texcoord);

    vec3 tonemapped = albedo.rgb;
    
    if(isEyeInWater == 1) {
        tonemapped *= OVERLAY_COLOR_WATER;
    }

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
        vec3 noBorder = removeBorder(colorCorrected);

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
            increase the color by one bit based on its proximity to either
            the original or increased color.
            This happens per every color channel individually.
        */

        vec3 noiseToSurpass = sampleNoise(texcoord, 0).rgb;
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