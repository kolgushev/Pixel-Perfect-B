#include "/common_defs.glsl"

out vec2 texcoord;
out vec3 position;
out vec3 normal;

in vec2 vaUV0;
in vec3 vaPosition;
in vec3 vaNormal;

uniform vec3 chunkOffset;

uniform mat4 projectionMatrix;
uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrixInverse;
uniform mat4 modelViewMatrixInverse;

uniform mat4 shadowModelViewInverse;

uniform int frameCounter;

#include "/lib/to_viewspace.glsl"
#include "/lib/distortion.glsl"

void main() {
    #if defined SHADOWS_ENABLED
        // check against position texture instead of depth
        texcoord = vaUV0;

        position = chunkOffset + vaPosition;
        normal = vaNormal;

        // if within range
        // xz / range
        // xz / sqrt(# layers)
        // start.x = y % sqrt(# layers)
        // start.z = floor(y / sqrt(# layers))

        // xz += start

        gl_Position = vec4(position, 1.0);

        // gl_Position = toViewspace(projectionMatrix, modelViewMatrix, position);
        
        // gl_Position.xy = distortShadow(gl_Position.xy);
        // gl_Position.xy = supersampleShift(gl_Position.xy, frameCounter);
        // gl_Position.xy = supersampleSubpixelShift(gl_Position.xy, frameCounter);
    #else
        gl_Position = vec4(0);
    #endif
}