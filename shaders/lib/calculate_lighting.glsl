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

float basicDirectShading(in float skyLight) {
    return pow(clamp((skyLight - 1.0 + RCP_3) * 3.0, 0.0, 1.0), 2.0);
}

float rainMultiplier(in float rain)  {
    return max(0.0, inversesqrt(rain + 1.0) * 3.4 - 2.4);
}

vec3 actualSkyColor(in float skyTransition) {
    return mix(mix(NIGHT_SKY_COLOR, NIGHT_SKY_COLOR_VANILLA, VANILLA_COLORS), mix(DAY_SKY_COLOR, DAY_SKY_COLOR_VANILLA, VANILLA_COLORS), skyTransition);
}

vec3 lightningFlash(in float isLightning, in float rain) {
    #if !defined DIM_NO_RAIN
        return isLightning * rain * LIGHTNING_FLASHES * 25.0 * LIGHTNING_FLASH_TINT;
    #else
        return vec3(0);
    #endif
}

// Input is not adjusted lightmap coordinates
mat2x3 getLightColor(in vec3 lightAndAO, in vec3 normal, in vec3 normalViewspace, in vec3 sunPosition, in vec3 moonPosition, in float moonBrightness, in float skyTransition, in float rain, in float directLightMult, in float nightVisionEffect, in float darknessEffect, in float darknessPulseEffect, in float isLightning, in sampler2D vanillaLightTex) {

    vec2 lightmap = lightAndAO.rg;
    float ambientOcclusion = lightAndAO.b;

    #if defined AO_SQUARED
        // the correct multiplier is 1.5 but 1.75 looks better
        ambientOcclusion = clamp(1 - (pow(1 - ambientOcclusion, 2) * 1.5), 0.0, 1.0);
    #endif

    float skyShading = (normal.y - 1) * 0.5 + 1.0;

    #if defined g_clouds
        normalViewspace = normal;
    #endif

    #if VANILLA_LIGHTING != 2

        // using texture2D instead of texture since the Optifine-provided varying block atlas is also called texture
        vec3 indirectLighting = texture2D(vanillaLightTex, vec2(lightmap.r, mix(0.0313, lightmap.g, VANILLA_LIGHTING_SKY_BLEED))).rgb - VANILLA_NATURAL_AMBIENT_LIGHT;
        vec3 directSkyLighting = texture2D(vanillaLightTex, lightmap).rgb - VANILLA_NATURAL_AMBIENT_LIGHT;

        indirectLighting = max(indirectLighting, vec3(0));
        directSkyLighting = max(directSkyLighting, vec3(0));

        directSkyLighting = gammaCorrection(directSkyLighting, GAMMA) * RGB_to_ACEScg * SKY_LIGHT_MULT;
        indirectLighting = gammaCorrection(indirectLighting, GAMMA) * RGB_to_ACEScg * BLOCK_LIGHT_MULT;

        #if VANILLA_LIGHTING == 1
            float oldLighting = max((abs(normal.z) * 1.25 + (normal.y) * 2.75), -0.7) * ISQRT_5 + ISQRT_5;
            directSkyLighting *= oldLighting;
        #endif

        /*
        Make sure to have accurate lighting - since indirectLighting
        and directSkyLighting are added together when not in shadow.
        */
        directSkyLighting -= indirectLighting;

        #if defined SHADOWS_ENABLED
            float sunShading = normalLighting(normalViewspace, sunPosition);
            float moonShading = normalLighting(normalViewspace, moonPosition);

            skyShading = mix(moonShading, sunShading, skyTransition);

            directSkyLighting *= skyShading;
        #endif

        vec3 ambientLight = AMBIENT_LIGHT_MULT * (1 - darknessEffect * 0.8) * max(1 - darknessPulseEffect * 3.0, 0.0) * AMBIENT_COLOR;

        #if STREAMER_MODE == -1
            ambientLight += vec3(0.8, 0.9, 1.0) * 2.0;
        #else
            ambientLight += nightVisionEffect * NIGHT_VISION_COLOR;
        #endif

        indirectLighting += ambientLight + lightningFlash(isLightning, rain) * skyShading * pow(max(lightmap.y - 0.0313, 0), 2);

    #else
        vec2 lightmapAdjusted = lightmap * lightmap;

        float lightBoost = BLOCK_LIGHT_POWER + darknessEffect * 0.9 + darknessPulseEffect * 4 - nightVisionEffect * 0.5;

        // Compute dot product vertex shading from normals
        float sunShading = normalLighting(normalViewspace, sunPosition);
        float moonShading = normalLighting(normalViewspace, moonPosition);


        vec3 torchColor = mix(TORCH_TINT, mix(TORCH_TINT_VANILLA, vec3(1), sqrt(lightmap.x)), VANILLA_COLORS);

        // Multiply each part of the light map with it's color

        vec3 torchLighting = gammaCorrection(lightmapAdjusted.x * torchColor, lightBoost) * BLOCK_LIGHT_MULT;

        vec3 moonLighting = moonShading * moonBrightness * MOON_COLOR;
        vec3 sunLighting = sunShading * SUN_COLOR;
        vec3 directSkyLighting = mix(moonLighting, sunLighting, skyTransition);

        #if defined FOG_ENABLED
            directSkyLighting *= directLightMult;
        #else
            directSkyLighting *= rainMultiplier(rain);
        #endif

        float hardcoreMult = inversesqrt(darknessEffect * 0.75 + 0.25) - 1;
        vec3 ambientLight = hardcoreMult * AMBIENT_LIGHT_MULT * AMBIENT_COLOR;
        ambientLight *= (1 - clamp(lightmap.y * 1.5, 0.0, 1.0));
        #if STREAMER_MODE == -1
            ambientLight += vec3(0.8, 0.9, 1.0) * 2.0;
        #else
            ambientLight += nightVisionEffect * NIGHT_VISION_COLOR;
        #endif

        vec3 minLight = hardcoreMult * MIN_LIGHT_MULT * MIN_LIGHT_COLOR;

        vec3 skyColor = actualSkyColor(skyTransition) * mix(1 - rain, 1, THUNDER_BRIGHTNESS) + lightningFlash(isLightning, rain);
        // technically the pow2 here isn't accurate, but it makes the falloff near the edges of the light look better
        vec3 skyLighting = skyColor * skyShading * lightmapAdjusted.y;

        // the 0.47 here is an artistic decision, anything below 0.5 represents bounce lighting reaching above the surface of a block
        float ambientSkyShading = (normal.y + 1) * -0.47 + 1.0;
        vec3 ambientSkyLight = (directSkyLighting + skyColor) * ambientSkyShading * lightmapAdjusted.y * 0.6;
        
        // Add the lighting togther to get the total contribution of the lightmap the final color.
        vec3 indirectLighting = max(vec3(minLight), ambientLight + torchLighting + skyLighting + ambientSkyLight);
    #endif

    float adjustedAo = 1 - clamp((1 - pow(ambientOcclusion, GAMMA)) * VANILLA_AO_INTENSITY, 0.0, 1.0);

    indirectLighting *= adjustedAo;
    #if VANILLA_LIGHTING != 2
        directSkyLighting *= adjustedAo;
    #endif

    return mat2x3(indirectLighting, directSkyLighting);
}