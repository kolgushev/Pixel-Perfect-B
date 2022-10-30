// color grading

#define color_pass

#include "/lib/common_defs.glsl"
#include "/program/base/configure_buffers.fsh"

uniform float screenBrightness;
uniform mat4 gbufferModelView;
uniform vec3 fogColor;
uniform vec3 skyColor;
uniform float far;
uniform int worldTime;

#include "/program/base/samplers.fsh"
uniform sampler2D depthtex2;

#include "/lib/calculate_sky.glsl"
#include "/lib/tonemapping.glsl"

void main() {
    #define READ_ALBEDO
    #define WRITE_ALBEDO

    #define READ_COORD
    
    #define READ_MASKS
    #define OVERRIDE_MASKS
    
    #define READ_GENERIC
    #define OVERRIDE_GENERIC
    
    #define READ_GENERIC3
    #define OVERRIDE_GENERIC3

    #include "/program/base/passthrough_1.fsh"

    // apply things-look-blue-at-night-effect
    #if defined USE_NIGHT_EFFECT && defined NIGHT_EFFECT_AFTER_EXPOSURE
        vec3 darkLightFilter = saturateRGB(NIGHT_EFFECT_SATURATION) * (NIGHT_EFFECT_HUE * albedo.rgb);

        albedo.rgb = mix(darkLightFilter, albedo.rgb, clamp(nightEffect(NIGHT_EFFECT_POINT, luminance(albedo.rgb)), 0, 1));
    #endif

    // compute fog
    float far_rcp = 1 / far;
    float fog = masks.r < 0.5 ? length(generic.xz) * far_rcp : 0;
    float maskingFog = masks.r < 0.5 ? abs(generic.y) * far_rcp : 0;
    maskingFog = pow2(clamp(maskingFog * 10 - 9, 0, 1));
    fog = clamp(pow6(fog) + maskingFog, 0, 1);

    // apply fog
    #ifndef DEBUG_VIEW
        vec3 skyColorProcessed = skyColor; 
        #ifdef GAMMA_CORRECT_PRE
            // linearize albedo
            skyColorProcessed = gammaCorrection(skyColorProcessed, GAMMA);
        #endif
        albedo.rgb =  mix(albedo.rgb, sky(skyColorProcessed * sRGB_to_ACEScg, worldTime), fog);
    #endif

    #ifdef AUTO_EXPOSE
        float cameraExposure = generic3.a;
    #else
        float cameraExposure = 1;
    #endif
    
    // const float actualScreenBrightness = fma(screenBrightness, 0.5, 0.5);
    const float actualScreenBrightness = 1;

    const float exposureBias = 0.7;
    const float contrastBias = 1;

    float actualContrast = (CONTRAST * contrastBias);
    
    // expose image
    vec3 exposedColor = albedo.rgb * EXPOSURE * cameraExposure * actualScreenBrightness * exposureBias;
    
    dvec3 tonemapped = exposedColor;

    #if RTT_MODE == 1
        tonemapped = tonemapped * RCP_16;
    #elif RTT_MODE == 2
        tonemapped = 1 - (1 / (1 + tonemapped));
    #elif RTT_MODE == 3
        tonemapped = rtt_and_odt_fit(dvec3(tonemapped) * ACEScg_to_sRGB) * sRGB_to_ACEScg;
    #endif

    // Convert back to desired colorspace
    #if OUTPUT_COLORSPACE == 0
        tonemapped = tonemapped * ACEScg_to_sRGB;
    #elif OUTPUT_COLORSPACE == 2
        tonemapped = tonemapped * ACEScg_to_ACES2065_1;
    #endif

    // Apply contrast
    tonemapped = clamp(fma((tonemapped - 0.5), vec3(actualContrast), vec3(0.5)), 0, 1);

    // gamma correction
    vec3 colorCorrected = vec3(tonemapped);
    #ifdef GAMMA_CORRECT
        colorCorrected = gammaCorrection(colorCorrected, RCP_GAMMA);
    #endif

    #ifdef USE_LUT
        dvec3 noBorder = removeBorder(colorCorrected);
        
        // apply LUT
        double blueScaled = colorCorrected.b * (LUT_SIZE - 1);

        int tileIdLow = int(floor(blueScaled));
        float heightOffsetLow = tileIdLow * LUT_SIZE_RCP;
        vec2 lutCoordLow = vec2(noBorder.r, noBorder.g * LUT_SIZE_RCP + heightOffsetLow);
        
        int tileIdHigh = int(ceil(blueScaled));
        float heightOffsetHigh = tileIdHigh * LUT_SIZE_RCP;
        vec2 lutCoordHigh = vec2(noBorder.r, noBorder.g * LUT_SIZE_RCP + heightOffsetHigh);
        
        vec3 colorCorrectedLow = texture(depthtex2, lutCoordLow).rgb;
        vec3 colorCorrectedHigh = texture(depthtex2, lutCoordHigh).rgb;
        
        double mixer = mod(colorCorrected.b, LUT_SIZE_RCP1) * (LUT_SIZE - 1);
        
        colorCorrected = vec3(mix(colorCorrectedLow, colorCorrectedHigh, mixer) * LUT_RANGE_MULT); 
    #endif

    // write the diffuse color
    vec4 finalColor = opaque(colorCorrected);

    #ifndef DEBUG_VIEW
        albedo = opaque(exposedColor);
        albedo = finalColor;
    #endif

    #include "/program/base/passthrough_2.fsh"
}