vec4 toViewspace(in mat4 projectionMatrix, in mat4 modelViewMatrix, in vec3 position) {
    return projectionMatrix * mul_m4_v3(modelViewMatrix, position);
}

vec4 toForcedViewspace(in mat4 projectionMatrix, in mat4 modelViewMatrix, in vec3 position) {
    vec4 modelView = mul_m4_v3(modelViewMatrix, position);

    // modelView.zw *= pow(mix(length(position), abs(modelView.z), cos(frameTimeCounter) * 0.5 + 0.5), sin(frameTimeCounter) * 0.1);
    // modelView.zw *= pow(mix(length(position), abs(modelView.z), cos(frameTimeCounter) * 0.5 + 0.5), 0.3);

    modelView.zw *= pow(mix(length(position), abs(modelView.z), FORCED_PERSPECTIVE_SHAPE) * FORCED_PERSPECTIVE_BIAS, FORCED_PERSPECTIVE_POWER) / FORCED_PERSPECTIVE_BIAS;

    return projectionMatrix * modelView;
}

vec4 getViewSpace(in vec2 texcoord, in float depth, in mat4 projectionInverse) {
    vec3 clipSpace = vec3(texcoord, depth) * 2 - 1;    
    vec4 viewW = mul_m4_v3(projectionInverse, clipSpace);
    viewW.xyz /= viewW.w;
    return viewW;
    // return vec3(1);
}

vec4 getViewSpace(in vec2 texcoord, in float depth) {
    return getViewSpace(texcoord, depth, gbufferProjectionInverse);
}


vec3 getWorldSpace(in vec2 texcoord, in float depth, in mat4 projectionInverse) {
    return (gbufferModelViewInverse * vec4(getViewSpace(texcoord, depth, projectionInverse).xyz, 1.0)).xyz;
}

vec3 getWorldSpace(in vec2 texcoord, in float depth) {
    return getWorldSpace(texcoord, depth, gbufferProjectionInverse);
}
