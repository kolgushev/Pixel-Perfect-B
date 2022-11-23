#include "/common_defs.glsl"

/* DRAWBUFFERS:0 */
layout(location = 0) out vec4 b0;

in vec2 texcoord;

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D colortex3;

uniform sampler2D depthtex0;
uniform sampler2D shadowtex1;
uniform sampler2D shadowcolor1;

uniform mat4 shadowProjection;
uniform mat4 shadowModelView;

uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;

uniform int worldTime;

// don't need to include to_viewspace since calculate_lighting already includes it
#include "/lib/to_viewspace.glsl"
#include "/lib/get_shadow.glsl"

void main() {
    vec3 diffuse = texture(colortex0, texcoord).rgb;
    vec3 directLighting = texture(colortex1, texcoord).rgb;

    float skyLightmap = texture(colortex2, texcoord).g;
    vec3 normal = texture(colortex2, texcoord).rgb;
    float depth = texture(depthtex0, texcoord).r;
    vec3 position = getWorldSpace(gbufferProjectionInverse, gbufferModelViewInverse, texcoord, depth).xyz;

    float shadow = getShadow(
        position,
        normal,
        shadowProjection,
        shadowModelView,
        shadowtex1,
        shadowcolor1,
        skyLightmap,
        worldTime);

    #if defined DEBUG_VIEW
        b0 = opaque(diffuse);
    #else
        b0 = opaque(diffuse + directLighting * shadow);
    #endif

    // b0 = texture(shadowtex1, texcoord);
}