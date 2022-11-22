vec4 toViewspace(in mat4 projectionMatrix, in mat4 modelViewMatrix, in vec3 position) {
    return projectionMatrix * mul_m4_v3(modelViewMatrix, position);
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