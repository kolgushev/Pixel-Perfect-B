vec4 fogify(in vec3 position, in vec3 diffuse, in float far, in int isEyeInWater, in float nightVisionEffect) {
    vec3 composite = diffuse.rgb;

    // Render fog in a cylinder shape
    float farRcp = 1 / far;
    float fogFlat = length(position.y);
    float fogTube = length(position.xz) + 16;
    
    // TODO: optimize
    fogFlat = pow2(clamp(fma(fogFlat * farRcp, 7, -6), 0, 1));
    fogTube = pow2(clamp(fma(fogTube * farRcp, 7, -6), 0, 1));
    fogTube = clamp(fogTube + fogFlat, 0, 1);

    float atmosPhog = 0;
    vec3 atmosPhogColor = vec3(0);
    float nigthVisionVisibility = 0;
    if(isEyeInWater == 0) {
        #if defined ATMOSPHERIC_FOG
            atmosPhog = length(position) * ATMOSPHERIC_FOG_DENSITY;
            atmosPhogColor = ATMOSPHERIC_FOG_COLOR;
            atmosPhog = clamp(exp(-atmosPhog), 0, 1);
        #endif
    } else {
        // hijack atmospheric fog calculations for underwater
        switch(isEyeInWater) {
            case 1:
                atmosPhog = ATMOSPHERIC_FOG_DENSITY_WATER;
                atmosPhogColor = ATMOSPHERIC_FOG_COLOR_WATER;
                nigthVisionVisibility = NIGHT_VISION_AFFECTS_FOG_WATER;
                break;
            case 2:
                atmosPhog = ATMOSPHERIC_FOG_DENSITY_LAVA;
                atmosPhogColor = ATMOSPHERIC_FOG_COLOR_LAVA;
                nigthVisionVisibility = NIGHT_VISION_AFFECTS_FOG_LAVA;
                break;
            case 3:
                atmosPhog = ATMOSPHERIC_FOG_DENSITY_POWDER_SNOW;
                atmosPhogColor = ATMOSPHERIC_FOG_COLOR_POWDER_SNOW;
                nigthVisionVisibility = NIGHT_VISION_AFFECTS_FOG_POWDER_SNOW;
                break;
        }

        atmosPhog = length(position) * atmosPhog * (1 - nightVisionEffect * nigthVisionVisibility);

        atmosPhog = clamp(exp(-atmosPhog), 0, 1);
    }

    composite = mix(atmosPhogColor, composite, atmosPhog);

    return vec4(composite, fogTube);
}