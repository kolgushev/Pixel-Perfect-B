// SSAO

#define filter_pass_pre

#include "/lib/common_defs.glsl"
#include "/program/base/configure_buffers.fsh"

uniform int frameCounter;
uniform float frameTimeCounter;

uniform float near;
uniform float far;

#include "/program/base/samplers.fsh"

#include "/lib/linearize_depth.fsh"

void main() {
    #define WRITE_COORD
    #include "/program/base/passthrough_1_unalign.fsh"

    #if defined TEX_RENDER || defined DEBUG_VIEW

        /* fill texpix in position and rendermap */

        // check for whether the texel is targeting an unrenderable pixel
        float renderableAtTarget = texture(colortex3, coord.rg).b;
        if(renderableAtTarget != 1) {
            renderable = 0.5;
            texcoordMod = texcoord;
        } else {
            texcoordMod = coord.rg;
        }
    #endif
    
	#include "/program/base/passthrough_2.fsh"
}