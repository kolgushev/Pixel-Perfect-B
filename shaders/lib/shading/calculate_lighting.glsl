float normalLighting(in vec3 normal, in vec3 lightPos) {
    #if VANILLA_LIGHTING != 2 && defined SHADOWS_ENABLED
        return clamp(dot(normal, normalize(lightPos)) * 6.0, 0.0, 1.0);
    #else
        #if defined g_clouds
            #if defined IS_IRIS
                return (normal.y - 1) * 0.5 + 1.0;
            #else
                return (normal.y - 1) * 0.2 + 1.0;
            #endif
        #else
            return max(dot(normal, normalize(lightPos)), 0.0);
        #endif
    #endif
}

float rainMultiplier(in float rain)  {
    return max(0.0, inversesqrt(rain + 1.0) * 3.4 - 2.4);
}

vec3 actualSkyColor(in float skyTime) {
    return mix(mix(NIGHT_SKY_COLOR, NIGHT_SKY_COLOR_VANILLA, VANILLA_COLORS) * NIGHT_SKY_LIGHT_MULT, mix(DAY_SKY_COLOR, DAY_SKY_COLOR_VANILLA, VANILLA_COLORS) * SKY_LIGHT_MULT, skyTime * 0.5 + 0.5);
}

// Input is not adjusted lightmap coordinates
mat2x3 getLightColor(in vec3 lightAndAO, in vec3 albedo, in vec3 F0, in float roughness, in vec3 normal, in vec3 normalViewspace, in vec3 incident, in vec3 sunPositionWorld, in vec3 moonPositionWorld, in float rain, in sampler2D vanillaLightTex) {

    vec2 lightmap = lightAndAO.rg;
    float ambientOcclusion = lightAndAO.b;

    #if defined AO_SQUARED
        ambientOcclusion = 1.0 - ambientOcclusion;
        ambientOcclusion = ambientOcclusion * ambientOcclusion;
        ambientOcclusion = 1.0 - ambientOcclusion;
    #endif

    float skyShading = (normal.y - 1) * 0.5 + 1.0;

    #if defined g_clouds
        normalViewspace = normal;
    #endif

    #if VANILLA_LIGHTING != 2

        lightmap = lightmap * 0.937 + 0.0313;

        vec3 indirectLighting = texture(vanillaLightTex, vec2(lightmap.r, mix(0.0313, lightmap.g, VANILLA_LIGHTING_SKY_BLEED))).rgb - VANILLA_NATURAL_AMBIENT_LIGHT;
        vec3 directSolarLighting = texture(vanillaLightTex, lightmap).rgb - VANILLA_NATURAL_AMBIENT_LIGHT;

        indirectLighting = max(indirectLighting, vec3(0));
        directSolarLighting = max(directSolarLighting, vec3(0));

        directSolarLighting = gammaCorrection(directSolarLighting, GAMMA) * RGB_to_AP1 * SKY_LIGHT_MULT;
        indirectLighting = gammaCorrection(indirectLighting, GAMMA) * RGB_to_AP1 * BLOCK_LIGHT_MULT;

        #if VANILLA_LIGHTING == 1 && !defined gc_emissive
            float oldLighting = max((abs(normal.z) + (normal.y) * 2.75), -0.7) * ISQRT_5 + ISQRT_5;
            directSolarLighting *= oldLighting;
        #endif

        /*
        Make sure to have accurate lighting - since indirectLighting
        and directSolarLighting are added together when not in shadow.
        */
        directSolarLighting -= indirectLighting;

        #if defined SHADOWS_ENABLED
            float sunShading = normalLighting(normalViewspace, sunPosition);
            float moonShading = normalLighting(normalViewspace, moonPosition);

            skyShading = mix(moonShading, sunShading, clamp(skyTime * 8.0 + 0.5, 0.0, 1.0) * 0.5 + 0.5);

            directSolarLighting *= skyShading;
        #endif

        vec3 ambientLight = AMBIENT_LIGHT_MULT * (1 - darknessFactor * 0.8) * max(1 - darknessLightFactor * 3.0, 0.0) * AMBIENT_COLOR;

        #if STREAMER_MODE == -1
            ambientLight += vec3(0.8, 0.9, 1.0) * 2.0;
        #else
            ambientLight += nightVision * NIGHT_VISION_COLOR;
        #endif

        indirectLighting += ambientLight + lightningFlash(isLightning, rain) * skyShading * pow(max(lightmap.y - 0.0313, 0), 2);

    #else
        vec2 lightmapAdjusted = lightmap * lightmap;

        float lightBoost = BLOCK_LIGHT_POWER + darknessFactor * 0.9 + darknessLightFactor * 4 - nightVision * 0.5;

        vec3 torchColor = mix(TORCH_TINT, mix(TORCH_TINT_VANILLA, vec3(1), sqrt(lightmap.x)), VANILLA_COLORS);

        // Multiply each part of the light map with it's color

        vec3 torchLighting = gammaCorrection(lightmapAdjusted.x * torchColor, lightBoost) * BLOCK_LIGHT_MULT;

        #if defined USE_PBR
            // adjust roughness to reduce weird-looking specular
            torchLighting = cookTorranceSingleLight(normal, incident, normal, albedo, F0, mix(roughness, 1.0, 0.5), torchLighting);
        #else
            torchLighting *= albedo * RCP_PI;
        #endif

        #if defined HAS_MOON
            float moonIntensity = clamp(-skyTime * 4.0, 0.0, 1.0);

            #if defined USE_PBR
                vec3 moonLighting = cookTorranceSingleLight(normal, incident, moonPositionWorld, albedo, F0, roughness, moonBrightness * MOON_COLOR * moonIntensity);
            #else
                float moonShading = normalLighting(normal, moonPositionWorld);
                vec3 moonLighting = moonShading * moonBrightness * MOON_COLOR * moonIntensity;
            #endif
        #else
            vec3 moonLighting = vec3(0.0);
        #endif
        
        #if defined HAS_SUN
            float sunIntensity = clamp(skyTime * 4.0, 0.0, 1.0);

            // TODO: modify sun color during sunset/sunrise
            #if defined USE_PBR
                vec3 sunLighting = cookTorranceSingleLight(normal, incident, sunPositionWorld, albedo, F0, roughness, SUN_COLOR * sunIntensity);
            #else
                float sunShading = normalLighting(normal, sunPositionWorld);
                vec3 sunLighting = sunShading * SUN_COLOR * sunIntensity;
            #endif
        #else
            vec3 sunLighting = vec3(0.0);
        #endif
        vec3 directSolarLighting = moonLighting + sunLighting;

        #if defined FOG_ENABLED
            directSolarLighting *= directLightMult;
        #else
            directSolarLighting *= rainMultiplier(rain);
        #endif

        #if !defined USE_PBR
            directSolarLighting *= albedo * RCP_PI;
        #endif

        float hardcoreMult = inversesqrt(darknessFactor * 0.75 + 0.25) - 1;
        vec3 ambientLight = hardcoreMult * AMBIENT_LIGHT_MULT * AMBIENT_COLOR;
        ambientLight *= (1 - clamp(lightmap.y * 1.5, 0.0, 1.0));
        #if STREAMER_MODE == -1
            ambientLight += vec3(0.8, 0.9, 1.0) * 2.0;
        #else
            ambientLight += nightVision * NIGHT_VISION_COLOR;
        #endif

        vec3 minLight = hardcoreMult * MIN_LIGHT_MULT * MIN_LIGHT_COLOR * albedo;

        // // shade according to sky color
        // vec3 skyColor = pixelPerfectSkyVector(normal, normalize(sunPositionWorld));
        // vec3 skyLighting = skyColor * lightmapAdjusted.y;

        vec3 skyColor = actualSkyColor(skyTime) * mix(1 - rain, 1, THUNDER_BRIGHTNESS) + lightningFlash(isLightning, rain);
        // technically the pow2 here isn't accurate, but it makes the falloff near the edges of the light look better
        vec3 skyLighting = skyColor * skyShading * lightmapAdjusted.y;

        // the 0.47 here is an artistic decision, anything below 0.5 represents bounce lighting reaching above the surface of a block
        float ambientSkyShading = (normal.y + 1) * -0.47 + 1.0;
        vec3 ambientSkyLight = skyColor * ambientSkyShading * lightmapAdjusted.y * 0.6;

        // Add the lighting togther to get the total contribution of the lightmap the final color.
        vec3 indirectLighting = torchLighting + (ambientLight + skyLighting + ambientSkyLight) * albedo;

        // apply min lighting
        indirectLighting = mix(0.5 * indirectLighting + minLight, indirectLighting, smoothstep(-minLight, 2.0 * minLight, indirectLighting));
    #endif

    float adjustedAo = 1 - clamp((1 - pow(ambientOcclusion, GAMMA)) * VANILLA_AO_INTENSITY, 0.0, 1.0);

    indirectLighting *= adjustedAo;
    #if VANILLA_LIGHTING != 2
        indirectLighting *= albedo;
        directSolarLighting *= adjustedAo * albedo;
    #endif

    return mat2x3(indirectLighting, directSolarLighting);
}