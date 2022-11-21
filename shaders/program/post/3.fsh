#include "/lib/common_defs.glsl"

layout(location = 0) out vec4 b0;

in vec2 texcoord;

uniform sampler2D colortex0;

uniform sampler3D shadowcolor1;

#include "/lib/tonemapping.glsl"

void main() {
    vec4 albedo = texture(colortex0, texcoord);

    vec3 tonemapped = albedo.rgb;

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

    // write the diffuse color
    vec4 finalColor = opaque(colorCorrected);

    #ifdef DEBUG_VIEW
        b0 = albedo;
    #else
        b0 = finalColor;
    #endif
}