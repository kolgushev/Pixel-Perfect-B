#define g_vsh
#include "/common_defs.glsl"

in vec3 vaPosition;
in vec2 vaUV0;
in vec3 vaNormal;
in vec2 mc_Entity;

out vec2 texcoord;
out vec3 position;
out vec3 normal;
out float dist;

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

            #if defined TAA_ENABLED && defined TAA_SHADOW_FIX && !defined NO_AA && IS_IRIS
                gl_Position = gbufferProjection * (gbufferModelView * vec4(position, 1.0));
                    
                // jitter
                gl_Position.xy -= temporalAAOffsets[frameCounter % TAA_OFFSET_LEN] * gl_Position.w / vec2(viewWidth, viewHeight);

                gl_Position = gbufferModelViewInverse * (gbufferProjectionInverse * gl_Position);
            #else
                gl_Position = vec4(position, 1.0);
            #endif


            gl_Position = toClipspace(projectionMatrix, modelViewMatrix, gl_Position.xyz);
            dist = length(gl_Position.xy);
            
            gl_Position.xy = distortShadow(gl_Position.xy);
        }
    #else
        gl_Position = vec4(0);
    #endif
}