#include "/common_defs.glsl"

/* DRAWBUFFERS:01 */
layout(location = 0) out vec4 b0;
#if defined FAST_GI || defined DYNAMIC_EXPOSURE_LIGHTING
    layout(location = 1) out vec4 b1;
#endif

in vec2 texcoord;


// uniforms


#define use_colortex0
#define use_colortex1
#define use_depthtex0
#define use_depthtex1

#define use_gbuffer_projection_inverse
#define use_gbuffer_model_view_inverse
#define use_fog_weather
#define use_far
#define use_is_eye_in_water
#define use_night_vision
#define use_blindness_smooth
#define use_is_spectator
#define use_fog_color
#define use_camera_position
#define use_frame_time_counter
#define use_lava_noise
#define use_camera_position
#define use_in_sky
#define use_eye_brightness_smooth_float
#define use_fog_weather_sky

#define use_fogify
#define use_to_viewspace

#include "/lib/use.glsl"

void main() {
    vec3 albedo = texture(colortex0, texcoord).rgb;

    float depth = texture(depthtex1, texcoord).r;
    float depthWater = texture(depthtex0, texcoord).r;

    vec3 position = getWorldSpace(gbufferProjectionInverse, gbufferModelViewInverse, texcoord, depth).xyz;
    vec3 positionWater = getWorldSpace(gbufferProjectionInverse, gbufferModelViewInverse, texcoord, depthWater).xyz;

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

    vec4 fogged = fogify(position, positionWater, opaque(albedo.rgb), albedo.rgb, far, isEyeInWater, nightVision, blindnessSmooth, isSpectator, fogWeatherSkyProcessed, inSkyProcessed, eyeBrightnessProcessed, fogColor, cameraPosition, frameTimeCounter, lavaNoise(cameraPosition.xz, frameTimeCounter));
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

            vec3 sampledPosition = getWorldSpace(gbufferProjectionInverse, gbufferModelViewInverse, texcoord, sampledDepth).xyz;

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

    vec4 transparency = texture(colortex1, texcoord);
    #if WATER_MIX_MODE == 1
        composite *= mix(vec3(1), transparency.rgb, transparency.a);
    #else
        composite = mix(composite, transparency.rgb, transparency.a);
    #endif

    #if defined FAST_GI || defined DYNAMIC_EXPOSURE_LIGHTING
        b1 = opaque(composite);
    #endif

    #if defined DEBUG_VIEW
        b0 = opaque(albedo);
    #else
        b0 = opaque(composite);
    #endif
}