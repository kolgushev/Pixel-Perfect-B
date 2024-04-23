#define use_atmospheric_fog_brightness_water

#include "/common_defs.glsl"

/* DRAWBUFFERS:01235 */
vec4 b0; // sky, near plane
vec4 b1; // far plane
vec4 b2; // light
vec4 b3; // normal
vec4 b5; // motion

varying vec2 texcoord;
varying vec4 color;
varying vec2 light;
varying vec3 position;
varying vec3 normal;
flat varying int mcEntity;

#if defined TAA_ENABLED
    varying vec3 prevClip;
    varying vec3 unjitteredClip;
#endif

#if defined g_skybasic
    varying vec2 stars;
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

#define use_lava_noise
#define use_sample_noisetex

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

#if defined gc_transparent
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
    // make sure DH terrain doesn't render over existing terrain
    vec2 texcoordScreenspace = gl_FragCoord.xy / vec2(viewWidth, viewHeight);
    float depth = texture(depthtex0, texcoordScreenspace).r;
    if(depth != 1.0) discard;

    // if we do this never, we have weird horizon underwater
    // if we do this always, transition to DH terrain looks bad overwater
    if(length(position) < (far - 8)
    #if defined gc_transparent
        && isEyeInWater == 1
    #endif
    ) {
        discard;
    }

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

    vec3 lightmap = vec3(light, color.a);

    vec2 texcoordMod = texcoord;

    vec4 albedo = color;

    // noise up the color
    vec3 absolutePosition = position + cameraPosition;
    vec2 samplePos = normal.x * absolutePosition.yz + normal.y * absolutePosition.xz + normal.z * absolutePosition.yx;
    albedo.rgb *= mix(dot(tile(samplePos * 4.0, NOISE_WHITE_4D, true).rgb, normal), 1.0, 0.9);

    // We didn't add this into the color in vsh since color is multiplied and entityColor is mixed
    albedo.rgb = mix(albedo.rgb, entityColor.rgb, entityColor.a);

    #if !defined IS_IRIS
        if(albedo.a < alphaTestRef) discard;
    #else
        if(albedo.a < 0.1) discard;
    #endif

    albedo.rgb = srgb_to_linear(albedo.rgb);
    albedo.rgb *= RGB_to_AP1;

    #if HDR_TEX_STANDARD == 1
        albedo.rgb = uncharted2_filmic_inverse(albedo.rgb * AP1_to_RGB) * RGB_to_AP1;
    #elif HDR_TEX_STANDARD == 2
        albedo.rgb = aces_fitted_inverse(albedo.rgb);
    #endif

    #if defined DIM_TEST
        albedo.rgb = vec3(1, 0, 0);
    #endif

    #if defined HDR_TEX_LIGHT_BRIGHTNESS
        #if !defined gc_emissive
            if(mcEntity == DH_BLOCK_ILLUMINATED || mcEntity == DH_BLOCK_LAVA) {
        #endif
                albedo.rgb = SDRToHDR(albedo.rgb);
        #if !defined gc_emissive
            }
        #endif
    #endif


    #if NOISY_LAVA != 0
        if(mcEntity == DH_BLOCK_LAVA) {
            albedo.rgb *= lavaNoise(position.xz + cameraPosition.xz, frameTimeCounter);
        }
    #endif

    #if defined gc_transparent
        vec3 positionNormalized = normalize(position);
        #if WATER_MIX_MODE != 1 || defined gc_transparent_mixed
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

        #if WATER_MIX_MODE == 0 || defined gc_transparent_mixed
            albedo.rgb *= lightColor[0] + (lightColor[1] + lightningColor) * shadow;
        #elif WATER_MIX_MODE == 2
            albedo.rgb *= mix(lightColor[0] + (lightColor[1] + lightningColor) * shadow, vec3(1.0), WATER_MULT_STRENGTH);
        #endif

        vec3 positionOpaque = position;
        vec3 diffuse = albedo.rgb;
        #if defined gc_transparent
            albedo.a *= 0.9;
            if(mcEntity == DH_BLOCK_WATER) {
                #if WATER_STYLE == 1
                    albedo *= vec4(vec3(0.7), 0.3);
                #else
                    albedo.a *= 0.6;
                #endif
            }

            #if defined WATER_FOG_FROM_OUTSIDE
                if(mcEntity == DH_BLOCK_WATER) {
                    float dhDepth = texture(dhDepthTex1, texcoordScreenspace).r;
                    // TODO: figure out a way to fix this
                    // diffuse = texture(colortex3, texcoordScreenspace).rgb;
                    // diffuse = vec3(1);
                    positionOpaque = getWorldSpace(texcoordScreenspace, dhDepth, dhProjectionInverse);
                }
            #endif
        #endif

        #if defined HAS_SKYLIGHT && defined WEATHER_FOG_IN_SKY_ONLY
            float fogWeatherSkyProcessed = fogWeather;
        #else
            float fogWeatherSkyProcessed = fogWeatherSky;
        #endif

        vec4 fogged = fogify(position, position, albedo, diffuse, dhFarPlane, isEyeInWater, nightVision, blindnessSmooth, isSpectator, fogWeatherSkyProcessed, fogColor, cameraPosition, frameTimeCounter, lavaNoise(cameraPosition.xz, frameTimeCounter));

        albedo.rgb = fogged.rgb;
        albedo.a *= 1 - fogged.a;

        #if defined WATER_FOG_FROM_OUTSIDE && defined gc_transparent
            vec4 overlay = vec4(0);
            if(mcEntity == DH_BLOCK_WATER) {
                float atmosPhogWater = 0.0;
                float opaqueFog = 1.0;
                if(isEyeInWater == 0) {
                    opaqueFog = fogifyDistanceOnly(positionOpaque, dhFarPlane, blindnessSmooth, 1/dhFarPlane);
                    atmosPhogWater = distance(position, positionOpaque);
                    float fogDensity = ATMOSPHERIC_FOG_DENSITY_WATER;
                    atmosPhogWater = mix(atmosPhogWater, dhFarPlane, opaqueFog) * fogDensity;
                    // atmosPhogWater = min(atmosPhogWater, 1);
                    atmosPhogWater = 1 - exp(-atmosPhogWater);
                }

                // apply fog to non-transparent objects
                overlay = vec4(ATMOSPHERIC_FOG_BRIGHTNESS_WATER * ATMOSPHERIC_FOG_COLOR_WATER, atmosPhogWater * (1 - fogged.a));
            }
        #endif
    #endif

    #if defined TAA_ENABLED

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

    #if defined gc_transparent
        #if defined gc_transparent_mixed
            // clouds are always mixed instead of multiplied
            b0 = albedo;
        #else
            #if defined WATER_FOG_FROM_OUTSIDE && defined gc_transparent
                b0 = overlay;
            #endif
            b1 = albedo;
        #endif
    #else
        b1 = albedo;
        b0 = vec4(0.0);
        // b1 = vec4((b5).rg * 0.5 + 0.5, 0, 1);
    #endif

    if(albedo.a > 0.5 || renderStage == MC_RENDER_STAGE_TERRAIN_CUTOUT_MIPPED || renderStage == MC_RENDER_STAGE_TERRAIN_SOLID) {
        b2 = opaque(lightmap);
        b3 = opaque(normal);
    }

    #if defined WHITE_WORLD
        b1 = color;
    #endif

    gl_FragData[0] = b0;
    gl_FragData[1] = b1;
    gl_FragData[2] = b2;
    gl_FragData[3] = b3;
    gl_FragData[4] = b5;
}
