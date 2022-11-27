vec4 fogify(in vec3 position, in vec3 diffuse, in float far) {

    // Render fog in a cylinder shape
    float farRcp = 1 / far;
    float fogTube = length(position.xz) + 16;
    float fogFlat = length(position.y);
    
    // TODO: optimize
    fogFlat = pow2(clamp(fma(fogFlat * farRcp, 7, -6), 0, 1));
    fogTube = pow2(clamp(fma(fogTube * farRcp, 7, -6), 0, 1));
    fogTube = clamp(fogTube + fogFlat, 0, 1);

    vec3 composite = diffuse.rgb;

    #if defined ATMOSPHERIC_FOG
        float atmosPhog = length(position) * ATMOSPHERIC_FOG_DENSITY;
        atmosPhog = clamp(atmosPhog / (1 + atmosPhog), 0, 1);

        composite = mix(composite, ATMOSPHERIC_FOG_COLOR, atmosPhog);
    #endif

    return vec4(composite, fogTube);
}