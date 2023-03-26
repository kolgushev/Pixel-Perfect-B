float normalLighting(in vec3 normal, in vec3 lightPos) {
    #if VANILLA_LIGHTING != 2 && defined SHADOWS_ENABLED
        return clamp(dot(normal, normalize(lightPos)) * 6, 0, 1);
    #else
        return max(dot(normal, normalize(lightPos)), 0);
    #endif
}

float basicDirectShading(in float skyLight) {
    return pow2(clamp((skyLight - 1 + RCP_3) * 3, 0, 1));
}

float rainMultiplier(in float rain)  {
    return max(0, inversesqrt(rain + 1) * 3.4 - 2.4);
}

vec3 actualSkyColor(in float skyTransition) {
    return mix(mix(NIGHT_SKY_COLOR, NIGHT_SKY_COLOR_VANILLA, VANILLA_COLORS), mix(DAY_SKY_COLOR, DAY_SKY_COLOR_VANILLA, VANILLA_COLORS), skyTransition);
}

vec3 lightningFlash(in float isLightning, in float rain) {
    #if !defined DIM_NO_RAIN
        return isLightning * rain * LIGHTNING_FLASHES * 25 * LIGHTNING_FLASH_TINT;
    #else
        return vec3(0);
    #endif
}

// Input is not adjusted lightmap coordinates
mat2x3 getLightColor(in vec3 lightAndAO, in vec3 normal, in vec3 normalViewspace, in vec3 sunPosition, in vec3 moonPosition, in float moonBrightness, in float skyTransition, in float rain, in float directLightMult, in float nightVisionEffect, in float darknessEffect, in float darknessPulseEffect, in float isLightning, in sampler2D vanillaLightTex) {

    vec2 lightmap = lightAndAO.rg;
    float ambientOcclusion = lightAndAO.b;

    // Usually this is divided by 2, but we're dividing by more than that to simulate bounce lighting
    float skyShading = (normal.y - 1) * RCP_3 + 1.0;
    
    #if VANILLA_LIGHTING != 2

        // using texture2D instead of texture since the Optifine-provided varying block atlas is also called texture
        vec3 indirectLighting = texture2D(vanillaLightTex, vec2(lightmap.r, mix(0.0313, lightmap.g, VANILLA_LIGHTING_SKY_BLEED))).rgb - VANILLA_NATURAL_AMBIENT_LIGHT;
        vec3 directSkyLighting = texture2D(vanillaLightTex, lightmap).rgb - VANILLA_NATURAL_AMBIENT_LIGHT;

        indirectLighting = max(indirectLighting, 0.0);
        directSkyLighting = max(directSkyLighting, 0.0);

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

            float skyShading = mix(moonShading, sunShading, skyTransition);

            directSkyLighting *= skyShading;
        #endif

        vec3 ambientLight = AMBIENT_LIGHT_MULT * (1 - darknessEffect * 0.8) * max(1 - darknessPulseEffect * 3.0, 0.0) * AMBIENT_COLOR;

        #if STREAMER_MODE == -1
            ambientLight += vec3(0.8, 0.9, 1.0) * 2.0;
        #else
            ambientLight += nightVisionEffect * NIGHT_VISION_COLOR;
        #endif

        indirectLighting += ambientLight + lightningFlash(isLightning, rain) * skyShading * pow2(max(lightmap.y - 0.0313, 0));

    #else
        float lightBoost = BLOCK_LIGHT_POWER + darknessEffect * 0.9 + darknessPulseEffect * 4 - nightVisionEffect * 0.5;

        // Compute dot product vertex shading from normals
        float sunShading = normalLighting(normalViewspace, sunPosition);
        float moonShading = normalLighting(normalViewspace, moonPosition);


        vec3 torchColor = mix(TORCH_TINT, mix(TORCH_TINT_VANILLA, vec3(1), sqrt(lightmap.x)), VANILLA_COLORS);

        vec3 skyColor = mix(mix(NIGHT_SKY_COLOR, DAY_SKY_COLOR, skyTransition), mix(NIGHT_SKY_COLOR_VANILLA, DAY_SKY_COLOR_VANILLA, skyTransition), VANILLA_COLORS);

        // Multiply each part of the light map with it's color

        vec3 torchLighting = gammaCorrection(pow2(lightmap.x) * torchColor, lightBoost) * BLOCK_LIGHT_MULT;

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
        ambientLight *= (1 - clamp(lightmap.y * 1.5, 0, 1));
        #if STREAMER_MODE == -1
            ambientLight += vec3(0.8, 0.9, 1.0) * 2.0;
        #else
            ambientLight += nightVisionEffect * NIGHT_VISION_COLOR;
        #endif

        vec3 minLight = hardcoreMult * MIN_LIGHT_MULT * MIN_LIGHT_COLOR;
        // technically the pow2 here isn't accurate, but it makes the falloff near the edges of the light look better
        vec3 ambientSkyLighting = (actualSkyColor(skyTransition) + lightningFlash(isLightning, rain)) * skyShading * pow2(lightmap.y);
        
        // Add the lighting togther to get the total contribution of the lightmap the final color.
        vec3 indirectLighting = max(vec3(minLight), ambientLight + torchLighting + ambientSkyLighting);
    #endif

    float adjustedAo = 1 - clamp((1 - pow2(ambientOcclusion)) * VANILLA_AO_INTENSITY, 0, 1);

    indirectLighting *= adjustedAo;
    #if VANILLA_LIGHTING != 2
        directSkyLighting *= adjustedAo;
    #endif

    return mat2x3(indirectLighting, directSkyLighting);
}