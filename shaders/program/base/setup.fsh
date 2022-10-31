#include "/lib/common_defs.glsl"
#include "/program/base/configure_buffers.fsh"

uniform float far;
uniform mat4 gbufferProjectionInverse;
uniform float alphaTestRef;

#include "/program/base/samplers.fsh"
uniform sampler2D texture;

in float currentSkyWhitePoint;

in vec3 position;
in vec3 light;
in vec4 color;
in vec3 normal;
in vec4 masks;
in vec3 velocity;

#include "/lib/tonemapping.glsl"
#include "/lib/to_viewspace.glsl"