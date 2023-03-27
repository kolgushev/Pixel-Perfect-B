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
uniform float moonBrightness;
uniform float rainStrength;
uniform float isLightning;

uniform float directLightMult;

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
    uniform sampler2D depthtex1;
    uniform sampler2D shadowtex1;
    uniform sampler2D noisetex;
    uniform mat4 shadowProjection;
    uniform mat4 shadowModelView;
    
    uniform mat4 gbufferProjectionInverse;
    uniform mat4 gbufferModelViewInverse;

    uniform int frameCounter;
    uniform float viewWidth;
    uniform float viewHeight;

    #include "/lib/sample_noisetex.glsl"
    #include "/lib/sample_noise.glsl"
    #include "/lib/get_shadow.glsl"
#endif

void main() {
    vec4 albedo = texture(colortex1, texcoord);
    
    vec3 lightmap = texture(colortex2, texcoord).rgb;
    
    vec3 normal = texture(colortex3, texcoord).rgb;
    vec3 normalViewspace = view(normal);

    #if defined SHADOWS_ENABLED
        float depth = texture(depthtex1, texcoord).r;
        vec3 position = getWorldSpace(gbufferProjectionInverse, gbufferModelViewInverse, texcoord, depth).xyz;
        vec3 pixelatedPosition = position;

        #if PIXELATED_SHADOWS != 0
            pixelatedPosition = floor((position + cameraPosition) * PIXELATED_SHADOWS) / PIXELATED_SHADOWS - cameraPosition;
            position = mix(pixelatedPosition, position, ceil(abs(normal)));
        #endif

        float shadow = getShadow(
            position,
            pixelatedPosition + cameraPosition,
            shadowProjection,
            shadowModelView,
            texcoord,
            shadowtex1,
            noisetex,
            lightmap.g,
            worldTime);
    #else
        #if defined VANILLA_SHADOWS
            float shadow = lightmap.g < 1 - RCP_16 ? 0 : 1;
        #else
            float shadow = basicDirectShading(lightmap.g);
        #endif
    #endif

    mat2x3 lightColor = getLightColor(lightmap,
    normal,normalViewspace,
    sunPosition,
    moonPosition,
    moonBrightness,
    skyTime(worldTime),
    rainStrength,
    directLightMult,
    nightVision,
    darknessFactor,
    darknessLightFactor,
    isLightning,
    shadowcolor0);

    #if !defined DEBUG_VIEW
        albedo.rgb *= lightColor[0] + lightColor[1] * shadow;
    #endif

    b1 = albedo;
}