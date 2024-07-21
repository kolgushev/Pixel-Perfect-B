// Note: dh_base is separate from base due to issues with the GLSL version used by everything else
#define g_fsh
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

#include "/lib/use.glsl"

void main() {
    // make sure DH terrain doesn't render over existing terrain
    vec2 texcoordScreenspace = gl_FragCoord.xy / vec2(viewWidth, viewHeight);
    float depth = texture(depthtex0, texcoordScreenspace).r;

    // don't render if blind or if rendering standard terrain
    if(depth != 1.0 || blindnessSmooth > (1.0 - EPSILON)) discard;

    // DH terrain dithers out when it is about to be replaced by standard terrain
    // idea for fadeout is originally from BSL, but implementation is from CLOSE_FADE_OUT 
    #if defined TAA_ENABLED
        float offset = frameCounter & 1;
    #else
        float offset = 0.0;
    #endif
    float noiseToSurpass = tile(gl_FragCoord.xy + offset, NOISE_CHECKERBOARD_1D, true).r;

    noiseToSurpass = noiseToSurpass * (1 - EPSILON) + EPSILON;

    if(noiseToSurpass > smoothstep(0.8 * (far - 8.0), 1.0 * (far - 8.0), length(position))
    #if defined gc_transparent
        // if we do this never, we have weird horizon underwater
        // if we do this always, transition to DH terrain looks bad overwater
        && isEyeInWater == 1
    #endif
    ) discard;

    #if defined DIM_NO_RAIN
        float rain = 0;
    #else
        float rain = rainStrength;
        #if defined IS_IRIS
            rain *= mix(thunderStrength, 1, THUNDER_THRESHOLD);
        #endif
    #endif

    vec3 lightmap = vec3(light, color.a);

    vec2 texcoordMod = texcoord;

    vec4 albedo = color;

    // noise up the color
    vec3 absolutePosition = position + cameraPosition;
    vec2 samplePos = normal.x * absolutePosition.yz + normal.y * absolutePosition.xz + normal.z * absolutePosition.yx;
    // we're fetching a 4-channel texture, might as well use it to prevent some cases of repetition
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

    vec3 positionNormalized = normalize(position);
    
    mat2x3 lightColor = getLightColor(
        lightmap,
        albedo.rgb,
        vec3(0.04),
        mix(0.9, 0.1, smoothstep(0.3, 0.9, dot(albedo.rgb, LUMINANCE_COEFFS_AP1))),
        false,
        normal,
        view(normal),
        positionNormalized,
        viewInverse(sunPosition),
        viewInverse(moonPosition),
        rain,
        shadowcolor0);

    lightColor *= albedo.a;

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

    albedo.rgb = lightColor[0] + (lightColor[1] + lightningColor) * shadow;

    #if defined gc_transparent
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
