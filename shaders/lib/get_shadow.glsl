#include "/lib/distortion.glsl"

float getShadow(in vec3 position, in mat4 shadowProjection, in mat4 shadowModelView, in sampler2D shadowtex, in float lightmapLight, in int time) {
    #if defined TEX_RENDER
        vec3 positionMod = position;
    #else
        vec3 positionMod = position;
    #endif
    vec3 shadowPosition = toViewspace(shadowProjection, shadowModelView, positionMod).xyz;

    float shadowCutoff = clamp(fma(length(shadowPosition.xy) * SHADOW_CUTOFF, 7, -6), 0, 1);

    shadowPosition.xy = distortShadow(shadowPosition.xy);
    shadowPosition = shadowPosition * 0.5 + 0.5;

    // float shadow = smoothstep(shadowPosition.z - EPSILON, shadowPosition.z, texture(shadowtex, shadowPosition.xy).r);
    float shadow = step(shadowPosition.z - EPSILON, texture(shadowtex, shadowPosition.xy).r);
    
    shadow = mix(shadow, 1, shadowCutoff);

    float skyTransition = skyTime(time);
    float shadowDimmed = shadow * abs(fma(skyTransition, 2, -1));

    return shadowDimmed;
}