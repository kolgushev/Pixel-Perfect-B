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
    #if defined SHADOWS_ENABLED && defined DH_SHADOWS_ENABLED
        texcoord = (vaUV0).xy;

        position = vaPosition + chunkOffset;
        normal = vaNormal;

        #if defined TAA_ENABLED && defined TAA_SHADOW_FIX && !defined NO_AA && IS_IRIS
            gl_Position = gbufferProjection * (gbufferModelView * vec4(position, 1.0));

            // jitter
            gl_Position.xy -= temporalAAOffsets[frameCounter % TAA_OFFSET_LEN] * gl_Position.w / vec2(viewWidth, viewHeight);

            gl_Position = gbufferModelViewInverse * (gbufferProjectionInverse * gl_Position);
        #else
            gl_Position = vec4(position, 1.0);
        #endif


        gl_Position = toClipspace(projectionMatrix, modelViewMatrix, gl_Position.xyz);
        
        gl_Position.xy = distortShadow(gl_Position.xy);
    #else
        gl_Position = vec4(0);
    #endif
}