// post-GI filter

#define exposure_pass

#include "/lib/common_defs.glsl"

layout(location = 6) out vec4 buffer6;
layout(location = 7) out vec4 buffer7;

uniform int frameCounter;
uniform float frameTimeCounter;

uniform float aspectRatio; 

in vec2 texcoord;
uniform sampler2D colortex5;

uniform sampler2D noisetex; 

void main() {
    vec4 generic = texture(colortex5, texcoord);

    #if defined AUTO_EXPOSE || defined DEBUG_VIEW
        if(renderable != 0) {
            vec2 pixelSize = 0.5 / vec2(viewWidth, viewHeight);
            buffer7.a = texture(colortex7, pixelSize).a;

            // albedo = opaque(getNoise(NOISETEX_RES, 0, 1).rgb);
            // albedo = opaque1(hand(texture(depthtex0, texcoordMod).r));
        }

        // store linear depth for next frame deghosting
        buffer6.r = length(generic.rgb);
    #endif
}