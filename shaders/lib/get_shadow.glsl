#include "/lib/distortion.glsl"

float getShadow(in vec3 position, in vec3 normal, in mat4 shadowProjection, in mat4 shadowModelView, in sampler2D shadowtex, in sampler2D shadowtexNormal, in float lightmapLight, in int time) {
    // check difference between backface and non-backface rendered
    
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


    // TODO: find log base for glsl
    float shadow = step(shadowPosition.z - EPSILON_SMALLEST * log(fma(length(position), 1.0, 1.0)), texture(shadowtex, shadowPosition.xy).r);
    
    shadow = mix(1, shadow, shadowMask) * lightmapLight;
    
    return shadow;
}