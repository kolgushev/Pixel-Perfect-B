#include "/common_defs.glsl"

/* DRAWBUFFERS:01 */
layout(location=0) out vec4 b0;
layout(location=1) out vec4 b1;

in vec2 texcoord;


// uniforms

#define use_colortex0
#define use_colortex1
#define use_colortex2
#define use_depthtex1
#define use_noisetex

#define use_gbuffer_projection_inverse
#define use_gbuffer_model_view_inverse
#define use_far
#define use_fog_color
#define use_is_eye_in_water
#define use_night_vision
#define use_blindness_smooth
#define use_is_spectator
#define use_fog_weather_sky
#define use_fog_weather
#define use_in_sky
#define use_eye_brightness_smooth_float
#define use_camera_position
#define use_frame_time_counter

#define use_switch_fog_color
#define use_fogify
#define use_to_viewspace
#define use_tonemapping
#define use_lava_noise

#if defined DIM_END
    #define use_boss_battle
#endif

#if defined RIMLIGHT_ENABLED
    #define use_colortex3

    #define use_near
    #define use_aspect_ratio
    #define use_view_width
    #define use_view_height

    #define use_linearize_depth
#endif

#include "/lib/use.glsl"

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

    vec3 position = getWorldSpace(texcoord, depth);

    #if defined HAS_SKYLIGHT
        float inSkyProcessed = inSky;
        float eyeBrightnessProcessed = eyeBrightnessSmoothFloat;
    #else
        float inSkyProcessed = 1;
        float eyeBrightnessProcessed = 1;
    #endif

    #if defined HAS_SKYLIGHT && defined WEATHER_FOG_IN_SKY_ONLY
        float fogWeatherSkyProcessed = fogWeatherSky;
    #else
        float fogWeatherSkyProcessed = fogWeather;
    #endif

    vec4 fogged = fogify(position, position, opaque(albedo.rgb), albedo.rgb, far, isEyeInWater, nightVision, blindnessSmooth, isSpectator, fogWeatherSkyProcessed, inSkyProcessed, eyeBrightnessProcessed, fogColor, cameraPosition, frameTimeCounter, lavaNoise(cameraPosition.xz, frameTimeCounter));
    vec3 composite = fogged.rgb;
    float fog = fogged.a;

    #if defined RIMLIGHT_ENABLED
        float dist = length(position);

        float maxBacklight = 0;

        vec2 sampleRadius = (RIMLIGHT_PIXEL_RADIUS + 0.1) / vec2(viewWidth, viewHeight);
        #if defined RIMLIGHT_DYNAMIC_RADIUS
            sampleRadius += 0.01 / (dist * vec2(aspectRatio, 1));
        #endif
        for(int i = 1; i < superSampleOffsetsCross.length; i++) {
            vec2 samplePoint = texcoord + superSampleOffsetsCross[i].xy * sampleRadius;
            float sampledDepth = texture(depthtex1, samplePoint).r;

            vec3 sampledPosition = getWorldSpace(texcoord, sampledDepth).xyz;

            bool isRimlit = sampledDepth > depth;

            #if defined RIMLIGHT_OUTLINE
                vec3 normal = texture(colortex3, texcoord).rgb;
                vec3 sampledNormal = texture(colortex3, samplePoint).rgb;

                bool isOutlined = distance(normal, sampledNormal) > 0.1;
                isRimlit = isRimlit || isOutlined;
            #endif

            if(!hand(depth) && isRimlit) {
                float backlight = smoothstep(0.25 * RIMLIGHT_DIST, RIMLIGHT_DIST, length(position - sampledPosition));

                #if defined RIMLIGHT_OUTLINE
                    backlight = isOutlined ? 1 : backlight;
                #endif
                if(maxBacklight < backlight) {
                    maxBacklight = backlight;
                }
            }
        }

        float rimlightRaw = mix(0, maxBacklight * RIMLIGHT_MULT, clamp(clamp(50 / dist, 0.0, 1.0) - fog, 0.0, 1.0));
        float luma = luminance(composite);
        float lumaNew = (luma + 0.1) * rimlightRaw + luma;
        composite = changeLuminance(composite, luma, lumaNew);
    #endif

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