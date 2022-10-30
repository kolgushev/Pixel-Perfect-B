#define lighting_pass

#include "/lib/common_defs.glsl"
#include "/program/base/configure_buffers.fsh"

uniform int frameCounter;
uniform float frameTimeCounter;

uniform float near;
uniform float far;

uniform float aspectRatio;

uniform sampler2D noisetex;

uniform mat4 modelViewMatrix;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;

#include "/program/base/samplers.fsh"

#include "/lib/get_noise.fsh"

#include "/lib/to_viewspace.glsl"

#include "/lib/bounce.glsl"

void main() {
    #include "/program/base/passthrough_1.fsh"

    

    #include "/program/base/passthrough_2.fsh"
}