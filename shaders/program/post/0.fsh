#include "/common_defs.glsl"

/* DRAWBUFFERS:0 */
layout(location = 0) out vec4 b0;

in vec2 texcoord;

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
#if defined PIXELATED_SHADOWS
    uniform sampler2D colortex3;

    uniform vec3 cameraPosition; 
#endif

uniform sampler2D depthtex0;
// uniform sampler2D shadowcolor0;
uniform sampler2D shadowcolor1;
uniform sampler2D noisetex;

uniform mat4 shadowProjection;
uniform mat4 shadowModelView;

uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;

uniform int worldTime;

uniform int frameCounter;
uniform float viewWidth;
uniform float viewHeight;

#include "/lib/sample_noisetex.glsl"
#include "/lib/sample_noise.glsl"

// don't need to include to_viewspace since calculate_lighting already includes it
#include "/lib/to_viewspace.glsl"
#include "/lib/distortion.glsl"
#include "/lib/voxelize.glsl"
#include "/lib/get_shadow.glsl"

void main() {
    vec3 diffuse = texture(colortex0, texcoord).rgb;
    vec3 directLighting = texture(colortex1, texcoord).rgb;

    float skyLightmap = texture(colortex2, texcoord).g;
    float depth = texture(depthtex0, texcoord).r;
    vec3 position = getWorldSpace(gbufferProjectionInverse, gbufferModelViewInverse, texcoord, depth).xyz;

    vec3 normal = texture(colortex3, texcoord).rgb;
    
    #if PIXELATED_SHADOWS != 0
        vec3 pixelatedPosition = floor((position + cameraPosition) * PIXELATED_SHADOWS) / PIXELATED_SHADOWS - cameraPosition;
        position = mix(pixelatedPosition, position, ceil(normal));
    #endif

    float shadow = getShadow(
            position,
            cameraPosition,
            normal,
            shadowProjection,
            shadowModelView,
            texcoord,
            shadowcolor1,
            noisetex,
            skyLightmap,
            worldTime);

    #if defined DEBUG_VIEW
        b0 = opaque(diffuse);
    #else
        b0 = opaque(diffuse + directLighting * shadow);
    #endif
}