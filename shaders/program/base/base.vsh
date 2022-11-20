#include "/lib/common_defs.glsl"

out vec2 texcoord;
out vec4 color;
out vec3 position;

in vec2 vaUV0;
in vec4 vaColor;
in vec3 vaNormal;

in vec3 vaPosition;

uniform vec3 chunkOffset;

uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;

#include "/lib/to_viewspace.glsl"

void main() {
    position = chunkOffset + vaPosition;

    texcoord = vaUV0;
    color = vaColor;

    gl_Position = toViewspace(projectionMatrix, modelViewMatrix, position);
}