#include "/common_defs.glsl"

out vec2 texcoord;
out vec3 position;
out vec3 normal;

uniform int frameCounter;

#define use_to_viewspace
#define use_distortion

#include "/lib/use.glsl"

void main() {
    #if defined SHADOWS_ENABLED
        // check against position texture instead of depth
        texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;

        position = gl_Vertex.xyz;
        normal = gl_Normal;

        // if within range
        // xz / range
        // xz / sqrt(# layers)
        // start.x = y % sqrt(# layers)
        // start.z = floor(y / sqrt(# layers))

        // xz += start

        // float range = 10;
        // float sqrtNumLayers = 10;
        // // position.xz = distance(position.xz, vec2(0)) < range ? position.xz / range : vec2(0);
        // position.xz = position.xz / range;
        // position.xz /= sqrtNumLayers;

        // vec2 startPos = vec2(0);
        // startPos.x = int(position.y) % int(sqrtNumLayers);
        // startPos.y = floor(position.y / sqrtNumLayers);

        // position.xz += startPos;

        // position.xyz = position.xzy;

        // gl_Position = vec4(position, 1.0);

        gl_Position = toViewspace(gl_ProjectionMatrix, gl_ModelViewMatrix, position);
        
        gl_Position.xy = distortShadow(gl_Position.xy);
        gl_Position.xy = supersampleShift(gl_Position.xy, frameCounter);
        gl_Position.xy = supersampleSubpixelShift(gl_Position.xy, frameCounter);
    #else
        gl_Position = vec4(0);
    #endif
}