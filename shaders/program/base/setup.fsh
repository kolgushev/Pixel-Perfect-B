#include "/lib/common_defs.glsl"

layout(location = 0) out vec4 buffer0;
layout(location = 1) out vec4 buffer1;
layout(location = 2) out vec4 buffer2;
layout(location = 3) out vec4 buffer3;
layout(location = 4) out vec4 buffer4;
layout(location = 5) out vec4 buffer5;
layout(location = 6) out vec4 buffer6;

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