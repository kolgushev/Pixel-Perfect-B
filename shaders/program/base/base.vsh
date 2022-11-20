#include "/lib/common_defs.glsl"

out vec2 texcoord;
out vec4 color;
out vec2 light;
out vec3 position;
out vec3 normal;

in vec2 vaUV0;
in ivec2 vaUV2;
in vec4 vaColor;
in vec3 vaNormal;
in vec3 vaPosition;

#if defined gc_terrain
    in vec4 mc_Entity;
#endif

uniform vec3 chunkOffset;

uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;

#if !defined gc_terrain
    uniform mat4 gbufferModelViewInverse;
#endif

#include "/lib/to_viewspace.glsl"

void main() {
    #if defined gc_terrain || defined gc_sky
        position = chunkOffset + vaPosition;
        gl_Position = toViewspace(projectionMatrix, modelViewMatrix, position);
    #else
        position = viewInverse(vaPosition);
        gl_Position = toViewspace(projectionMatrix, modelViewMatrix, vaPosition);
    #endif

    texcoord = vaUV0;
    color = vaColor;
    light = (LIGHT_MATRIX * vec4(vaUV2, 1, 1)).xy;
    light = max(vec2(light.rg) - 0.0313, 0);
    #if defined gc_terrain || defined gc_textured
        normal = vaNormal;
    #else
        normal = viewInverse(vaNormal);
    #endif

}