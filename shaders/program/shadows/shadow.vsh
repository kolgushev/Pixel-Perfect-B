#include "/common_defs.glsl"

out vec2 texcoordV;
out vec3 positionV;
out vec3 normalV;

uniform mat4 shadowModelViewInverse;

uniform int frameCounter;

#include "/lib/to_viewspace.glsl"
#include "/lib/distortion.glsl"

void main() {
    #if defined SHADOWS_ENABLED
        // check against position texture instead of depth
        texcoordV = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;

        positionV = gl_Vertex.xyz;
        normalV = gl_Normal;

        // if within range
        // xz / range
        // xz / sqrt(# layers)
        // start.x = y % sqrt(# layers)
        // start.z = floor(y / sqrt(# layers))

        // xz += start

        gl_Position = vec4(positionV, 1.0);

        // vec2 startPos = vec2(0);
        // startPos.x = int(position.y) % int(sqrtNumLayers);
        // startPos.y = floor(position.y / sqrtNumLayers);

        // position.xz += startPos;

        // position.xyz = position.xzy;

        // gl_Position = vec4(position, 1.0);

        gl_Position = toViewspace(gl_ProjectionMatrix, gl_ModelViewMatrix, positionV);
        
        // gl_Position.xy = distortShadow(gl_Position.xy);
        // gl_Position.xy = supersampleShift(gl_Position.xy, frameCounter);
        // gl_Position.xy = supersampleSubpixelShift(gl_Position.xy, frameCounter);
    #else
        gl_Position = vec4(0);
    #endif
}