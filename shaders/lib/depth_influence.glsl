float calcDepthInfluence(in vec3 viewSpace, in vec3 sampleViewSpace, in vec3 normal, in float pixelSize, in const bool distanceCorrection, in const bool sizeCorrection, in const bool forceNormalCorrection) {
    vec3 sampleDifference = sampleViewSpace - viewSpace;
    float sampleDistance = length(sampleDifference);
    
    // account for directionality of light

    #ifdef COLORED_LIGHT_ONLY
        float influence = 1;
        
        if(forceNormalCorrection) {
            vec3 lightNormal = normalize(sampleDifference);
            influence = clamp(dot(normal, lightNormal) + SELF_ILLUMINATION, 0, 1);
        }

        if(distanceCorrection) {
            influence *= clamp(fma(sampleDistance, -MAX_LIGHT_PROPAGATION_INVERSE, 1f), 0, 1);
        }
    #else
        vec3 lightNormal = normalize(sampleDifference);
        float influence = clamp(dot(normal, lightNormal) + SELF_ILLUMINATION, 0, 1);
        if(distanceCorrection) {
            // inverse square law for light
            influence /= pow2(sampleDistance);
        }
    #endif

    if(sizeCorrection) {
        // divide by pixel size (to counteract more pixels being visible when closer)
        influence /= pixelSize;
    }

    return float(influence);
}
