#include "/common_defs.glsl"

#if defined DIM_NETHER
    #define NO_SKY
#endif

/* DRAWBUFFERS:01 */
layout(location=0) out vec4 b0;
layout(location=1) out vec4 b1;

in vec2 texcoord;

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;

uniform sampler2D depthtex1;

uniform sampler2D noisetex;


uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;

uniform float far;

uniform vec3 fogColor;
uniform int isEyeInWater;
uniform float nightVision;

uniform vec3 cameraPosition;
uniform float frameTimeCounter;

#if defined DIM_END
    uniform int bossBattle;
#endif

#include "/lib/switch_fog_color.glsl"
#include "/lib/fogify.glsl"
#include "/lib/to_viewspace.glsl"
#include "/lib/tonemapping.glsl"

#include "/lib/sample_noisetex.glsl"
#include "/lib/lava_noise.glsl"

void main() {
    vec3 sky = texture(colortex0, texcoord).rgb;
    vec4 albedo = texture(colortex1, texcoord);

    float depth = texture(depthtex1, texcoord).r;

    bool isSky = albedo.a == 0;

    // the nether doesn't render sky
    #if defined NO_SKY
        #if defined ATMOSPHERIC_FOG
            vec3 skyColorProcessed = ATMOSPHERIC_FOG_COLOR;
        #else
            vec3 skyColorProcessed = gammaCorrection(fogColor * 2, GAMMA) * RGB_to_ACEScg;
        #endif

        skyColorProcessed = getFogColor(isEyeInWater, skyColorProcessed);
    #else
        vec3 skyColorProcessed = sky.rgb;
    #endif

    vec3 position = getWorldSpace(gbufferProjectionInverse, gbufferModelViewInverse, texcoord, depth).xyz;
    vec4 fogged = fogify(position, position, opaque(albedo.rgb), albedo.rgb, far, isEyeInWater, nightVision, gammaCorrection(fogColor, GAMMA) * RGB_to_ACEScg, cameraPosition, frameTimeCounter, lavaNoise(cameraPosition.xz, frameTimeCounter));
    vec3 composite = fogged.rgb;
    float fog = fogged.a;

    // fade out around edges of world
    composite = isSky ? skyColorProcessed : mix(composite, skyColorProcessed, fog);
    
    // manually clear for upcoming transparency pass
    b1 = vec4(0.0);

    #ifdef DEBUG_VIEW
        b0 = albedo;
    #else
        b0 = opaque(composite);
    #endif
}