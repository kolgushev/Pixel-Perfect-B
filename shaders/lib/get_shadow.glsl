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

    #if FILTER_SHADOWS > 0
        float shadowOffset = SHADOW_FILTER_OFFSET / float(shadowMapResolution);

        vec2 shadowSampleOffsets[SHADOW_FILTER_SAMPLES] = vec2[SHADOW_FILTER_SAMPLES](
            #if FILTER_SHADOWS == 1 || FILTER_SHADOWS == 3
                vec2(shadowOffset, 0),
                vec2(-shadowOffset, 0),
                vec2(0, shadowOffset),
                vec2(0, -shadowOffset),
            #endif
            #if FILTER_SHADOWS == 1 || FILTER_SHADOWS == 2
                vec2(shadowOffset, -shadowOffset),
                vec2(-shadowOffset, -shadowOffset),
                vec2(shadowOffset, shadowOffset),
                vec2(shadowOffset, -shadowOffset),
            #endif

            vec2(0, 0) // placeholder to allow trailing commas
        );

        float finalShadowSample = texture(shadowtex, shadowPosition.xy).r;
        for(int i = 1; i < shadowSampleOffsets.length; i++) {
            finalShadowSample = min(finalShadowSample, texture(shadowtex, shadowPosition.xy + shadowSampleOffsets[i]).r);
        }
    #else
        float finalShadowSample = texture(shadowtex, shadowPosition.xy).r;
    #endif

    float shadow = step(shadowPosition.z, finalShadowSample);
    
    shadow = mix(lightmapLight, shadow, shadowMask);
    
    return shadow;
}