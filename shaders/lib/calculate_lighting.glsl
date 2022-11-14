#define lighting_pass

#include "/lib/color_manipulation.glsl"

// Input is not adjusted lightmap coordinates
vec3 getLightColor(in vec2 lightmap, in float sunShading, in float moonShading, in int moonPhase, in int time, in float rain, in float skyShading, in float ambientLightMult, in float minLightMult) {
    float skyTransition = skyTime(time);

    // TODO: find out why this is failing
    // #if VANILLA_COLORS == 0
    //     vec3 torchColor = TORCH_TINT;
    // #else
    //     vec3 torchColor = mix(TORCH_TINT, mix(TORCH_TINT_VANILLA, vec3(1), sqrt(lightmap.x)), VANILLA_COLORS);
    // #endif

    vec3 torchColor = mix(TORCH_TINT, mix(TORCH_TINT_VANILLA, vec3(1), sqrt(lightmap.x)), VANILLA_COLORS);

    vec3 skyColor = mix(mix(NIGHT_SKY_COLOR, DAY_SKY_COLOR, skyTransition), mix(NIGHT_SKY_COLOR_VANILLA, DAY_SKY_COLOR_VANILLA, skyTransition), VANILLA_COLORS);

    vec3 actualSkyLightColor = mix(MOON_COLOR, SUN_COLOR, skyTransition);

    // Multiply each part of the light map with it's color

    vec3 torchLighting = pow2(lightmap.x) * torchColor * BLOCK_LIGHT_MULT;

    vec3 moonLighting = moonShading * fma(cos(float(moonPhase) * 2 * PI * RCP_8), 0.3, 0.7) * MOON_COLOR;
    vec3 sunLighting = sunShading * SUN_COLOR;
    vec3 skyLighting = pow2(lightmap.y) * fma(inversesqrt(rain + 1), 3.4, -2.4) * mix(moonLighting, sunLighting, skyTransition);
    vec3 actualSkyColor = mix(mix(NIGHT_SKY_COLOR, NIGHT_SKY_COLOR_VANILLA, VANILLA_COLORS), mix(DAY_SKY_COLOR, DAY_SKY_COLOR_VANILLA, VANILLA_COLORS), skyTransition);

    // unoptimized EQ: ambientLightMult * (ambientColor + mix(ambientColor, skyColor + actualSkyLightColor, 0.7) * lightmap.y) + skyColor * skyShading * skyLightMult * lightmap.y;
    // vec3 ambientLighting = fma(ambientColor, vec3(ambientLightMult), fma(mix(ambientColor, skyColor + actualSkyLightColor, 0.7), vec3(ambientLightMult), skyColor * skyShading * SKY_LIGHT_MULT) * lightmap.y);
    vec3 ambientLight = ambientLightMult * AMBIENT_COLOR;
    vec3 minLight = minLightMult * AMBIENT_COLOR;
    vec3 ambientSkyLight = ambientLightMult * mix(AMBIENT_COLOR, skyColor + actualSkyLightColor, 0.7) * lightmap.y;
    vec3 skyLight = actualSkyColor * skyShading * lightmap.y;
    
    vec3 ambientLighting = ambientSkyLight + skyLight;

    // Add the lighting togther to get the total contribution of the lightmap the final color.
    vec3 bounceAffectedLighting = skyLighting;
    vec3 lightmapLighting = max(minLight, ambientLight * (1 - clamp(lightmap.y * 3, 0, 1)) + torchLighting + ambientLighting + bounceAffectedLighting);

    // Return the value
    return lightmapLighting;
}

float normalLighting(in vec3 normal, in vec3 lightPos) {
    return max(dot(normal, normalize(lightPos)), 0);
}