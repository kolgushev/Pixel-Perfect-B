// process lighting
#define lighting_pass

#include "/lib/common_defs.glsl"

// Direction of the sun (not normalized!)
uniform vec3 sunPosition;
uniform vec3 moonPosition;

uniform int worldTime;
uniform int moonPhase;
uniform float rainStrength; 

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;

const float sunPathRotation = -20;

#include "/program/base/samplers_vsh.vsh"

in vec3 vaPosition;
in vec4 vaColor;
in vec3 vaNormal;
in vec2 vaUV0;
in ivec2 vaUV2;
in vec3 at_velocity;

uniform vec3 chunkOffset;
uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;

out vec3 position;
out vec2 texcoord;
out vec3 light;
out vec4 color;
out vec3 normal;

out vec4 masks;
out vec3 velocity;

out float currentSkyWhitePoint;

#include "/lib/to_viewspace.glsl"
#include "/lib/calculate_lighting.glsl"