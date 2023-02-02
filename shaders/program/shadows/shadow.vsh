#include "/common_defs.glsl"

out vec2 texcoordV;
out vec3 positionV;
out vec3 normalV;

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
        texcoordV = vaUV0;

        normalV = vaNormal;
        // subtract normals to move full block face centers away from block edge and towards block center
        positionV = floor(chunkOffset) + vaPosition - normalV * 0.1;

        // if within range
        // xz / range
        // xz / sqrt(# layers)
        // start.x = y % sqrt(# layers)
        // start.z = floor(y / sqrt(# layers))

        // xz += start

        gl_Position = vec4(positionV, 1.0);

        // gl_Position = toViewspace(projectionMatrix, modelViewMatrix, positionV);
        
        // gl_Position.xy = distortShadow(gl_Position.xy);
        // gl_Position.xy = supersampleShift(gl_Position.xy, frameCounter);
        // gl_Position.xy = supersampleSubpixelShift(gl_Position.xy, frameCounter);
    #else
        gl_Position = vec4(0);
    #endif
}