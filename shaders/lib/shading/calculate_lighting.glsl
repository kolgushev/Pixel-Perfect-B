float normalLighting(in vec3 normal, in vec3 lightPos, in float subsurface) {
    #if VANILLA_LIGHTING != 2 && defined SHADOWS_ENABLED
        float shading = dot(normal, normalize(lightPos)) * 6.0;
    #else
        float shading = dot(normal, normalize(lightPos));
    #endif
    
    #if defined DO_SUBSURFACE
        if(subsurface > 0.0) {
            return mix(clamp(shading, 0.0, 1.0), min(abs(shading), 1.0) * 0.5, subsurface) * RCP_PI;
        } else {
            return clamp(shading, 0.0, 1.0) * RCP_PI;
        }
    #else
        return clamp(shading, 0.0, 1.0) * RCP_PI;
    #endif
}

float rainMultiplier(in float rain)  {
    return max(0.0, inversesqrt(rain + 1.0) * 3.4 - 2.4);
}

vec3 actualSkyColor(in float skyTime) {
    return mix(mix(NIGHT_SKY_COLOR, NIGHT_SKY_COLOR_VANILLA, VANILLA_COLORS) * NIGHT_SKY_LIGHT_MULT, mix(DAY_SKY_COLOR, DAY_SKY_COLOR_VANILLA, VANILLA_COLORS) * SKY_LIGHT_MULT, skyTime * 0.5 + 0.5);
}

// Input is not adjusted lightmap coordinates
mat2x3 getLightColor(in vec3 lightAndAO, in float AOMap, in vec3 albedo, in vec3 F0, in float roughness, in int metalId, in float subsurface, in vec3 emissiveness, in bool hasLighting, in float clearcoatStrength, in vec3 clearcoatNormal, in vec3 normal, in vec3 normalViewspace, in vec3 incident, in vec3 sunPositionWorld, in vec3 moonPositionWorld, in float rain, in sampler2D vanillaLightTex) {
    vec3 indirectLighting = vec3(0.0);
    vec3 directSolarLighting = vec3(0.0);

    if(hasLighting) {
        vec2 lightmap = lightAndAO.rg;
        float ambientOcclusion = lightAndAO.b;

        #if defined AO_SQUARED
            ambientOcclusion = 1.0 - ambientOcclusion;
            ambientOcclusion = ambientOcclusion * ambientOcclusion;
            ambientOcclusion = 1.0 - ambientOcclusion;
        #endif

        ambientOcclusion *= AOMap;

        float skyShading = (normal.y - 1) * 0.5 + 1.0;

        #if VANILLA_LIGHTING != 2

            lightmap = lightmap * 0.937 + 0.0313;

            indirectLighting = texture(vanillaLightTex, vec2(lightmap.r, mix(0.0313, lightmap.g, VANILLA_LIGHTING_SKY_BLEED))).rgb - VANILLA_NATURAL_AMBIENT_LIGHT;
            directSolarLighting = texture(vanillaLightTex, lightmap).rgb - VANILLA_NATURAL_AMBIENT_LIGHT;

            indirectLighting = max(indirectLighting, vec3(0));
            directSolarLighting = max(directSolarLighting, vec3(0));

            directSolarLighting = rec709ToACEScg(directSolarLighting) * SKY_LIGHT_MULT;
            indirectLighting = rec709ToACEScg(indirectLighting) * BLOCK_LIGHT_MULT;

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
                float sunShading = normalLighting(normalViewspace, sunPosition, subsurface);
                float moonShading = normalLighting(normalViewspace, moonPosition, subsurface);

                skyShading = mix(moonShading, sunShading, clamp(skyTime * 2.0 * SKY_TRANSITION_SPEED + 0.5, 0.0, 1.0) * 0.5 + 0.5);

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

            torchLighting *= albedo * RCP_PI;

            #if defined HAS_MOON
                float moonIntensity = clamp(-skyTime * SKY_TRANSITION_SPEED, 0.0, 1.0);

                vec3 moonLighting = vec3(0.0);
                if(moonIntensity > 0.0) {
                    moonLighting = singleLight(normal, incident, moonPositionWorld, albedo, F0, roughness, metalId, subsurface, clearcoatStrength, clearcoatNormal, moonBrightness * MOON_COLOR * moonIntensity);
                }
            #else
                vec3 moonLighting = vec3(0.0);
            #endif
            
            #if defined HAS_SUN
                float sunIntensity = clamp(skyTime * SKY_TRANSITION_SPEED, 0.0, 1.0);

                // TODO: modify sun color during sunset/sunrise
                vec3 sunLighting = vec3(0.0);
                if(sunIntensity > 0.0) {
                    sunLighting = singleLight(normal, incident, sunPositionWorld, albedo, F0, roughness, metalId, subsurface, clearcoatStrength, clearcoatNormal, SUN_COLOR * sunIntensity);
                }
            #else
                vec3 sunLighting = vec3(0.0);
            #endif

            directSolarLighting = moonLighting + sunLighting;

            #if defined FOG_ENABLED
                directSolarLighting *= directLightMult;
            #else
                directSolarLighting *= rainMultiplier(rain);
            #endif

            // // shade according to sky color
            // vec3 skyColor = pixelPerfectSkyVector(normal, normalize(sunPositionWorld));
            // vec3 skyLighting = skyColor * lightmapAdjusted.y;

            vec3 skyColor = actualSkyColor(clamp(skyTime * SKY_TRANSITION_SPEED, -1.0, 1.0)) * mix(1 - rain, 1, THUNDER_BRIGHTNESS) + lightningFlash(isLightning, rain);
            // technically the pow2 here isn't accurate, but it makes the falloff near the edges of the light look better
            vec3 skyLighting = skyColor * skyShading * lightmapAdjusted.y;

            // the 0.47 here is an artistic decision, anything below 0.5 represents bounce lighting reaching above the surface of a block
            float ambientSkyShading = (normal.y + 1) * -0.47 + 1.0;
            vec3 ambientSkyLight = skyColor * ambientSkyShading * lightmapAdjusted.y * 0.6;

            // clearcoat
            vec3 skyReflection = vec3(0.0);
            #if defined PUDDLES_REFLECT_SKY
                vec3 clearcoatReflection = incident;
                if(dot(incident, clearcoatNormal) < 0.0) {
                    clearcoatReflection = reflect(incident, clearcoatNormal);
                }
                skyReflection = pixelPerfectSkyVector(clearcoatReflection, sunPositionWorld, vec2(0.0), rain, skyTime, true);

                float fresnel = fresnelSchlick(normalize(clearcoatReflection), clearcoatNormal, 0.02);
                fresnel *= clearcoatStrength;
                skyReflection *= fresnel;
                ambientSkyLight *= 1.0 - fresnel;
            #endif

            float hardcoreMult = inversesqrt(darknessFactor * 0.75 + 0.25) - 1;
            #if !defined g_clouds
                vec3 ambientLight = hardcoreMult * AMBIENT_LIGHT_MULT * AMBIENT_COLOR;
                ambientLight *= (1 - clamp(lightmap.y * 1.5, 0.0, 1.0));
                #if STREAMER_MODE == -1
                    ambientLight += vec3(0.8, 0.9, 1.0) * 2.0;
                #else
                    ambientLight += nightVision * NIGHT_VISION_COLOR;
                #endif
                vec3 minLight = hardcoreMult * MIN_LIGHT_MULT * MIN_LIGHT_COLOR * albedo;
            #else
                vec3 ambientLight = vec3(0.0);
            #endif

            // Add the lighting togther to get the total contribution of the lightmap the final color.
            indirectLighting = torchLighting + (skyLighting + ambientSkyLight + ambientLight) * albedo + skyReflection;

            #if defined g_clouds
                vec3 minLight = 0.5 * indirectLighting;
            #endif

            // apply min lighting
            indirectLighting = mix(0.5 * indirectLighting + minLight, indirectLighting, smoothstep(-minLight, 2.0 * minLight, indirectLighting));


            // apply min lighting
            indirectLighting = mix(0.5 * indirectLighting + minLight, indirectLighting, smoothstep(-minLight, 2.0 * minLight, indirectLighting));
        #endif

        float adjustedAo = 1 - clamp((1 - pow(ambientOcclusion, GAMMA)) * VANILLA_AO_INTENSITY, 0.0, 1.0);

        indirectLighting *= adjustedAo;
        #if VANILLA_LIGHTING != 2
            indirectLighting *= albedo;
            directSolarLighting *= adjustedAo * albedo;
        #endif
    } else {
        emissiveness += albedo * UNLIT_MIN_EMISSION;
    }

    indirectLighting += emissiveness * DEFAULT_EMISSIVE_STRENGTH;

    return mat2x3(indirectLighting, directSolarLighting);
}