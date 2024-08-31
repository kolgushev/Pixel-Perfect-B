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
varying vec4 tangent;

flat varying int mcEntity;

#if defined TAA_ENABLED
    varying vec3 prevClip;
    varying vec3 unjitteredClip;
#endif

#include "/lib/use.glsl"

void main() {
    // make sure DH terrain doesn't render over existing terrain
    vec2 texcoordScreenspace = gl_FragCoord.xy / vec2(viewWidth, viewHeight);
    float depth = texture(depthtex0, texcoordScreenspace).r;

    // don't render if blind or if rendering behind standard terrain
    if(depth != 1.0 || blindnessSmooth > (1.0 - EPSILON)) discard;

    // DH terrain dithers out when it is about to be replaced by standard terrain
    // idea for fadeout is originally from BSL, but implementation is from CLOSE_FADE_OUT 
    #if defined TAA_ENABLED
        #if defined BLUE_DITHERING
            float offset = frameCounter * 113;
        #else
            float offset = frameCounter & 1;
        #endif
    #else
        float offset = 0.0;
    #endif

    #if defined BLUE_DITHERING
        #define DITHER_NOISE NOISE_BLUE_1D
    #else
        #define DITHER_NOISE NOISE_CHECKERBOARD_1D
    #endif

    float noiseToSurpass = tile(gl_FragCoord.xy + offset, DITHER_NOISE, true).r;

    noiseToSurpass = noiseToSurpass * (1 - EPSILON) + EPSILON;

    float transition = fogifyDistanceOnly(position, (far - 16.0), 0.0, 1.0 / (far - 16.0), 0.6);
    if(noiseToSurpass > transition
    #if defined gc_transparent && !defined SMOOTH_TRANSITION_TO_DH
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
    

    #if !defined IS_IRIS
        if(albedo.a < alphaTestRef) discard;
    #else
        if(albedo.a < 0.1) discard;
    #endif

    albedo.rgb = sRGBToACEScg(albedo.rgb);

    #if HDR_TEX_STANDARD == 1
        albedo.rgb = linearRGBToACEScg(uncharted2_filmic_inverse(ACEScgToLinearRGB(albedo.rgb)));
    #elif HDR_TEX_STANDARD == 2
        albedo.rgb = aces_fitted_inverse(albedo.rgb);
    #endif

    #if defined DIM_TEST
        albedo.rgb = vec3(1, 0, 0);
    #endif

    // -2 dielectric, -1 generic metal, 0-n hardcoded metal
    int metalId = mcEntity == DH_BLOCK_METAL ? -1 : -2;
    float roughness = 0.9;
    float subsurface = 0.0;
    vec3 reflectance = vec3(0.02);
    vec3 emissiveness = vec3(0.0);

    #if defined AUTO_MAT
        switch(mcEntity) {
            case DH_BLOCK_LEAVES:
                // High roughness due to varied normals approximating rough microfacet model at distance
                // (and also automat doesn't count leaves as smooth)
                subsurface = 0.5;
                reflectance = vec3(0.04);
                break;
            case DH_BLOCK_STONE:
                reflectance = vec3(0.02);
                break;
            case DH_BLOCK_WOOD:
                roughness = 0.7;
                reflectance = vec3(0.05);
                break;
            case DH_BLOCK_METAL:
                roughness = 0.2;
                reflectance = albedo.rgb;
                break;
            case DH_BLOCK_DIRT:
                reflectance = vec3(0.02);
                break;
            case DH_BLOCK_LAVA:
                reflectance = vec3(0.1);
                break;
            case DH_BLOCK_DEEPSLATE:
                reflectance = vec3(0.02);
                break;
            case DH_BLOCK_SNOW:
                roughness = 0.6;
                subsurface = 0.8;
                reflectance = vec3(0.04);
                break;
            case DH_BLOCK_SAND:
                roughness = 0.8;
                subsurface = 0.1;
                reflectance = vec3(0.05);
                break;
            case DH_BLOCK_TERRACOTTA:
                roughness = 0.75;
                reflectance = vec3(0.05);
                break;
            case DH_BLOCK_NETHER_STONE:
                reflectance = vec3(0.02);
                break;
            case DH_BLOCK_WATER:
                // Higher-than-usual roughness due to automat in non-DH terrain
                roughness = 0.4;
                reflectance = vec3(0.02);
                break;
            case DH_BLOCK_ILLUMINATED:
                reflectance = vec3(0.02);
                break;
        }
        roughness *= roughness;

        emissiveness = mcEntity == DH_BLOCK_ILLUMINATED || mcEntity == DH_BLOCK_LAVA ? getEmissiveness(albedo.rgb, LUMINANCE_COEFFS_AP1) : vec3(0.0);
    #endif

    if(mcEntity == DH_BLOCK_LAVA) {
        #if defined MC_TEXTURE_FORMAT_LAB_PBR_1_3 || defined AUTO_MAT
            #if NOISY_LAVA != 0
                emissiveness *= lavaNoise(position.xz + cameraPosition.xz, frameTimeCounter);
            #endif
            // lava actually has a very low albedo, its orange color is exclusively because of emission
            // simulate that here
            albedo.rgb *= 0.1;
            emissiveness *= 1.5;
        #else
            albedo.rgb *= 1.0;
            #if NOISY_LAVA != 0
                albedo.rgb *= lavaNoise(position.xz + cameraPosition.xz, frameTimeCounter);
            #endif
        #endif
    }

    vec3 positionNormalized = normalize(position);
    
    mat2x3 lightColor = getLightColor(
        lightmap,
        1.0,
        albedo.rgb,
        reflectance,
        roughness,
        metalId,
        subsurface,
        emissiveness,
        true,
        0.0,
        UP,
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

        #if defined DH_SHADOWS_ENABLED
            float shadow = getShadow(
                shadowPos,
                normal,
                getTBN(normal, tangent),
                gl_FragCoord.xy,
                viewInverse(shadowLightPosition),
                lightmap.g,
                skyTime,
                subsurface);
        #else
            #if defined VANILLA_SHADOWS
                float shadow = lightmap.g < 1 - RCP_16 ? 0 : 1;
            #else
                float shadow = basicDirectShading(lightmap.g);
            #endif
        #endif
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
                    opaqueFog = fogifyDistanceOnly(positionOpaque, dhFarPlane, blindnessSmooth, 1/dhFarPlane, 0.875);
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
        #if defined WATER_FOG_FROM_OUTSIDE && defined gc_transparent
            b0 = overlay;
        #endif
        b1 = albedo;
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
