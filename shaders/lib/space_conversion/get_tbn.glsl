// Thanks to https://shaderlabs.org/wiki/Shader_Tricks
mat3 getTBN(vec3 normal, vec4 tangent) {
    // Left in DirectX format since that's what texturepack normals use
    vec3 bitangent = cross(normal, tangent.xyz) * tangent.w;
    return mat3(tangent.xyz, bitangent, normal);
}