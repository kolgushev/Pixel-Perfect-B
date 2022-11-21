#define lighting_pass

#include "/lib/color_manipulation.glsl"
#include "/lib/to_viewspace.glsl"

float normalLighting(in vec3 normal, in vec3 lightPos) {
    return max(dot(normal, normalize(lightPos)), 0);
}

// Input is not adjusted lightmap coordinates
vec3 getLightColor(in vec3 lightAndAO, in vec3 normal, in vec3 normalViewspace, in vec3 sunPosition, in vec3 moonPosition, in int moonPhase, in int time, in float rain) {
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

    vec3 torchLighting = pow2(lightmap.x) * torchColor * BLOCK_LIGHT_MULT;

    vec3 moonLighting = moonShading * fma(cos(float(moonPhase) * 2 * PI * RCP_8), 0.3, 0.7) * MOON_COLOR;
    vec3 sunLighting = sunShading * SUN_COLOR;
    vec3 skyLighting = pow2(lightmap.y) * fma(inversesqrt(rain + 1), 3.4, -2.4) * mix(moonLighting, sunLighting, skyTransition);
    vec3 actualSkyColor = mix(mix(NIGHT_SKY_COLOR, NIGHT_SKY_COLOR_VANILLA, VANILLA_COLORS), mix(DAY_SKY_COLOR, DAY_SKY_COLOR_VANILLA, VANILLA_COLORS), skyTransition);

    // unoptimized EQ: AMBIENT_LIGHT_MULT * (ambientColor + mix(ambientColor, skyColor + actualSkyLightColor, 0.7) * lightmap.y) + skyColor * skyShading * skyLightMult * lightmap.y;
    // vec3 ambientLighting = fma(ambientColor, vec3(AMBIENT_LIGHT_MULT), fma(mix(ambientColor, skyColor + actualSkyLightColor, 0.7), vec3(AMBIENT_LIGHT_MULT), skyColor * skyShading * SKY_LIGHT_MULT) * lightmap.y);
    vec3 ambientLight = AMBIENT_LIGHT_MULT * AMBIENT_COLOR;
    vec3 minLight = MIN_LIGHT_MULT * AMBIENT_COLOR;
    vec3 skyLight = actualSkyColor * skyShading * lightmap.y;
    
    // Add the lighting togther to get the total contribution of the lightmap the final color.
    vec3 bounceAffectedLighting = skyLighting;
    vec3 lightmapLighting = max(vec3(0), ambientLight * (1 - clamp(lightmap.y * 8, 0, 1)) + torchLighting + skyLight + bounceAffectedLighting);

    lightmapLighting *= 1 - clamp((1 - pow2(ambientOcclusion)) * VANILLA_AO_INTENSITY, 0, 1);

    // Return the value
    return lightmapLighting;
}