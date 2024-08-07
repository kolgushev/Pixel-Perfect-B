#define use_atmospheric_fog_brightness_water

#include "/common_defs.glsl"

/* DRAWBUFFERS:01235 */
layout(location = 0) out vec4 b0; // sky, near plane
layout(location = 1) out vec4 b1; // far plane
layout(location = 2) out vec4 b2; // light
layout(location = 3) out vec4 b3; // normal
layout(location = 4) out vec4 b5; // motion

in vec2 texcoord;
in vec4 color;
in vec2 light;
in vec3 position;
in vec3 normal;
flat in int mcEntity;
#if defined TAA_ENABLED
    in vec3 prevClip;
    in vec3 unjitteredClip;
#endif
#if defined g_skybasic
    in vec2 stars;
#endif



#if defined CLOSE_FADE_OUT && (defined gc_fades_out || defined gc_particles)
    #define fade_out_items
#endif

// uniforms

#define use_texture

#define use_render_stage
#define use_alpha_test_ref

#define use_tonemapping
#define use_hdr_mapping

#if defined fade_out_items
    #define use_view_width
    #define use_view_height
    #define use_gbuffer_model_view

    #if defined TAA_ENABLED
        #define use_frame_counter
        #define use_sample_noise
    #else
        #define use_sample_noisetex
    #endif
#endif

#if defined gc_transparent
    #define use_shadowcolor0

    #define use_sun_position
    #define use_moon_position
    #define use_darkness_factor
    #define use_darkness_light_factor
    #define use_is_spectator
    #define use_is_eye_in_water
    #define use_gbuffer_model_view
    #define use_lightning_bolt_position
    #define use_is_lightning
    #define use_direct_light_mult
    #define use_far
    #define use_view_width
    #define use_view_height
    #define use_gbuffer_projection_inverse
    #define use_gbuffer_model_view_inverse
    #define use_colortex0
    #define use_depthtex1
    #define use_sky_time
    #define use_frame_time_counter
    #define use_night_vision
    #define use_blindness_smooth
    #define use_fog_color

    #define use_fogify
    #define use_to_viewspace
    #define use_sample_noisetex
    #define use_lava_noise
    #define use_camera_position
    #define use_basic_direct_shading

    #if defined SHADOWS_ENABLED
        #define use_shadowtex1
        #define use_shadow_projection
        #define use_shadow_model_view


        #define use_frame_counter
        #define use_view_width
        #define use_view_height

        #define use_sample_noise
        #define use_get_shadow
    #endif

    // for changing the end sky rendering when fighting the dragon
    #if defined DIM_END
        #define use_boss_battle
    #endif

    #define NEED_WEATHER_DATA
#endif

#if defined g_water
    #define use_tonemapping
#endif

#if defined g_terrain
    #define use_frame_time_counter
    #define use_sample_noisetex
    #define use_lava_noise
    #define use_camera_position
#endif

#if defined gc_sky
    #define use_far
    #define use_sky_time
    #define use_is_eye_in_water
    #define use_blindness_smooth

    #if defined DIM_END
        #define use_boss_battle
    #endif

    #define use_switch_fog_color

    #define NEED_WEATHER_DATA
#endif

#if defined g_weather
    #define use_sky_time
    #define use_rain_wind_sharp
    #define use_rain_wind

    #if defined NOISY_RAIN
        #define use_rain_wind
        #define use_camera_position
        #define use_sample_noisetex
    #endif

    #define NEED_WEATHER_DATA
#endif

#if defined g_skybasic
    #define use_gbuffer_projection_inverse
    #define use_view_width
    #define use_view_height
    #define use_fog_color
    #define use_sky_color
    #define use_is_lightning
    #define use_sun_position
    #define use_gbuffer_model_view_inverse

    // #define use_calculate_sky
    #define use_pixel_perfect_sky
#else
    #define use_entity_color

    #if defined TEXTURE_FILTERING
        #define use_texture_filter
    #endif
#endif

#if defined NEED_WEATHER_DATA
    #define use_moon_brightness
    #define use_rain_strength
    #define use_thunder_strength

    #define use_fog_weather
    #define use_fog_weather_sky
    #define use_in_sky
    #define use_eye_brightness_smooth_float

    #define use_color_manipulation
    #define use_calculate_lighting
#endif

#if defined DIM_END && defined g_skytextured
    #define use_sample_noisetex
#endif

#include "/lib/use.glsl"

void main() {
    #if defined DISTANT_HORIZONS
        #define FAR dhFarPlane
    #else
        #define FAR far
    #endif

    #if defined gc_sky && defined DIM_TWILIGHT
        #if defined g_skybasic
            if(stars.g <= 0.5) {
                discard;
            }
        #endif
    #endif

    // discard if too close
    #if defined fade_out_items
        // sample noise texture
        #if defined TAA_ENABLED
            float offset = frameCounter & 1;
        #else
            float offset = 0.0;
        #endif
        float noiseToSurpass = tile(gl_FragCoord.xy + offset, NOISE_CHECKERBOARD_1D, true).r;

        #if defined CLOSE_FADE_OUT_FULL
            noiseToSurpass = noiseToSurpass * (1 - EPSILON) + EPSILON;
        #else
            noiseToSurpass = noiseToSurpass * 1.5 - 0.5;
        #endif


        if(noiseToSurpass > smoothstep(0.47 * FADE_OUT_RADIUS, 0.6 * FADE_OUT_RADIUS, length(position))) discard;
    #endif

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

    #if defined gc_basic
        vec3 lightmap = vec3(0.7, 0.7, 1);
    #elif defined g_clouds
        vec3 lightmap = vec3(0, 1, 1);
    #else
        vec3 lightmap = vec3(light, color.a);
        if(mcEntity == LIT_PROBLEMATIC) {
            lightmap.rg = vec2(10, 0);
        }
    #endif


    #if defined g_skybasic
        if(renderStage == MC_RENDER_STAGE_SUNSET) discard;

        vec4 albedo = opaque(pixelPerfectSkyVector(position, viewInverse(sunPosition), stars, rain, skyTime));

        if(stars.g > 0.5) {
            albedo = opaque1(stars.r);
            if(position.y < 0) {
                discard;
            }
        }
    #else
        #if defined g_weather
            vec3 absolutePosition = position + cameraPosition;
            vec2 positionMod = tile(absolutePosition.xz + frameTimeCounter * 4, NOISE_PERLIN_4D, false).xy;
        #endif

        vec2 texcoordMod = texcoord;

        #if defined DIM_END && defined g_skytextured
            texcoordMod = tile(texcoordMod * END_SKY_RESOLUTION, NOISE_BLUE_2D, true).rg;
        #endif

        #if defined g_weather
            texcoordMod.x *= RAIN_THICKNESS;
            texcoordMod.y *= mix(RAIN_THICKNESS, 1, rainWindSharp);
        #endif

        #if defined gc_skybox && !defined DIM_END
            #define FILTER_SKYBOX
        #endif

        vec4 albedo = texture(gtexture, texcoordMod);

        albedo.rgb *= color.rgb;

        #if defined g_clouds
            albedo.a *= step(0.1, albedo.a) * 0.6;
        #elif !defined gc_terrain
            albedo.a *= color.a;
        #endif

        #if defined g_damagedblock
            albedo.a = clamp(albedo.a - 0.003, 0.0, 1.0);
        #elif defined g_weather
            float rainMask;
            #if defined NOISY_RAIN
                rainMask = tile((frameTimeCounter * 12 + absolutePosition.y) * 3 + positionMod * 200 + absolutePosition.xz * 4, NOISE_PERLIN_4D, false).r;

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
            float normalizedHeight = normalize(position).y;
            albedo.a = normalizedHeight < -0.001 ? 0.0 : smoothstep(-0.005, 0.05, normalizedHeight);

            // prevent sun from showing during rain
            albedo.a *= smoothstep(-THUNDER_THRESHOLD, 0, -rain);
        #endif
    #endif

    #if !defined IS_IRIS
        if(albedo.a < alphaTestRef) discard;
    #else
        #if defined g_terrain
            if(albedo.a < 0.1) discard;
        #else
            if(albedo.a < EPSILON) discard;
        #endif
    #endif

    #if !defined g_skybasic
        albedo.rgb = srgb_to_linear(albedo.rgb);
        albedo.rgb *= RGB_to_AP1;
    #endif

    #if HDR_TEX_STANDARD == 1
        albedo.rgb = uncharted2_filmic_inverse(albedo.rgb * AP1_to_RGB) * RGB_to_AP1;
    #elif HDR_TEX_STANDARD == 2
        albedo.rgb = aces_fitted_inverse(albedo.rgb);
    #endif

    #if defined g_line
        if(renderStage == MC_RENDER_STAGE_OUTLINE && color.rgb == vec3(0)) {
            #if OUTLINE_COLOR == 0
                albedo = vec4(0.0, 0.0, 0.0, OUTLINE_ALPHA);
            #elif OUTLINE_COLOR == 1
                albedo = vec4(10, 10, 10, OUTLINE_ALPHA);
            #elif OUTLINE_COLOR == 2
                albedo = vec4(10, 0, 0, OUTLINE_ALPHA);
            #elif OUTLINE_COLOR == 3
                albedo = vec4(0, 10, 0, OUTLINE_ALPHA);
            #elif OUTLINE_COLOR == 4
                albedo = vec4(0, 1, 10, OUTLINE_ALPHA);
            #elif OUTLINE_COLOR == 5
                albedo.rgb = BASE_COLOR;
                albedo.a = OUTLINE_ALPHA;
            #elif OUTLINE_COLOR == -1
                albedo = vec4(-1, -1, -1, 1);
            #endif
        }
    #endif

    #if defined DIM_TEST
        albedo.rgb = vec3(1, 0, 0);
    #endif

    #if defined g_skybasic
        albedo.rgb += lightningFlash(isLightning, rain) * 0.1;
    #endif

    #if defined g_skytextured
        #if defined HAS_DAYNIGHT_CYCLE
            // since we're using an advanced color pipeline it's safe to pump up the skytextured brightness
            albedo.rgb *= mix(MOON_LIGHT_MULT, SUN_LIGHT_MULT, clamp(skyTime * 8.0 + 0.5, 0.0, 1.0));
        #endif
        #if !defined DIM_USES_SKYBOX
            albedo.rgb *= PLANET_BRIGHTNESS;
        #endif
    #endif

    #if defined g_weather && !defined DIM_NO_RAIN
        const float a = 1.5;
        float skyTransition = skyTime;

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
        albedo.rgb *= clamp(SKY_LIGHT_MULT * 0.45, 0.0, 100.0) * SKY_BRIGHTNESS;

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
    if(renderStage == MC_RENDER_STAGE_WORLD_BORDER) {
        albedo.rgb *= 100.0;
    }

    #if defined g_terrain && NOISY_LAVA != 0
        if(mcEntity == LAVA) {
            albedo.rgb *= lavaNoise(position.xz + cameraPosition.xz, frameTimeCounter);
        }
    #endif

    #if defined gc_transparent
        vec3 positionNormalized = normalize(position);
        // apply lighting here for transparent stuff
        #if defined g_clouds
            // TODO: figure out a way for this to work dynamically with Optifine's configurable cloud height
            #if defined DIM_TWILIGHT
                #define CLOUD_HEIGHT 128.36
            #else
                #define CLOUD_HEIGHT 192.36
            #endif
            float positionMod = clamp((position.y + cameraPosition.y - CLOUD_HEIGHT) * 0.3, 0.0, 1.0);

            positionMod = mix(positionMod, 1, 0);

            albedo.a *= 0.8;

            positionMod = mix(positionMod * (1 - rain), 1, 0);

            #if VANILLA_LIGHTING == 2
                vec3 normalMod = vec3(0, positionMod * 2 - 1, 0);

                mat2x3 lightColor = getLightColor(
                    lightmap,
                    normalMod,
                    view(normalMod),
                    positionNormalized,
                    viewInverse(sunPosition),
                    viewInverse(moonPosition),
                    rain,
                    shadowcolor0);
            #else
                vec3 skyColor = actualSkyColor(skyTime) + lightningFlash(isLightning, rain);
                skyColor *= mix(positionMod, 1, 0.5);

                mat2x3 lightColor = mat2x3(
                    skyColor,
                    vec3(0)
                );
            #endif

            lightColor[0] *= CLOUD_COLOR * mix(1 - rain, 1, RAINCLOUD_BRIGHTNESS);
            lightColor[0] += lightColor[1];
            lightColor[1] = vec3(0);
        #elif defined g_weather
            mat2x3 lightColor = mat2x3(
                vec3(1),
                vec3(0)
            );
        #elif WATER_MIX_MODE != 1 || defined gc_transparent_mixed
            mat2x3 lightColor = getLightColor(
                lightmap,
                normal,
                view(normal),
                positionNormalized,
                viewInverse(sunPosition),
                viewInverse(moonPosition),
                rain,
                shadowcolor0);

            lightColor *= albedo.a;
        #endif

        #if WATER_MIX_MODE != 1 || defined gc_transparent_mixed
            #if defined SHADOWS_ENABLED
                vec3 shadowPos = position;
                vec3 pixelatedPosition = position;

                #if PIXELATED_SHADOWS != 0
                    pixelatedPosition = ceil((position + cameraPosition) * PIXELATED_SHADOWS) / PIXELATED_SHADOWS - cameraPosition;
                    shadowPos = mix(pixelatedPosition, position, ceil(abs(normal)));
                #endif

                float shadow = getShadow(
                    shadowPos,
                    pixelatedPosition + cameraPosition,
                    shadowProjection,
                    shadowModelView,
                    texcoord,
                    shadowtex1,
                    lightmap.g,
                    skyTime);
            #else
                #if defined VANILLA_SHADOWS
                    float shadow = lightmap.g < 1 - RCP_16 ? 0 : 1;
                #else
                    float shadow = basicDirectShading(lightmap.g);
                #endif

            #endif

            vec3 lightningColor = vec3(0.0);

            if(lightningBoltPosition.w == 1.0) {
                lightningColor = lightningFlash(1, rainStrength) / (pow(distance(position.xz, lightningBoltPosition.xz), 2) + 1.0);
                lightningColor *= DIRECT_LIGHTNING_STRENGTH;
            }

        #endif

        #if defined g_clouds
            albedo.rgb = lightColor[0] + lightningColor;
        #elif WATER_MIX_MODE == 0 || defined gc_transparent_mixed
            albedo.rgb *= lightColor[0] + (lightColor[1] + lightningColor) * shadow;
        #elif WATER_MIX_MODE == 2
            albedo.rgb *= mix(lightColor[0] + (lightColor[1] + lightningColor) * shadow, vec3(1.0), WATER_MULT_STRENGTH);
        #endif

        vec3 positionOpaque = position;
        vec3 diffuse = albedo.rgb;
        #if defined g_water
            albedo.a *= 0.9;
            if(mcEntity == WATER) {
                #if WATER_STYLE == 1
                    diffuse = gammaCorrection(diffuse, GAMMA);
                    float luma = luminance(diffuse);
                    albedo.a *= albedo.a * mix(luma, 1.0, 0.5);
                    albedo.a = clamp(albedo.a * 1.1, 0.0, 1.0);
                    luma = smoothstep(0.4, 1.0, luma);
                    diffuse = mix(albedo.rgb, vec3(lightColor[0]), luma);
                #endif
            }

            #if defined WATER_FOG_FROM_OUTSIDE
                if(mcEntity == WATER || mcEntity == ICE) {
                    vec2 texcoordScreenspace = gl_FragCoord.xy / vec2(viewWidth, viewHeight);

                    float depth = texture(depthtex1, texcoordScreenspace).r;
                    // TODO: figure out a way to fix this
                    // diffuse = texture(colortex3, texcoordScreenspace).rgb;
                    // diffuse = vec3(1);
                    positionOpaque = getWorldSpace(texcoordScreenspace, depth);
                }
            #endif
        #endif

        #if defined HAS_SKYLIGHT && defined WEATHER_FOG_IN_SKY_ONLY
            float fogWeatherSkyProcessed = fogWeather;
        #else
            float fogWeatherSkyProcessed = fogWeatherSky;
        #endif

        vec4 fogged = fogify(position, position, albedo, diffuse, FAR, isEyeInWater, nightVision, blindnessSmooth, isSpectator, fogWeatherSkyProcessed, fogColor, cameraPosition, frameTimeCounter, lavaNoise(cameraPosition.xz, frameTimeCounter));

        albedo.rgb = fogged.rgb;
        albedo.a *= 1 - fogged.a;

        #if defined WATER_FOG_FROM_OUTSIDE && defined g_water
            vec4 overlay = vec4(0);
            if(mcEntity == WATER || mcEntity == ICE) {
                float atmosPhogWater = 0.0;
                float opaqueFog = 1.0;
                if(isEyeInWater == 0) {
                    opaqueFog = fogifyDistanceOnly(positionOpaque, FAR, blindnessSmooth, 1/FAR);
                    atmosPhogWater = distance(position, positionOpaque);
                    float fogDensity = mcEntity == WATER ? ATMOSPHERIC_FOG_DENSITY_WATER : FOG_DENSITY_ICE;
                    atmosPhogWater = mix(atmosPhogWater, FAR, opaqueFog) * fogDensity;
                    // atmosPhogWater = min(atmosPhogWater, 1);
                    atmosPhogWater = 1 - exp(-atmosPhogWater);
                }

                // apply fog to non-transparent objects
                overlay = vec4(ATMOSPHERIC_FOG_BRIGHTNESS_WATER * ATMOSPHERIC_FOG_COLOR_WATER, atmosPhogWater * (1 - fogged.a));
            }
        #endif
    #endif

    #if defined TAA_ENABLED
        #if defined IS_IRIS && defined g_hand
            b5 = vec4(0);
        #else
            vec2 prevTexcoord = (prevClip.xy / prevClip.z) * 0.5 + 0.5;
            vec2 unjitteredTexcoord = (unjitteredClip.xy / unjitteredClip.z) * 0.5 + 0.5;
            #if defined gc_transparent && !defined g_clouds
                if(albedo.a > 0.65) {
            #endif
                b5 = opaque2(prevTexcoord - unjitteredTexcoord);
            #if defined gc_transparent && !defined g_clouds
                }
            #endif
        #endif
    #endif

    #if defined gc_sky
        // ?Even though the sky texture doesn't have an alpha layer, we use alpha in the gbuffers
        // ?for proper mixing of g_skytextured

        #if defined FOG_ENABLED && (defined g_skybasic || defined gc_skybox)
            albedo.rgb = mix(ATMOSPHERIC_FOG_COLOR, albedo.rgb, exp(-fogWeather * FAR * ATMOSPHERIC_FOG_DENSITY * ATMOSPHERIC_FOG_MULTIPLIER * WEATHER_FOG_MULTIPLIER));
        #endif

        albedo.rgb = mix(albedo.rgb, vec3(0), blindnessSmooth);

        #if defined FAST_GI
            albedo.rgb *= 1 + FAST_GI_EXPOSURE_CORRECT_GRAY * FAST_GI_STRENGTH;
        #endif

        b0 = albedo;
        b1 = vec4(0, 0, 0, 0);
    #elif defined gc_transparent
        #if defined gc_transparent_mixed
            // clouds are always mixed instead of multiplied
            b0 = albedo;
        #else
            #if defined WATER_FOG_FROM_OUTSIDE && defined g_water
                b0 = overlay;
            #endif
            b1 = albedo;
        #endif
    #elif OUTLINE_COLOR == -1 && defined g_line
        if(renderStage == MC_RENDER_STAGE_OUTLINE && color.rgb == vec3(0)) {
            b0 = albedo;
        }
    #else
        b1 = albedo;
        // b1 = vec4((b5).rg * 0.5 + 0.5, 0, 1);
    #endif

    if(albedo.a > 0.5 || renderStage == MC_RENDER_STAGE_TERRAIN_CUTOUT_MIPPED || renderStage == MC_RENDER_STAGE_TERRAIN_SOLID) {
        b2 = opaque(lightmap);
        b3 = opaque(normal);
    }

    #if defined g_line
        if(renderStage == MC_RENDER_STAGE_OUTLINE && color.rgb == vec3(0)) {
            b2.a = 0;
        }
    #endif

    #if defined WHITE_WORLD
        b1 = color;
    #endif
}
