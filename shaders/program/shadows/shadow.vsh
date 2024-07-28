#define g_vsh
#include "/common_defs.glsl"

in vec3 vaPosition;
in vec2 vaUV0;
in vec3 vaNormal;
in vec2 mc_Entity;

out vec2 texcoord;
out vec3 position;
out vec3 normal;


#include "/lib/use.glsl"

void main() {
    #if defined SHADOWS_ENABLED
        #if defined GRASS_CASTS_SHADOWS
            #define IS_WAVY false
        #else
            #define IS_WAVY (isBlockWavy(mc_Entity.x))
        #endif

        if(IS_WAVY) {
            gl_Position = vec4(0);
        } else {
            // check against position texture instead of depth
            texcoord = (vaUV0).xy;

            position = vaPosition + chunkOffset;
            normal = vaNormal;

            gl_Position = toClipspace(projectionMatrix, modelViewMatrix, position);
            
            gl_Position.xy = distortShadow(gl_Position.xy);
            gl_Position.xy = supersampleShift(gl_Position.xy, frameCounter);
            gl_Position.xy = supersampleSubpixelShift(gl_Position.xy, frameCounter);
        }
    #else
        gl_Position = vec4(0);
    #endif
}