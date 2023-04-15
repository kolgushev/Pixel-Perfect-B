#include "/common_defs.glsl"

/* DRAWBUFFERS:0123 */
layout(location = 0) out vec4 b0;
layout(location = 1) out vec4 b1;
layout(location = 2) out vec4 b2;
layout(location = 3) out vec4 b3;

in vec2 texcoord;
in vec4 color;
in vec2 light;
in vec3 position;
in vec3 normal;
flat in int mcEntity;

#if defined g_skybasic
    in vec2 stars;
#endif

// TODO: make a separate def for each uniform
uniform sampler2D texture;
uniform sampler2D shadowcolor0;

uniform vec4 entityColor;
uniform int isEyeInWater;
uniform float nightVision;
uniform float blindness;

uniform vec3 fogColor;
uniform vec3 skyColor;

uniform float isLightning;

uniform int renderStage;


#if defined gc_transparent
    uniform vec3 sunPosition;
    uniform vec3 moonPosition;

    uniform float darknessFactor;
    uniform float darknessLightFactor;
    uniform bool isSpectator;

    uniform mat4 gbufferModelView;

    uniform float directLightMult;
    uniform float far;

    uniform float viewWidth;
    uniform float viewHeight;

    uniform mat4 gbufferProjectionInverse;
    uniform mat4 gbufferModelViewInverse;

    uniform sampler2D colortex0;
    uniform sampler2D depthtex1;
#endif

#if defined gc_transparent || defined g_skytextured || defined g_weather
    uniform int worldTime;
#endif

#if defined FOG_ENABLED && (defined g_skybasic || defined gc_skybox)
    uniform float far;
#endif

#if defined g_skybasic
    uniform mat4 gbufferProjectionInverse;
    uniform int viewWidth;
    uniform int viewHeight;
#endif

#if (defined gc_sky || defined gc_transparent) && defined DIM_END
    uniform int bossBattle;
#endif

#include "/lib/tonemapping.glsl"
#include "/lib/calculate_sky.glsl"
#include "/lib/hdr_mapping.glsl"

#if defined gc_transparent
    #include "/lib/fogify.glsl"
    #include "/lib/to_viewspace.glsl"
#endif


#if defined gc_transparent || defined g_weather || defined gc_sky
    #define NEED_WEATHER_DATA
#endif

#if defined NEED_WEATHER_DATA
    uniform float moonBrightness;
    uniform float rainStrength;

    #if defined IS_IRIS
        uniform float thunderStrength;
    #endif

    uniform float fogWeather;
    uniform float fogWeatherSky;
    uniform float inSky;
    uniform float eyeBrightnessSmoothFloat;

    #include "/lib/color_manipulation.glsl"
    #include "/lib/calculate_lighting.glsl"
#endif

#if defined gc_sky
    uniform float far;

    #include "/lib/switch_fog_color.glsl"
#endif

#if defined g_weather && defined NOISY_RAIN
    #define use_camera_position
    #define use_noisetex_lib
#endif

#if defined g_weather
    uniform float rainWind;
#endif

#if defined DIM_END && defined g_skytextured
    #define use_noisetex_lib
#endif
#if defined g_terrain || defined gc_transparent
    #define use_noisetex_lib
    #define use_lava_noise
    #define use_camera_position

    uniform float frameTimeCounter;
#endif

#if defined use_camera_position
    uniform vec3 cameraPosition;
#endif
#if defined use_noisetex_lib
    uniform sampler2D noisetex;
    #include "/lib/sample_noisetex.glsl"
#endif

#if defined use_lava_noise

    #include "/lib/lava_noise.glsl"
#endif

void main() {
    #if defined NEED_WEATHER_DATA
        #if defined DIM_NO_RAIN
            float rain = 0;
        #else
            float rain = rainStrength;
            #if defined IS_IRIS
                rain *= mix(thunderStrength, 1, THUNDER_THRESHOLD);
            #endif
        #endif
    #endif

    #if defined g_basic
        vec3 lightmap = vec3(0.7, 0.7, 1);
    #elif defined g_clouds
        vec3 lightmap = vec3(0, 1, 1);
    #else
        vec3 lightmap = vec3(light, color.a);
    #endif

    vec3 customFogColor = mix(fogColor, skyColor, SKY_COLOR_BLEND);

    #if defined g_skybasic
        // TODO: make a proper sunset
        if(renderStage == MC_RENDER_STAGE_SUNSET) discard;

        vec4 albedo = stars.g > 0.5 ? opaque1(stars.r) * NIGHT_SKY_LIGHT_MULT * STAR_WEIGHTS : opaque(calcSkyColor(normalize(position), skyColor, customFogColor));
        /*  The sky is rendered using a cylinder-like shape at the top and a flat shape at the bottom.
            For some reason the vaPosition for the flat shape translates to the same as texcoord when
            mapped to clipspace, so we need to detect that and set it to the fog color
            instead of evaluating the gradient.
        */
        if(distance(color.rgb, fogColor) < EPSILON) albedo = opaque(customFogColor);

        albedo.rgb = mix(albedo.rgb, RAINY_SKY_COLOR, smoothstep(THUNDER_THRESHOLD, 1, rain));
    #else
        #if defined g_weather
            vec3 absolutePosition = position + cameraPosition;
            vec2 positionMod = tile(absolutePosition.xz + frameTimeCounter * 4, vec2(1, 0), false).xy;
        #endif
        
        vec2 texcoordMod = texcoord;
        
        #if defined DIM_END && defined g_skytextured
            texcoordMod = tile(texcoordMod * END_SKY_RESOLUTION, vec2(1, 1), true).rg;
        #endif
        
        #if defined g_weather
            texcoordMod.x *= RAIN_THICKNESS;
        #endif

        vec4 albedo = texture2D(texture, texcoordMod);
        vec3 uncoloredDiffuse = albedo.rgb;

        albedo.rgb *= color.rgb;
        #if defined g_clouds
            albedo.a *= step(0.1, albedo.a);
        #elif !defined gc_terrain
            albedo.a *= color.a;
        #endif

        #if defined g_damagedblock
            albedo.a = clamp(albedo.a - 0.003, 0, 1);
        #elif defined g_weather
            float rainMask;
            #if defined NOISY_RAIN
                rainMask = tile((frameTimeCounter * 12 + absolutePosition.y) * 3 + positionMod * 200 + absolutePosition.xz * 4, vec2(1, 0), false).r;

                rainMask = smoothstep(RAIN_AMOUNT, RAIN_AMOUNT + RAIN_CONSTRAINT, rainMask);

                // albedo.a = 1;
                // albedo.rgb = vec3(rainMask);
            #else
                rainMask = RAIN_AMOUNT_USER * 0.9 + 0.1;
            #endif

            albedo.a *= mix(SNOW_OPACITY, rainMask, rainWind);
        #endif
        
        // We didn't add this into the color in vsh since color is multiplied and entityColor is mixed
        albedo.rgb = mix(albedo.rgb, entityColor.rgb, entityColor.a);
    #endif

    #if defined g_skytextured
        #if defined DIM_END
            float vertical = normalize(position).y;
            float gradient = smoothstep(-1, 0.1, vertical);
            albedo.rgb *= gradient;

            float gradient2 = smoothstep(-0.2, 1, vertical);
            if(bossBattle != 2) {
                albedo.rgb = mix(albedo.rgb, SDRToHDR(albedo.rgb * 7) * 0.05, pow(gradient2, 2));
            }
        #elif !defined DIM_NO_HORIZON
            // prevent underground sun/moon, add virtual horizon
            albedo.a = smoothstep(-0.05, 0.01, normalize(position).y);

            // prevent sun from showing during rain
            albedo.a *= smoothstep(-THUNDER_THRESHOLD, 0, -rain);
        #endif
    #endif
    
    if(albedo.a < EPSILON) discard;
    
    albedo.rgb = gammaCorrection(albedo.rgb, GAMMA);

    #if HDR_TEX_STANDARD == 1
        albedo.rgb = uncharted2_filmic_inverse(albedo.rgb);
    #elif HDR_TEX_STANDARD == 2
        albedo.rgb = aces_fitted_inverse(albedo.rgb * RGB_to_ACEScg) * ACEScg_to_RGB;
    #endif

    #if defined g_skybasic
        // saturate
        albedo.rgb = max(vec3(0), saturateRGB(SKY_SATURATION) * albedo.rgb);
    #endif

    albedo.rgb *= RGB_to_ACEScg;

    #if defined g_basic
        if(renderStage == MC_RENDER_STAGE_OUTLINE) {
            #if OUTLINE_COLOR == 0
                albedo = vec4(0.01, 0.01, 0.01, 0.8);
            #elif OUTLINE_COLOR == 1
                albedo = vec4(10, 10, 10, 0.8);
            #elif OUTLINE_COLOR == 2
                albedo = vec4(10, 0, 0, 0.8);
            #elif OUTLINE_COLOR == 3
                albedo = vec4(0, 10, 0, 0.8);
            #elif OUTLINE_COLOR == 4
                albedo = vec4(0, 1, 10, 0.8);
            #elif OUTLINE_COLOR == 5
                albedo.rgb = BASE_COLOR;
                albedo.a = 0.8;
            #elif OUTLINE_COLOR == -1
                albedo = vec4(-1, -1, -1, 1);
            #endif
        }
    #endif

    #if defined DIM_TEST
        albedo.rgb = vec3(1, 0, 0);
    #endif

    #if defined gc_sky
        albedo.rgb += lightningFlash(isLightning, rain) * 0.1;

        if(isEyeInWater == 1) {
            float farFog = exp(-far * ATMOSPHERIC_FOG_DENSITY_WATER);
            albedo.rgb = mix(ATMOSPHERIC_FOG_COLOR_WATER, albedo.rgb, farFog);
        }
    #endif

    #if defined g_skytextured
        #if defined HAS_DAYNIGHT_CYCLE
            // since we're using an advanced color pipeline it's safe to pump up the skytextured brightness
            albedo.rgb *= mix(MOON_LIGHT_MULT, SUN_LIGHT_MULT, skyTime(worldTime));
        #endif
        #if !defined DIM_USES_SKYBOX
            albedo.rgb *= PLANET_BRIGHTNESS;
        #endif
    #endif

    #if defined g_weather && !defined DIM_NO_RAIN
        const float a = 1.5;
        float skyTransition = skyTime(worldTime);

        albedo.a = max(0.15, albedo.a);

        albedo.a *= RAIN_TRANSPARENCY * smoothstep(0, THUNDER_THRESHOLD, rain);
        
        albedo.rgb *= 
            rainMultiplier(rain) * mix(moonBrightness * MOON_COLOR, SUN_COLOR, skyTransition)
            + actualSkyColor(skyTransition)
            + lightningFlash(isLightning, rain);
        albedo.rgb *= 0.5;
    #endif

    #if defined gc_sky
        #if defined SKY_ADDITIVE
            #if defined DIM_END && defined g_skytextured
                if(bossBattle != 2) {
                    albedo.rgb += SKY_ADDITIVE * gradient2;
                    // albedo.rgb += SKY_ADDITIVE;
                } else {
                    albedo.rgb += SKY_ADDITIVE;
                }
            #else
                albedo.rgb += SKY_ADDITIVE;
            #endif
        #endif


        // anything more than about 100 causes an overflow
        albedo.rgb *= clamp(SKY_LIGHT_MULT * 0.45, 0, 100) * SKY_BRIGHTNESS;

        #if defined DIM_END
            if(bossBattle == 2) {
                albedo.rgb *= BOSS_BATTLE_SKY_MULT;
            }
        #endif

        albedo.rgb = getFogColor(isEyeInWater, albedo.rgb);
    #endif

    #if defined HDR_TEX_LIGHT_BRIGHTNESS
        #if !defined gc_emissive
            if(mcEntity == LIT || mcEntity == LIT_CUTOUTS || mcEntity == LIT_CUTOUTS_UPSIDE_DOWN || mcEntity == LAVA || mcEntity == WAVING_CUTOUTS_BOTTOM_LIT || mcEntity == LIT_PROBLEMATIC) {
        #endif
                albedo.rgb = SDRToHDR(albedo.rgb);
        #if !defined gc_emissive
            }
        #endif
    #endif

    #if defined g_spidereyes
        albedo.rgb *= SPIDEREYES_MULT;
    #endif

    #if defined g_terrain && NOISY_LAVA != 0
        if(mcEntity == LAVA) {
            albedo.rgb *= lavaNoise(position.xz + cameraPosition.xz, frameTimeCounter);
        }
    #endif

    #if defined gc_transparent
        // apply lighting here for transparent stuff
        #if defined g_clouds
            #if defined IS_IRIS
                float positionMod = clamp(position.y * RCP_8, 0, 1);
            #else
                float positionMod = mix(normal.y, 1, 0.6);
            #endif
            
            albedo.a *= 0.8;
            
            positionMod = mix(positionMod * (1 - rain), 1, 0.0);

            #if VANILLA_LIGHTING == 2
                vec3 normalMod = vec3(0, positionMod * 2 - 1, 0);

                mat2x3 lightColor = getLightColor(
                    lightmap,
                    normalMod,
                    view(normalMod),
                    sunPosition,
                    moonPosition,
                    moonBrightness,
                    skyTime(worldTime),
                    rain,
                    directLightMult,
                    nightVision,
                    darknessFactor,
                    darknessLightFactor,
                    isLightning,
                    shadowcolor0);
            #else
                vec3 skyColor = actualSkyColor(skyTime(worldTime)) + lightningFlash(isLightning, rain);
                skyColor *= mix(positionMod, 1, 0.5);

                mat2x3 lightColor = mat2x3(
                    skyColor,
                    vec3(0)
                );
            #endif

            lightColor[0] *= CLOUD_COLOR * mix(1 - rain, 1, RAINCLOUD_BRIGHTNESS);
        #elif defined g_weather
            mat2x3 lightColor = mat2x3(
                vec3(1),
                vec3(0)
            );
        #else
            mat2x3 lightColor = getLightColor(
                lightmap,
                normal,
                view(normal),
                sunPosition,
                moonPosition,
                moonBrightness,
                skyTime(worldTime),
                rain,
                directLightMult,
                nightVision,
                darknessFactor,
                darknessLightFactor,
                isLightning,
                shadowcolor0);
        #endif
        
        #if defined SHADOWS_ENABLED
            vec4 directLighting = opaque(lightColor[1]) * albedo;
            #if defined g_clouds
                albedo.rgb = lightColor[0];
            #else
                albedo.rgb *= lightColor[0];
            #endif
        #else
            #if defined VANILLA_SHADOWS
                float shadow = lightmap.g < 1 - RCP_16 ? 0 : 1;
            #else
                float shadow = basicDirectShading(lightmap.g);
            #endif
            #if defined g_clouds || defined g_weather
                albedo.rgb = lightColor[0];
            #else
                albedo.rgb *= lightColor[0] + lightColor[1] * shadow;
            #endif
        #endif

        vec3 positionOpaque = position;
        vec3 diffuse = albedo.rgb;
        #if defined g_water
            albedo.a *= 0.9;
            if(mcEntity == WATER) {
                #if WATER_STYLE == 1
                    uncoloredDiffuse = gammaCorrection(uncoloredDiffuse, GAMMA);
                    float luma = luminance(uncoloredDiffuse);
                    albedo.a *= albedo.a * luma;
                    albedo.a = clamp(albedo.a * 1.1, 0, 1);
                    luma = smoothstep(0.45, 1.0, luma);
                    albedo.rgb = mix(albedo.rgb, vec3(lightColor[0]), luma);
                #endif

                #if defined WATER_FOG_FROM_OUTSIDE
                    vec2 texcoordScreenspace = gl_FragCoord.xy / vec2(viewWidth, viewHeight);

                    float depth = texture2D(depthtex1, texcoordScreenspace).r;
                    // TODO: figure out a way to fix this
                    // diffuse = texture2D(colortex3, texcoordScreenspace).rgb;
                    // diffuse = vec3(1);
                    positionOpaque = getWorldSpace(gbufferProjectionInverse, gbufferModelViewInverse, texcoordScreenspace, depth).xyz;
                #endif
            }
        #endif

        // apply fog as well
        #if defined HAS_SKYLIGHT
            float inSkyProcessed = inSky;
            float eyeBrightnessProcessed = eyeBrightnessSmoothFloat;
        #else
            float inSkyProcessed = 1;
            float eyeBrightnessProcessed = 1;
        #endif

        #if defined HAS_SKYLIGHT && defined WEATHER_FOG_IN_SKY_ONLY
            float fogWeatherSkyProcessed = fogWeather;
        #else
            float fogWeatherSkyProcessed = fogWeatherSky;
        #endif

        vec4 fogged = fogify(position, positionOpaque, albedo, diffuse, far, isEyeInWater, nightVision, blindness, isSpectator, fogWeatherSkyProcessed, inSkyProcessed, eyeBrightnessProcessed, fogColor, cameraPosition, frameTimeCounter, lavaNoise(cameraPosition.xz, frameTimeCounter));

        albedo.rgb = fogged.rgb;
        albedo.a *= 1 - fogged.a;
        #if defined SHADOWS_ENABLED
            directLighting.a *= 1 - fogged.a;
        #endif

        // TODO: find out why water lighting is being inherited from opaque geometry
    #endif

    #if defined gc_sky
        // ?Even though the sky texture doesn't have an alpha layer, we use alpha in the gbuffers
        // ?for proper mixing of g_skytextured

        #if defined FOG_ENABLED && (defined g_skybasic || defined gc_skybox)
            albedo.rgb = mix(ATMOSPHERIC_FOG_COLOR, albedo.rgb, exp(-fogWeather * far * ATMOSPHERIC_FOG_DENSITY * ATMOSPHERIC_FOG_MULTIPLIER * WEATHER_FOG_MULTIPLIER));
        #endif
        
        albedo.rgb = mix(albedo.rgb, vec3(0), blindness);

        #if defined FAST_GI
            albedo.rgb *= 1 + FAST_GI_EXPOSURE_CORRECT_GRAY * FAST_GI_STRENGTH;
        #endif

        b0 = albedo;
        b1 = vec4(0, 0, 0, 0);
    #elif defined gc_transparent
        b0 = albedo;
        #if defined SHADOWS_ENABLED
            b1 = directLighting;
        #endif
    
    #elif OUTLINE_COLOR == -1 && defined g_basic
        if(renderStage == MC_RENDER_STAGE_OUTLINE) {
            b0 = albedo;
        }
    #else
        b1 = albedo;
    #endif

    b2 = opaque(lightmap);
    b3 = opaque(normal);

    #if defined g_basic
        if(renderStage == MC_RENDER_STAGE_OUTLINE) {
            b2.a = 0;
        }
    #endif
}