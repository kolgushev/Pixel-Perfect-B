#include "/lib/common_defs.glsl"

#if defined DIM_NETHER
    #define NO_SKY
#endif

layout(location=0) out vec4 b0;

in vec2 texcoord;

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D colortex5;

uniform float far;

uniform vec3 fogColor;

#include "/lib/tonemapping.glsl"

void main() {
    vec4 sky = texture(colortex0, texcoord);
    vec4 albedo = texture(colortex1, texcoord);
    vec4 transparent = texture(colortex2, texcoord);
    vec3 position = texture(colortex5, texcoord).xyz;

    bool isSky = albedo.a == 0;

    // Render fog in a cylinder shape
    float farRcp = 1 / far;
    float fogTube = length(position.xz) + 16;
    float fogFlat = length(position.y);

    // the nether doesn't render sky
    #if defined NO_SKY
        vec3 skyColorProcessed = gammaCorrection(fogColor * 2, GAMMA) * RGB_to_ACEScg;
    #else
        vec3 skyColorProcessed = sky.rgb;
    #endif

    // TODO: optimize
    fogFlat = pow2(clamp(fma(fogFlat * farRcp, 7, -6), 0, 1));
    fogTube = pow2(clamp(fma(fogTube * farRcp, 7, -6), 0, 1));
    fogTube = clamp(fogTube + fogFlat, 0, 1);

    vec3 composite = albedo.rgb;

    #if defined ATMOSPHERIC_FOG
        float atmosPhog = length(position) * ATOMSPHERIC_FOG_DENSITY;
        atmosPhog = clamp(atmosPhog / (1 + atmosPhog), 0, 1);

        #if defined NO_SKY
            skyColorProcessed = ATMOSPHERIC_FOG_COLOR;
        #endif

        composite = mix(composite, ATMOSPHERIC_FOG_COLOR, atmosPhog);
    #endif

    // fade out around edges of world
    composite = isSky ? skyColorProcessed : mix(composite, skyColorProcessed, fogTube);

    // multiply in transparent objects
    // TODO: shade in gc_transparent, allow mixing
    // TODO: apply fog as alpha in gc_transparent
    composite *= mix(vec3(1), transparent.rgb, transparent.a);

    b0 = opaque(composite);
}