#define lighting_pass

float normalLighting(in vec3 normal, in vec3 lightPos) {
    return max(dot(normal, normalize(lightPos)), 0);
}

// Input is not adjusted lightmap coordinates
mat2x3 getLightColor(in vec3 lightAndAO, in vec3 normal, in vec3 normalViewspace, in vec3 sunPosition, in vec3 moonPosition, in int moonPhase, in int time, in float rain, in float nightVisionEffect, in float darknessEffect, in float darknessPulseEffect) {
    float lightBoost = 1 + darknessEffect * 0.9 + darknessPulseEffect * 4 - nightVisionEffect * 0.5;

    vec2 lightmap = lightAndAO.rg;
    float ambientOcclusion = lightAndAO.b;


    // Compute dot product vertex shading from normals
    float sunShading = normalLighting(normalViewspace, sunPosition);
    float moonShading = normalLighting(normalViewspace, moonPosition);

    // Usually this is divided by 2, but we're dividing by more than that to simulate bounce lighting
    float skyShading = fma((normal.y - 1), RCP_3, 1f);

    float skyTransition = skyTime(time);

    vec3 torchColor = mix(TORCH_TINT, mix(TORCH_TINT_VANILLA, vec3(1), sqrt(lightmap.x)), VANILLA_COLORS);

    vec3 skyColor = mix(mix(NIGHT_SKY_COLOR, DAY_SKY_COLOR, skyTransition), mix(NIGHT_SKY_COLOR_VANILLA, DAY_SKY_COLOR_VANILLA, skyTransition), VANILLA_COLORS);

    vec3 actualSkyLightColor = mix(MOON_COLOR, SUN_COLOR, skyTransition);

    // Multiply each part of the light map with it's color

    vec3 torchLighting = gammaCorrection(pow2(lightmap.x) * torchColor, lightBoost) * BLOCK_LIGHT_MULT;

    vec3 moonLighting = moonShading * fma(cos(float(moonPhase) * 2 * PI * RCP_8), 0.3, 0.7) * MOON_COLOR;
    vec3 sunLighting = sunShading * SUN_COLOR;
    // vec3 skyLighting = pow2(lightmap.y) * fma(inversesqrt(rain + 1), 3.4, -2.4) * mix(moonLighting, sunLighting, skyTransition);
    vec3 directSkyLighting = max(vec3(0), fma(inversesqrt(rain + 1), 3.4, -2.4) * mix(moonLighting, sunLighting, skyTransition));
    vec3 actualSkyColor = mix(mix(NIGHT_SKY_COLOR, NIGHT_SKY_COLOR_VANILLA, VANILLA_COLORS), mix(DAY_SKY_COLOR, DAY_SKY_COLOR_VANILLA, VANILLA_COLORS), skyTransition);

    // unoptimized EQ: AMBIENT_LIGHT_MULT * (ambientColor + mix(ambientColor, skyColor + actualSkyLightColor, 0.7) * lightmap.y) + skyColor * skyShading * skyLightMult * lightmap.y;
    // vec3 ambientLighting = fma(ambientColor, vec3(AMBIENT_LIGHT_MULT), fma(mix(ambientColor, skyColor + actualSkyLightColor, 0.7), vec3(AMBIENT_LIGHT_MULT), skyColor * skyShading * SKY_LIGHT_MULT) * lightmap.y);
    float hardcoreMult = inversesqrt(fma(darknessEffect, 0.75, 0.25)) - 1;
    vec3 ambientLight = hardcoreMult * AMBIENT_LIGHT_MULT * AMBIENT_COLOR;
    ambientLight *= (1 - clamp(lightmap.y * 1.5, 0, 1));
    ambientLight += nightVisionEffect * NIGHT_VISION_COLOR;

    vec3 minLight = hardcoreMult * MIN_LIGHT_MULT * AMBIENT_COLOR;
    vec3 ambientSkyLighting = actualSkyColor * skyShading * lightmap.y;
    
    // Add the lighting togther to get the total contribution of the lightmap the final color.
    vec3 indirectLighting = max(vec3(minLight), ambientLight + torchLighting + ambientSkyLighting);

    indirectLighting *= 1 - clamp((1 - pow2(ambientOcclusion)) * VANILLA_AO_INTENSITY, 0, 1);

    // Return the value
    return mat2x3(indirectLighting, directSkyLighting);
}