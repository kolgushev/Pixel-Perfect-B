vec4 toViewspace(in mat4 projectionMatrix, in mat4 modelViewMatrix, in vec3 position) {
    return projectionMatrix * mul_m4_v3(modelViewMatrix, position);
}

vec4 toForcedViewspace(in mat4 projectionMatrix, in mat4 modelViewMatrix, in vec3 position, in float frameTimeCounter) {
    vec4 modelView = mul_m4_v3(modelViewMatrix, position);

    // modelView.zw *= pow(mix(length(position), abs(modelView.z), cos(frameTimeCounter) * 0.5 + 0.5), sin(frameTimeCounter) * 0.1);
    // modelView.zw *= pow(mix(length(position), abs(modelView.z), cos(frameTimeCounter) * 0.5 + 0.5), 0.3);

    modelView.zw *= pow(mix(length(position), abs(modelView.z), FORCED_PERSPECTIVE_SHAPE) * FORCED_PERSPECTIVE_BIAS, FORCED_PERSPECTIVE_POWER) / FORCED_PERSPECTIVE_BIAS;

    return projectionMatrix * modelView;
}

vec4 getViewSpace(in mat4 gbufferProjectionInverse, in vec2 texcoord, in float depth) {
    vec3 clipSpace = vec3(texcoord, depth) * 2 - 1;    
    vec4 viewW = mul_m4_v3(gbufferProjectionInverse, clipSpace);
    viewW.xyz /= viewW.w;
    return viewW;
    // return vec3(1);
}

vec4 getWorldSpace(in mat4 gbufferProjectionInverse, in mat4 gbufferModelViewInverse, in vec2 texcoord, in float depth) {
    return gbufferModelViewInverse * getViewSpace(gbufferProjectionInverse, texcoord, depth);
}