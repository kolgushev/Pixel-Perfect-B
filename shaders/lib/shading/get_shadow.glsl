float shadowSample(in vec3 positionViewSpace, in sampler2D shadowtex) {
    vec3 shadowPosition = positionViewSpace;
    
    shadowPosition.xy = distortShadow(shadowPosition.xy);
    shadowPosition = shadowPosition * 0.5 + 0.5;
    
    shadowPosition.xy = supersampleSampleShift(shadowPosition.xy);

    return shadowPosition.z - texture(shadowtex, shadowPosition.xy).r;
}

float getShadow(in vec3 position, in vec3 absolutePosition, in mat4 shadowProjection, in mat4 shadowModelView, in vec2 texcoord, in sampler2D shadowtex, in float lightmapLight, in float skyTime) {
    // check difference between backface and non-backface rendered
    
    vec3 positionMod = position;

    float dist = length(positionMod);
    float shadowCutoff = smoothstep(0.9, 1.0, dist / (shadowDistance * SHADOW_CUTOFF));

    vec3 shadowPosition = toViewspace(shadowProjection, shadowModelView, positionMod).xyz;

    #if SHADOW_FILTERING == 0
        float shadow = shadowSample(shadowPosition, shadowtex);
        shadow = step(shadow, EPSILON);
    #elif SHADOW_FILTERING == 1
        float shadowAverage = 0;
        vec3 shadowOffset;
        vec3 noise;

        for(int i = 0; i < SHADOW_FILTERING_SAMPLES; i++) {
            vec2 sampleCoord = texcoord;

            int iMod = i;
            #if defined TAA_ENABLED
                iMod += frameCounter * SHADOW_FILTERING_SAMPLES;
            #endif

            #if PIXELATED_SHADOWS != 0
                sampleCoord = absolutePosition.xz + absolutePosition.y * 100;
            #endif

            noise = sampleNoise(sampleCoord * vec2(viewWidth, viewHeight), iMod, NOISE_BLUE_3D, true).rgb * 2 - 1;

            shadowOffset = noise / shadowDistance * 0.5 * SHADOW_FILTERING_RADIUS;

            float sampled = shadowSample(shadowPosition + shadowOffset, shadowtex);

            shadowAverage += step(sampled, EPSILON);
        }

        float shadow = shadowAverage / SHADOW_FILTERING_SAMPLES;
    #elif SHADOW_FILTERING == 4 || SHADOW_FILTERING == 5
        vec2 samplePositionWithinBounds = mod(shadowPosition.xy * shadowMapResolution, 1);

        shadowPosition.xy = floor(shadowPosition.xy * shadowMapResolution) / shadowMapResolution;

        float shadowSamples[4] = float[4](0, 0, 0, 0);

        for(int i = 0; i < 4; i++) {
            shadowSamples[i] = shadowSample(shadowPosition + vec3(superSampleOffsets4[i] / shadowMapResolution, 0), shadowtex);
            // shadowSamples[i] = shadowSample(shadowPosition, shadowtex);
            shadowSamples[i] = smoothstep(EPSILON, 0, shadowSamples[i]);
        }

        shadowSamples[0] = mix(shadowSamples[0], shadowSamples[1], samplePositionWithinBounds.y);
        shadowSamples[1] = mix(shadowSamples[2], shadowSamples[3], samplePositionWithinBounds.y);

        float shadow = mix(shadowSamples[0], shadowSamples[1], samplePositionWithinBounds.x);
    #endif

    shadow = mix(shadow, basicDirectShading(lightmapLight), shadowCutoff);
    shadow = mix(SHADOW_TRANSITION_MIXING, shadow, abs(clamp(skyTime * 8.0, -1.0, 1.0)));

    #if defined SHADOW_AFFECTED_BY_LIGHTMAP
        shadow *= lightmapLight;
    #endif
    
    return shadow;
}