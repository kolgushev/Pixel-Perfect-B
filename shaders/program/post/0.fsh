#include "/common_defs.glsl"

/* DRAWBUFFERS:01 */
layout(location = 0) out vec4 b0;
#if defined GI_FAST
    layout(location = 1) out vec4 b1;
#endif

in vec2 texcoord;

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;

#if defined PIXELATED_SHADOWS
    uniform sampler2D colortex3;

    uniform vec3 cameraPosition; 
#endif

uniform sampler2D depthtex0;
// uniform sampler2D shadowcolor0;
uniform sampler2D shadowcolor1;
uniform sampler2D noisetex;

uniform mat4 shadowProjection;
uniform mat4 shadowModelView;

uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;

uniform int worldTime;

uniform int frameCounter;
uniform float viewWidth;
uniform float viewHeight;

#include "/lib/sample_noisetex.glsl"
#include "/lib/sample_noise.glsl"

// don't need to include to_viewspace since calculate_lighting already includes it
#include "/lib/to_viewspace.glsl"
#include "/lib/get_shadow.glsl"

void main() {
    vec3 diffuse = texture(colortex0, texcoord).rgb;
    vec3 directLighting = texture(colortex1, texcoord).rgb;

    float skyLightmap = texture(colortex2, texcoord).g;
    float depth = texture(depthtex0, texcoord).r;
    vec3 position = getWorldSpace(gbufferProjectionInverse, gbufferModelViewInverse, texcoord, depth).xyz;

    vec3 pixelatedPosition = position;

    #if PIXELATED_SHADOWS != 0
        vec3 normal = texture(colortex2, texcoord).rgb;

        pixelatedPosition = floor((position + cameraPosition) * PIXELATED_SHADOWS - 0.5 * normal) / PIXELATED_SHADOWS;
        position = mix(pixelatedPosition - cameraPosition, position, ceil(abs(normal)));
    #endif

    float shadow = getShadow(
            position,
            pixelatedPosition,
            shadowProjection,
            shadowModelView,
            texcoord,
            shadowcolor1,
            noisetex,
            skyLightmap,
            worldTime);

    vec3 final = diffuse + directLighting * shadow;

    #if defined GI_FAST
        b1 = hand(depth) ? opaque1(GI_FAST_EXPOSURE_CORRECT_GRAY) : opaque(final);
    #endif

    #if defined DEBUG_VIEW
        b0 = opaque(diffuse);
    #else
        b0 = opaque(final);
    #endif
}