#include "/common_defs.glsl"

in vec3 vaPosition;
in vec2 vaUV0;
in vec3 vaNormal;
in vec2 mc_Entity;

out vec2 texcoord;
out vec3 position;
out vec3 normal;

#define use_projection_matrix
#define use_model_view_matrix
#define use_shadow_model_view_inverse
#define use_frame_counter
#define use_chunk_offset

#define use_to_viewspace
#define use_distortion

#define use_frame_counter

#define use_to_viewspace
#define use_distortion

#include "/lib/use.glsl"

void main() {
    #if defined SHADOWS_ENABLED
        #if defined GRASS_CASTS_SHADOWS
            #define IS_WAVY false
        #else
            #define IS_WAVY (mc_Entity.x == WAVING_CUTOUTS_LOW || mc_Entity.x == WAVING_CUTOUTS_BOTTOM || mc_Entity.x == WAVING_CUTOUTS_TOP || mc_Entity.x == WAVING_CUTOUTS_BOTTOM_STIFF || mc_Entity.x == WAVING_CUTOUTS_TOP_STIFF || mc_Entity.x == WAVING_CUTOUTS_BOTTOM_LIT)
        #endif

        if(IS_WAVY) {
            gl_Position = vec4(0);
        } else {
            // check against position texture instead of depth
            texcoord = (vaUV0).xy;

            position = vaPosition + chunkOffset;
            normal = vaNormal;

            gl_Position = toViewspace(projectionMatrix, modelViewMatrix, position);
            
            gl_Position.xy = distortShadow(gl_Position.xy);
            gl_Position.xy = supersampleShift(gl_Position.xy, frameCounter);
            gl_Position.xy = supersampleSubpixelShift(gl_Position.xy, frameCounter);
        }
    #else
        gl_Position = vec4(0);
    #endif
}