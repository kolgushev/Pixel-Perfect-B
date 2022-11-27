#include "/common_defs.glsl"

/* DRAWBUFFERS:01 */
layout(location = 1) out vec4 b1;

in vec2 texcoord;

uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D colortex3;

uniform sampler2D shadowcolor0;

uniform vec3 sunPosition;
uniform vec3 moonPosition;

uniform vec3 cameraPosition;

uniform int worldTime;
uniform int moonPhase;
uniform float rainStrength;

uniform float nightVision;
uniform float darknessFactor;
uniform float darknessLightFactor;

uniform mat4 gbufferModelView;


// don't need to include to_viewspace since calculate_lighting already includes it
#include "/lib/tonemapping.glsl"
#include "/lib/color_manipulation.glsl"
#include "/lib/to_viewspace.glsl"
#include "/lib/calculate_lighting.glsl"

#if defined SHADOWS_ENABLED
    #include "/lib/get_shadow.glsl"

    uniform sampler2D depthtex1;
    uniform sampler2D shadowcolor1;
    uniform mat4 shadowProjection;
    uniform mat4 shadowModelView;
    
    uniform mat4 gbufferProjectionInverse;
    uniform mat4 gbufferModelViewInverse;
#endif

void main() {
    vec4 albedo = texture(colortex1, texcoord);
    
    vec3 lightmap = texture(colortex2, texcoord).rgb;
    
    vec3 normal = texture(colortex3, texcoord).rgb;
    vec3 normalViewspace = view(normal);

    #if defined SHADOWS_ENABLED
        float depth = texture(depthtex1, texcoord).r;
        vec3 position = getWorldSpace(gbufferProjectionInverse, gbufferModelViewInverse, texcoord, depth).xyz;
        float shadow = getShadow(
            position,
            shadowProjection,
            shadowModelView,
            shadowcolor1,
            lightmap.g,
            worldTime);
    #else
        float shadow = lightmap.g;
    #endif

    mat2x3 lightColor = getLightColor(lightmap,
    normal,normalViewspace,
    sunPosition,
    moonPosition,
    moonPhase,
    worldTime,
    rainStrength,
    nightVision, darknessFactor,
    darknessLightFactor,
    shadowcolor0);

    #if !defined DEBUG_VIEW
        albedo.rgb *= lightColor[0] + lightColor[1] * shadow;
    #endif

    b1 = albedo;

    // vec2 texcoordMod = supersampleSampleShift(texcoord);
    // b1 = opaque1(texture(shadowcolor1, texcoordMod).r);
    // b1 = opaque(texture(shadowcolor0, texcoord).rgb);
    // b1 = opaque2(texcoordMod);
}