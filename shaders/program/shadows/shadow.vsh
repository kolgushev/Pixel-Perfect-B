#include "/lib/common_defs.glsl"

out vec2 texcoord;
out vec3 position;

in vec3 vaPosition;

uniform vec3 chunkOffset;

uniform mat4 shadowProjection;
uniform mat4 shadowModelView;

#include "/lib/to_viewspace.glsl"
#include "/lib/distortion.glsl"

void main() {
    position = chunkOffset + vaPosition;


    gl_Position = toViewspace(shadowProjection, shadowModelView, position);
    gl_Position.xy = distortShadow(gl_Position.xy);
}