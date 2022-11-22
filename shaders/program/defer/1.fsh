#include "/lib/common_defs.glsl"

#if defined DIM_NETHER
    #define NO_SKY
#endif

layout(location=0) out vec4 b0;
layout(location=1) out vec4 b1;
layout(location=3) out vec4 b3;
layout(location=4) out vec4 b4;
layout(location=5) out vec4 b5;

in vec2 texcoord;

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D colortex5;

uniform float far;

uniform vec3 fogColor;

#include "/lib/tonemapping.glsl"
#include "/lib/fogify.glsl"

void main() {
    vec3 sky = texture(colortex0, texcoord).rgb;
    vec4 albedo = texture(colortex1, texcoord);
    vec3 position = texture(colortex5, texcoord).xyz;

    bool isSky = albedo.a == 0;

    // the nether doesn't render sky
    #if defined NO_SKY
        #if defined ATMOSPHERIC_FOG
            vec3 skyColorProcessed = ATMOSPHERIC_FOG_COLOR;
        #else
            vec3 skyColorProcessed = gammaCorrection(fogColor * 2, GAMMA) * RGB_to_ACEScg;
        #endif
    #else
        vec3 skyColorProcessed = sky.rgb;
    #endif

    vec4 fogged = fogify(position, albedo.rgb, far);
    vec3 composite = fogged.rgb;
    float fog = fogged.a;

    // fade out around edges of world
    composite = isSky ? skyColorProcessed : mix(composite, skyColorProcessed, fog);
    
    // manually clear for upcoming transparency pass
    b1 = vec4(0);
    b3 = vec4(0);
    b4 = vec4(0);
    b5 = vec4(0);

    #ifdef DEBUG_VIEW
        b0 = albedo;
    #else
        b0 = opaque(composite);
    #endif
}