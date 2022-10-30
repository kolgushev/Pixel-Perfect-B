// post-GI filter

#define filter_pass_post

#include "/lib/common_defs.glsl"
#include "/program/base/configure_buffers.fsh"

uniform int frameCounter;
uniform float frameTimeCounter;

uniform float near;
uniform float far;

uniform float aspectRatio; 

#include "/program/base/samplers.fsh"
uniform sampler2D noisetex;

#include "/lib/denoise.glsl"

void main() {
    #define WRITE_GENERIC2
    #define WRITE_GENERIC3
    #include "/program/base/passthrough_1.fsh"
    #ifdef DENOISE
        if(renderable != 0) {
            float avg = (viewWidth + viewHeight) * 0.5;
            generic3.rgb = squareBlur(texcoord, colortex7, colortex3, clamp(sqrt(texelSurfaceArea) * avg * DENOISE_MULT, 0f, MAX_COMPLETE_SAMPLE_DIAMETER), false).rgb;
            generic2.gba = squareBlur(texcoord, colortex6, colortex3, clamp(sqrt(texelSurfaceArea) * avg * DENOISE_MULT, 0f, MAX_COMPLETE_SAMPLE_DIAMETER), false).gba;
        }
    #endif
    #include "/program/base/passthrough_2.fsh"
}