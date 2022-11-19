// color grading and fog

#define color_pass

#include "/lib/common_defs.glsl"

layout(location = 0) out vec4 buffer0;

uniform float screenBrightness;
uniform mat4 gbufferModelView;
uniform vec3 fogColor;
uniform vec3 skyColor;
// uniform float fogStart;
uniform float far;
uniform int worldTime;

#include "/program/base/samplers.fsh"
uniform sampler3D shadowcolor1;

#include "/lib/calculate_sky.glsl"
#include "/lib/tonemapping.glsl"

void main() {
    vec4 coord = texture(colortex3, texcoord);
    vec4 albedo = texture(colortex0, texcoord);
    vec4 masks = vec4(texture(colortex4, texcoord));
    vec4 generic = texture(colortex5, texcoord);
    vec4 generic3 = texture(colortex7, texcoord);

    // apply things-look-blue-at-night-effect
    #if defined USE_NIGHT_EFFECT && defined NIGHT_EFFECT_AFTER_EXPOSURE
        vec3 darkLightFilter = saturateRGB(NIGHT_EFFECT_SATURATION) * (NIGHT_EFFECT_HUE * albedo.rgb);

        albedo.rgb = mix(darkLightFilter, albedo.rgb, clamp(nightEffect(NIGHT_EFFECT_POINT, luminance(albedo.rgb)), 0, 1));
    #endif

    // compute fog
    // float far_rcp = 1 / fogStart;
    float far_rcp = 1 / far;
    float fog = length(generic.xz);
    float maskingFog = abs(generic.y);
    // float maskingFog = 0.0;
        if(masks.r > 0.5 && masks.g < 0.5) {
            #if defined DIM_OVERWORLD || defined DIM_END
                fog = 0.0;
                maskingFog = 0.0;
            #else
                fog = far;
                maskingFog = far;
            #endif
        }

    #if defined DIM_NETHER
        vec3 skyColorProcessed = fogColor;
    #else
        vec3 skyColorProcessed = skyColor;
    #endif

    #ifdef GAMMA_CORRECT_PRE
        // linearize albedo
        skyColorProcessed = gammaCorrection(skyColorProcessed, GAMMA);
    #endif

    #ifdef ATMOSPHERIC_FOG
        float atmosPhog = (masks.r < 0.5 || masks.g > 0.5) ? length(generic.xyz) * ATOMSPHERIC_FOG_DENSITY : 0;
        atmosPhog = clamp(atmosPhog / (1.0 + atmosPhog), 0, 1);
        
        vec3 atmosPhogColor = ATMOSPHERIC_FOG_COLOR;
        #if defined DIM_NETHER
            skyColorProcessed = ATMOSPHERIC_FOG_COLOR;
        #endif
    #endif
    
    maskingFog = pow2(clamp(fma(maskingFog * far_rcp, 7, -6), 0, 1));
    fog = clamp(pow7(fog * far_rcp) + maskingFog, 0, 1);

    // apply fog
    #ifndef DEBUG_VIEW
        #ifdef ATMOSPHERIC_FOG
            albedo.rgb = mix(albedo.rgb, atmosPhogColor, atmosPhog);
        #endif
        albedo.rgb =  mix(albedo.rgb, sky(skyColorProcessed * RGB_to_ACEScg, worldTime), fog);
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
    
    vec3 tonemapped = exposedColor;

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

    // Apply contrast
    tonemapped = clamp(fma((tonemapped - 0.5), vec3(actualContrast), vec3(0.5)), 0, 1);

    // gamma correction
    vec3 colorCorrected = tonemapped;
    #ifdef GAMMA_CORRECT
        colorCorrected = gammaCorrection(colorCorrected, RCP_GAMMA);
    #endif

    #ifdef USE_LUT
        vec3 noBorder = removeBorder(colorCorrected);

        // vec3 lutApplied = texture(shadowcolor1, removeBorder(vec3(texcoord, 1.0))).rgb;
        vec3 lutApplied = texture(shadowcolor1, noBorder).rgb;
                
        colorCorrected = vec3(lutApplied * LUT_RANGE_MULT); 
    #endif

    // write the diffuse color
    vec4 finalColor = opaque(colorCorrected);

    #ifndef DEBUG_VIEW
        albedo = finalColor;
    #endif

    buffer0 = albedo;
}