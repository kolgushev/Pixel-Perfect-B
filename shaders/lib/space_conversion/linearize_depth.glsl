// credit to https://wiki.shaderlabs.org/wiki/Shader_tricks for the following function
vec3 depthToView(vec2 texCoord, float depth, mat4 projInv) {

    vec4 ndc = vec4(texCoord, depth, 1) * 2 - 1;

    vec4 viewPos = projInv * ndc;

    return viewPos.xyz / viewPos.w;

}