float shadowSample(in vec3 positionClipSpace, in sampler2D shadowtex) {
    vec3 shadowPosition = positionClipSpace;
    
    shadowPosition.xy = distortShadow(shadowPosition.xy);
    shadowPosition = shadowPosition * 0.5 + 0.5;
    
    shadowPosition.xy = supersampleSampleShift(shadowPosition.xy);

    vec3 shadowSurface = vec3(shadowPosition.xy, texture(shadowtex, shadowPosition.xy).r);
    float shadowDiff = shadowSurface.z - shadowPosition.z;

    return distance((shadowProjectionInverse * vec4(shadowPosition * 2.0 - 1.0, 1.0)).xyz, (shadowProjectionInverse * vec4(shadowSurface * 2.0 - 1.0, 1.0)).xyz) * sign(shadowDiff);
}

float shadowStep(in float len, in float subsurface, in vec3 normal, in vec3 shadowLightPosition) {
    #if defined DO_SUBSURFACE
        float sharpShadow = step(-0.1, len);
        if(dot(normal, shadowLightPosition) < 0.0) {
            float smoothShadow = smoothstep(-SQRT_3, -0.1, len);
            return smoothShadow * smoothShadow;
        } else {
            return sharpShadow;
        }
    #else
        return step(-0.1, len);
    #endif
}

float getShadow(in vec3 position, in vec3 normal, in vec3 shadowLightPosition, in vec3 absolutePosition, in mat4 shadowProjection, in mat4 shadowModelView, in vec2 texcoord, in sampler2D shadowtex, in float lightmapLight, in float skyTime, in float subsurface) {
    #if defined DO_SUBSURFACE
        if(dot(normal, shadowLightPosition) < 0.0 && subsurface < EPSILON) {
    #else
        if(dot(normal, shadowLightPosition) < 0.0) {
    #endif
        return 0.0;
    } else {
        vec3 positionMod = position;

        float dist = length(positionMod);
        float shadowCutoff = smoothstep(0.9, 1.0, dist / (shadowDistance * SHADOW_CUTOFF));

        vec3 shadowPosition = toClipspace(shadowProjection, shadowModelView, positionMod).xyz;

        float shadow = 0.0;
        if(shadowCutoff < 1.0) {
            #if SHADOW_FILTERING == 0
                shadow = shadowSample(shadowPosition, shadowtex);
                shadow = shadowStep(shadow, subsurface, normal, shadowLightPosition);
            #elif SHADOW_FILTERING == 1
                float shadowAverage = 0.0;
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

                    noise = sampleNoise(sampleCoord, iMod, NOISE_BLUE_3D, true).rgb * 2 - 1;

                    shadowOffset = noise / shadowDistance * 0.5 * mix(SHADOW_FILTERING_RADIUS, 1.0, subsurface);

                    float sampled = shadowSample(shadowPosition + shadowOffset, shadowtex);

                    shadowAverage += shadowStep(sampled, subsurface, normal, shadowLightPosition);
                }

                shadow = shadowAverage / SHADOW_FILTERING_SAMPLES;
            #elif SHADOW_FILTERING == 4 || SHADOW_FILTERING == 5
                vec2 samplePositionWithinBounds = mod(shadowPosition.xy * shadowMapResolution, 1);

                shadowPosition.xy = floor(shadowPosition.xy * shadowMapResolution) / shadowMapResolution;

                float shadowSamples[4] = float[4](0, 0, 0, 0);

                for(int i = 0; i < 4; i++) {
                    shadowSamples[i] = shadowSample(shadowPosition + vec3(superSampleOffsets4[i] / shadowMapResolution, 0.0), shadowtex);

                    shadowSamples[i] = shadowStep(shadowSamples[i], subsurface, normal, shadowLightPosition);
                }

                shadowSamples[0] = mix(shadowSamples[0], shadowSamples[1], samplePositionWithinBounds.y);
                shadowSamples[1] = mix(shadowSamples[2], shadowSamples[3], samplePositionWithinBounds.y);

                shadow = mix(shadowSamples[0], shadowSamples[1], samplePositionWithinBounds.x);
            #endif
        }

        shadow = mix(shadow, basicDirectShading(lightmapLight), shadowCutoff);

        #if defined SHADOW_AFFECTED_BY_LIGHTMAP
            shadow *= lightmapLight;
        #endif
        
        return shadow;
    }
}