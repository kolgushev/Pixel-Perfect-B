
#define g_vsh
#include "/common_defs.glsl"

attribute vec3 vaPosition;
attribute vec2 vaUV0;
attribute vec3 vaNormal;
attribute vec2 mc_Entity;

varying vec2 texcoord;
varying vec3 position;
varying vec3 normal;


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
        }
    #else
        gl_Position = vec4(0);
    #endif
}