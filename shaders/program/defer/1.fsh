#include "/common_defs.glsl"

/* DRAWBUFFERS:01 */
layout(location=0) out vec4 b0;
layout(location=1) out vec4 b1;

in vec2 texcoord;

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;

uniform sampler2D depthtex1;

uniform sampler2D noisetex;


uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;

uniform float far;

uniform vec3 fogColor;
uniform int isEyeInWater;
uniform float nightVision;
uniform float blindness;
uniform bool isSpectator;

uniform float fogWeatherSky;
uniform float fogWeather;

uniform float inSky;

uniform vec3 cameraPosition;
uniform float frameTimeCounter;

#if defined DIM_END
    uniform int bossBattle;
#endif

#include "/lib/switch_fog_color.glsl"
#include "/lib/fogify.glsl"
#include "/lib/to_viewspace.glsl"
#include "/lib/tonemapping.glsl"

#include "/lib/sample_noisetex.glsl"
#include "/lib/lava_noise.glsl"

void main() {
    vec3 sky = texture(colortex0, texcoord).rgb;
    vec4 albedo = texture(colortex1, texcoord);

    float depth = texture(depthtex1, texcoord).r;

    bool isSky = albedo.a == 0;
    #if OUTLINE_COLOR == -1
        bool isOutline = sky.rgb == vec3(-1);
    #endif

    // the nether doesn't render sky
    #if !defined HAS_SKY
        #if defined ATMOSPHERIC_FOG
            vec3 skyColorProcessed = ATMOSPHERIC_FOG_COLOR;
        #else
            vec3 skyColorProcessed = gammaCorrection(fogColor * 2, GAMMA) * RGB_to_ACEScg;
            #if defined FOG_ENABLED
                skyColorProcessed = mix(skyColorProcessed, ATMOSPHERIC_FOG_COLOR, fogWeather);
            #endif
        #endif

        skyColorProcessed = getFogColor(isEyeInWater, skyColorProcessed);
    #else
        vec3 skyColorProcessed = sky.rgb;
    #endif

    vec3 position = getWorldSpace(gbufferProjectionInverse, gbufferModelViewInverse, texcoord, depth).xyz;

    #if defined HAS_SKYLIGHT
        float inSkyProcessed = inSky;
    #else
        float inSkyProcessed = 1;
    #endif

    #if defined HAS_SKYLIGHT && defined WEATHER_FOG_IN_SKY_ONLY
        float fogWeatherSkyProcessed = fogWeatherSky;
    #else
        float fogWeatherSkyProcessed = fogWeather;
    #endif

    vec4 fogged = fogify(position, position, opaque(albedo.rgb), albedo.rgb, far, isEyeInWater, nightVision, blindness, isSpectator, fogWeatherSkyProcessed, inSkyProcessed, fogColor, cameraPosition, frameTimeCounter, lavaNoise(cameraPosition.xz, frameTimeCounter));
    vec3 composite = fogged.rgb;
    float fog = fogged.a;

    // fade out around edges of world
    composite = isSky ? skyColorProcessed : mix(composite, skyColorProcessed, fog);
    
    #if OUTLINE_COLOR == -1
        if(isOutline) {
            float luma = luminance(composite);
            composite = changeLuminance(composite, luma, 1 - luma);
        }
    #endif

    // manually clear for upcoming transparency pass
    b1 = vec4(0.0);

    #ifdef DEBUG_VIEW
        b0 = albedo;
    #else
        b0 = opaque(composite);
    #endif
}