#include "/common_defs.glsl"

/* DRAWBUFFERS:01 */
layout(location=0) out vec4 b0;
layout(location=1) out vec4 b1;

in vec2 texcoord;

#include "/lib/use.glsl"

void main() {
    vec3 sky = texture(colortex0, texcoord).rgb;
    vec4 albedo = texture(colortex1, texcoord);

    float depth = texture(depthtex1, texcoord).r;
    #if defined DISTANT_HORIZONS
        // dhDepthTex1 isn't updated yet
        float dhDepth = texture(dhDepthTex0, texcoord).r;
    #endif

    bool isSky = albedo.a == 0;
    #if OUTLINE_COLOR == -1
        bool isOutline = sky.rgb == vec3(-1);
    #endif

    // the nether & twilight forest don't render sky
    #if !defined HAS_SKY
        #if defined DIM_TWILIGHT
            vec3 skyColorProcessed = pixelPerfectSkyVector(viewInverse(depthToView(texcoord, depth, gbufferProjectionInverse)), vec3(0.0, -1.0, 0.0), vec2(0.0), 0.0, -1.0);
        #else
            #if defined ATMOSPHERIC_FOG
                vec3 skyColorProcessed = ATMOSPHERIC_FOG_COLOR;
            #else
                vec3 skyColorProcessed = gammaCorrection(fogColor * 2, GAMMA) * RGB_to_AP1;
                #if defined FOG_ENABLED
                    skyColorProcessed = mix(skyColorProcessed, ATMOSPHERIC_FOG_COLOR, fogWeather);
                #endif
            #endif

            skyColorProcessed = getFogColor(isEyeInWater, skyColorProcessed);
        #endif
    #else
        vec3 skyColorProcessed = sky.rgb;
    #endif

    vec3 composite = albedo.rgb;
    vec3 position = getWorldSpace(texcoord, depth);
    #if defined DISTANT_HORIZONS
        if(depth == 1.0) {
            position = getWorldSpace(texcoord, dhDepth, dhProjectionInverse);
        }
    #endif

    #if defined HAS_SKYLIGHT && defined WEATHER_FOG_IN_SKY_ONLY
        float fogWeatherSkyProcessed = fogWeatherSky;
    #else
        float fogWeatherSkyProcessed = fogWeather;
    #endif


    #if defined DISTANT_HORIZONS
        #define FAR dhFarPlane
    #else
        #define FAR far
    #endif

    vec4 fogged = fogify(position, position, opaque(albedo.rgb), albedo.rgb, FAR, isEyeInWater, nightVision, blindnessSmooth, isSpectator, fogWeatherSkyProcessed, fogColor, cameraPosition, frameTimeCounter, lavaNoise(cameraPosition.xz, frameTimeCounter));
    composite = fogged.rgb;
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
        float luma = dot(composite, LUMINANCE_COEFFS_AP1);
        float lumaNew = (luma + 0.1) * rimlightRaw + luma;
        composite = changeLuminance(composite, luma, lumaNew);
    #endif

    // fade out around edges of world
    #if defined BORDER_FOG
        composite = isSky ? skyColorProcessed : mix(composite, skyColorProcessed, fog);
    #else
        composite = isSky ? skyColorProcessed : composite;
    #endif

    #if OUTLINE_COLOR == -1
        if(isOutline) {
            composite = 0.2 / (0.2 + composite);
        }
    #endif

    // manually clear for upcoming transparency pass
    #if WATER_MIX_MODE == 1
        b1 = vec4(vec3(1.0), 0.0);
    #elif WATER_MIX_MODE == 0
        b1 = vec4(0.0);
    #else
        b1 = vec4(vec3(mix(0.0, 1.0, WATER_MULT_STRENGTH)), 0.0);
    #endif

    #ifdef DEBUG_VIEW
        b0 = albedo;
    #else
        b0 = opaque(composite);
    #endif
}