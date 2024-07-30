// returns signed distance between position and closest surface to the sun on the ray from sun to position
float shadowSample(in vec3 position) {
    vec3 shadowPosition = position;
    
    shadowPosition.xy = distortShadow(shadowPosition.xy);
    shadowPosition = shadowPosition * 0.5 + 0.5;
    
    shadowPosition.xy = supersampleSampleShift(shadowPosition.xy);

    vec3 shadowSurface = vec3(shadowPosition.xy, texture(shadowtex0, shadowPosition.xy).r);
    float shadowDiff = shadowSurface.z - shadowPosition.z;

    return distance((shadowProjectionInverse * vec4(shadowPosition * 2.0 - 1.0, 1.0)).xyz, 
                    (shadowProjectionInverse * vec4(shadowSurface * 2.0 - 1.0, 1.0)).xyz) * sign(shadowDiff);
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

float getShadow(in vec3 position, in vec3 normal, in mat3 TBN, in vec3 shadowLightPosition, in vec4 noise, in float lightmapLight, in float skyTime, in float subsurface) {
    vec3 shadowLightPos = normalize(shadowLightPosition);
    float shadowCutoff = smoothstep(0.9, 1.0, length(position) / (shadowDistance * SHADOW_CUTOFF));
    float basicShading = basicDirectShading(skyTime);
    if(
        dot(normal, shadowLightPos) < -SHADOW_NORMAL_MIX_THRESHOLD
        #if defined DO_SUBSURFACE
            && subsurface < EPSILON_2
        #endif
        || shadowCutoff > 1.0 - EPSILON
    ) {
        return basicShading;
    } else {
        float shadow = 0.0;

        vec3 shadowPosition = toClipspace(shadowProjection, shadowModelView, position).xyz;

        shadow = shadowSample(shadowPosition);
        shadow = shadowStep(shadow, subsurface, normal, shadowLightPosition);

        #if defined SHADOW_AFFECTED_BY_LIGHTMAP
            shadow *= lightmapLight;
        #endif

        shadow = mix(basicShading, shadow, smoothstep(-SHADOW_NORMAL_MIX_THRESHOLD, 0.0, dot(normal, shadowLightPos)));
        shadow = mix(shadow, basicShading, shadowCutoff);

        return shadow;
    }
}