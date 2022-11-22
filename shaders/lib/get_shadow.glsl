#include "/lib/distortion.glsl"

float getShadow(in vec3 position, in vec3 normal, in mat4 shadowProjection, in mat4 shadowModelView, in sampler2D shadowtex, in sampler2D shadowtexNormal, in float lightmapLight, in int time) {
    #if defined TEX_RENDER
        vec3 positionMod = position;
    #else
        vec3 positionMod = position;
    #endif
    float skyTransition = abs(fma(skyTime(time), 2, -1));
    float shadowCutoff = clamp(fma(length(positionMod) / (shadowDistance * SHADOW_CUTOFF), 10, -9), 0, 1);

    float shadowMask = skyTransition * (1 - shadowCutoff);

    vec3 shadowPosition = toViewspace(shadowProjection, shadowModelView, positionMod).xyz;

    shadowPosition.xy = distortShadow(shadowPosition.xy);
    shadowPosition = shadowPosition * 0.5 + 0.5;

    float shadow = step(shadowPosition.z, texture(shadowtex, shadowPosition.xy).r);
    
    shadow = mix(lightmapLight, shadow, shadowMask);
    
    return shadow;
}