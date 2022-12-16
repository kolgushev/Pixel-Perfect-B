#include "/lib/distortion.glsl"

float shadowSample(in vec3 positionViewSpace, in sampler2D shadowtex) {
    vec3 shadowPosition = positionViewSpace;
    
    shadowPosition.xy = distortShadow(shadowPosition.xy);
    shadowPosition = shadowPosition * 0.5 + 0.5;
    
    shadowPosition.xy = supersampleSampleShift(shadowPosition.xy);

    return shadowPosition.z - texture(shadowtex, shadowPosition.xy).r;
}

float getShadow(in vec3 position, in mat4 shadowProjection, in mat4 shadowModelView, in vec2 texcoord, in sampler2D shadowtex, in sampler2D noisetex, in float lightmapLight, in int time) {
    // check difference between backface and non-backface rendered
    
    #if defined TEX_RENDER
        vec3 positionMod = position;
    #else
        vec3 positionMod = position;
    #endif


    float skyTransition = abs(fma(skyTime(time), 2, -1));
    float dist = length(positionMod);
    float shadowCutoff = clamp(fma(dist / (shadowDistance * SHADOW_CUTOFF), 10, -9), 0, 1);

    float shadowMask = skyTransition * (1 - shadowCutoff);

    vec3 shadowPosition = toViewspace(shadowProjection, shadowModelView, positionMod).xyz;

    #if SHADOW_FILTERING == 0
        float shadow = shadowSample(shadowPosition, shadowtex);
        shadow = step(shadow, EPSILON);
    #elif SHADOW_FILTERING == 1
        float shadowAverage = 0;
        vec3 shadowOffset;
        vec2 noise;

        for(int i = 0; i < SHADOW_FILTERING_SAMPLES; i++) {
            noise = sampleNoise(texcoord, i).rg * 2 - 1;

            shadowOffset = vec3(noise, 0) / shadowDistance * 0.05;

            shadowAverage += step(shadowSample(shadowPosition + shadowOffset, shadowtex), EPSILON);
        }

        float shadow = shadowAverage / SHADOW_FILTERING_SAMPLES;
    #endif


    shadow = mix(1, shadow, shadowMask);

    #if defined SHADOW_AFFECTED_BY_LIGHTMAP
        shadow *= lightmapLight;
    #endif
    
    return shadow;
}