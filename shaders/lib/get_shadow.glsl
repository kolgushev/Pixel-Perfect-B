#include "/lib/distortion.glsl"

float getShadow(in vec3 position, in mat4 shadowProjection, in mat4 shadowModelView, in sampler2D shadowtex) {
    #if defined TEX_RENDER
        vec3 positionMod = position;
    #else
        vec3 positionMod = position;
    #endif
    vec3 shadowPosition = toViewspace(shadowProjection, shadowModelView, positionMod).xyz;

    shadowPosition.xy = distortShadow(shadowPosition.xy);
    shadowPosition = shadowPosition * 0.5 + 0.5;

    return smoothstep(shadowPosition.z - EPSILON, shadowPosition.z, texture(shadowtex, shadowPosition.xy).r);
}