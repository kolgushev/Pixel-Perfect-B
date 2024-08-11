// returns signed distance between position and closest surface to the sun on the ray from sun to position
float shadowSample(in vec3 position) {
    vec3 shadowPosition = position;
    
    shadowPosition.xy = distortShadow(shadowPosition.xy);
    shadowPosition = shadowPosition * 0.5 + 0.5;
    
    vec3 shadowSurface = vec3(shadowPosition.xy, texture(shadowtex0, shadowPosition.xy).r);
    float shadowDiff = shadowSurface.z - shadowPosition.z;

    return distance((shadowProjectionInverse * vec4(shadowPosition * 2.0 - 1.0, 1.0)).xyz, 
                    (shadowProjectionInverse * vec4(shadowSurface * 2.0 - 1.0, 1.0)).xyz) * sign(shadowDiff);
}

float shadowStep(in float len, in float subsurface, in float factor) {
    float sharpShadow = smoothstep(0.0, EPSILON, len);
    #if defined DO_SUBSURFACE
        float smoothShadow = smoothstep(0.1 - SQRT_3, 0.0, len);
        return mix(subsurface < EPSILON ? 0.0 : smoothShadow * smoothShadow, sharpShadow, factor);
    #else
        return mix(0.0, sharpShadow, factor);
    #endif
}

float getShadow(in vec3 position, in vec3 normal, in mat3 TBN, in vec2 screenPos, in vec3 shadowLightPosition, in float lightmapLight, in float skyTime, in float subsurface) {
    vec3 shadowLightPos = normalize(shadowLightPosition);
    float shadowCutoff = smoothstep(0.9, 1.0, length(position) / (shadowDistance * SHADOW_CUTOFF));
    float basicShading = basicDirectShading(skyTime);
    float NdotL = dot(normal, shadowLightPos);
    bool isUnlit = NdotL < -SHADOW_NORMAL_MIX_THRESHOLD;
    bool isSubsurf = subsurface > EPSILON;

    if(
        isUnlit
        #if defined DO_SUBSURFACE
            && !isSubsurf
        #endif
        || shadowCutoff > 1.0 - EPSILON
    ) {
        return isUnlit ? 0.0 : basicShading;
    } else {
        float shadow = 0.0;

        // extend position out a bit to account for shadow resolution inaccuracies
        // TODO: Calculate the extension amount analytically
        vec3 shadowPosition = position + normal * 0.1;

        float factor = smoothstep(-SHADOW_NORMAL_MIX_THRESHOLD, 0.0, NdotL);

        #if SHADOW_FILTERING == FILTERING_NONE
            shadowPosition = toClipspace(shadowProjection, shadowModelView, shadowPosition).xyz;
            shadow = shadowSample(shadowPosition);
            shadow = shadowStep(shadow, subsurface, factor);
        #else
            #if SHADOW_FILTERING == FILTERING_VPSS_CHEAP
                // determine dist from current position to position of shadow caster
                shadow = shadowSample(shadowPosition);
            #endif

            float radius = SHADOW_FILTERING_RADIUS;
            vec3 noise = vec3(0.0);

            #if SHADOW_FILTERING == FILTERING_PCF && defined DO_SUBSURFACE
                if(isSubsurf && isUnlit) {
                    radius = subsurface;
                }
            #elif SHADOW_FILTERING == FILTERING_BILINEAR
                if(isSubsurf && isUnlit) {
                    radius = subsurface;
            #endif
                vec3 offset;
                vec3 worldOffset;
                vec3 samplePos;
                float sampleShadow;
                // Generate sample positions in tangent space using blue noise
                for (int i = 0; i < SHADOW_FILTERING_SAMPLES; i++) {
                    noise = tile(screenPos + i * (113.0 - EPSILON) + randomVec.xy * 256.0, NOISE_BLUE_3D, true).xyz;

                    if(isSubsurf) {
                        offset = radius * (noise * 2.0 - 1.0);
                    } else {
                        offset = radius * vec3(noise.xy * 2.0 - 1.0, 0.0);
                    }

                    // transform offset to world space using TBN matrix
                    worldOffset = TBN * offset;
                    
                    // apply offset to shadow position
                    samplePos = shadowPosition + worldOffset;

                    samplePos = toClipspace(shadowProjection, shadowModelView, samplePos).xyz;
                    sampleShadow = shadowStep(shadowSample(samplePos), subsurface, factor);

                    shadow += sampleShadow;
                }

                shadow *= 1.0 / float(SHADOW_FILTERING_SAMPLES);
            #if SHADOW_FILTERING == FILTERING_BILINEAR
                } else {
                    shadowPosition = toClipspace(shadowProjection, shadowModelView, shadowPosition).xyz;
                    vec2 samplePositionWithinBounds = mod(shadowPosition.xy * shadowMapResolution, 1);

                    shadowPosition.xy = floor(shadowPosition.xy * shadowMapResolution) / shadowMapResolution;

                    float shadowSamples[4];

                    for(int i = 0; i < 4; i++) {
                        vec3 samplePos = shadowPosition + vec3(superSampleOffsets4[i] / shadowMapResolution, 0.0);
                        shadowSamples[i] = shadowSample(samplePos);
                        shadowSamples[i] = shadowStep(shadowSamples[i], subsurface, factor);
                    }

                    shadowSamples[0] = mix(shadowSamples[0], shadowSamples[1], samplePositionWithinBounds.y);
                    shadowSamples[1] = mix(shadowSamples[2], shadowSamples[3], samplePositionWithinBounds.y);

                    shadow = mix(shadowSamples[0], shadowSamples[1], samplePositionWithinBounds.x);
                }
            #endif

        #endif

        #if defined SHADOW_AFFECTED_BY_LIGHTMAP
            shadow *= lightmapLight;
        #endif

        shadow = mix(shadow, basicShading, shadowCutoff);

        return shadow;
    }
}