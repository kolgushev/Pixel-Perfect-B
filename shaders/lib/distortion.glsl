// Using https://github.com/saada2006/MinecraftShaderProgramming/tree/master/Tutorial%204%20-%20Advanced%20Shadow%20Mapping
vec2 distortShadow(in vec2 position) {

    // float dist = (abs(position.x - position.y) + abs(position.x + position.y)) * 0.5;
    float dist = length(position);
    float distortion = mix(1.0, dist, SHADOW_DISTORTION);

    vec2 distortedPos = position / distortion;

    return distortedPos;
}

vec2 supersampleShift(in vec2 position, in int frameCounter) {
    #if SHADOW_SUPERSAMPLE > 0
        int index = int(mod(frameCounter, superSampleOffsets.length));
        return position * SHADOW_RES_MULT_RCP - superSampleOffsets[index];
    #else
        return position;
    #endif
}

vec2 supersampleSubpixelShift(in vec2 position, in int frameCounter) {
    #if SHADOW_SUPERSAMPLE > 0
        int index = int(mod(frameCounter, superSampleOffsets.length));
        return (position * float(shadowMapResolution) + superSampleOffsets[index]) * (1.0 / float(shadowMapResolution));
    #else
        return position;
    #endif
}

vec2 supersampleSampleShift(in vec2 position) {
    #if SHADOW_SUPERSAMPLE > 0
        vec2 d = mod(position * float(shadowMapResolution), SHADOW_RES_MULT);

        const float s = shadowMapResolution * SHADOW_RES_MULT_RCP;
        
        vec2 u = floor(d) * (s - 1) + d + floor(position * s);

        return u * (1.0 / float(shadowMapResolution));
    #else
        return position;
    #endif
}