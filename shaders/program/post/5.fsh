// post-GI filter

#define exposure_pass

#include "/lib/common_defs.glsl"
#include "/program/base/configure_buffers.fsh"

uniform int frameCounter;
uniform float frameTimeCounter;

uniform float aspectRatio; 

#include "/program/base/samplers.fsh"
uniform sampler2D noisetex; 

void main() {
    #define READ_GENERIC
    #define OVERRIDE_GENERIC

    #define WRITE_GENERIC2
    
    #define WRITE_GENERIC3
    #include "/program/base/passthrough_1.fsh"

    #if defined AUTO_EXPOSE || defined DEBUG_VIEW
        if(renderable != 0) {
            vec2 pixelSize = 0.5 / vec2(viewWidth, viewHeight);
            generic3.a = texture(colortex7, pixelSize).a;

            // albedo = opaque(getNoise(NOISETEX_RES, 0, 1).rgb);
            // albedo = opaque1(hand(texture(depthtex0, texcoordMod).r));
        }

        // store linear depth for next frame deghosting
        generic2.r = length(generic.rgb);
    #endif

    #include "/program/base/passthrough_2.fsh"
}