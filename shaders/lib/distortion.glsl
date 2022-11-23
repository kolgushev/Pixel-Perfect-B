// Using https://github.com/saada2006/MinecraftShaderProgramming/tree/master/Tutorial%204%20-%20Advanced%20Shadow%20Mapping
vec2 distortShadow(in vec2 position, in int frameCounter){
    vec2 jitteredPos = position;

    #if SHADOW_SUPERSAMPLE > 0
        #if SHADOW_SUPERSAMPLE == 1
            vec2 superSampleOffsets[4] = vec2[4](
                vec2(-0.5, -0.5),
                vec2(-0.5, 0.5),
                vec2(0.5, -0.5),
                vec2(0.5, 0.5)
            );
        #elif SHADOW_SUPERSAMPLE == 2
            vec2 superSampleOffsets[16] = vec2[16](
                vec2(0.375, 0.375),
                vec2(0.875, 0.875),
                vec2(0.125, 0.875),
                vec2(0.875, 0.125),
                vec2(0.125, 0.125),
                vec2(0.875, 0.375),
                vec2(0.375, 0.625),
                vec2(0.625, 0.125),
                vec2(0.375, 0.875),
                vec2(0.625, 0.625),
                vec2(0.125, 0.375),
                vec2(0.875, 0.625),
                vec2(0.375, 0.125),
                vec2(0.625, 0.875),
                vec2(0.125, 0.625),
                vec2(0.625, 0.375)
            );
        #endif

        int index = int(mod(frameCounter, superSampleOffsets.length));

        vec2 currentOffset = superSampleOffsets[index] * (1.0 / float(shadowMapResolution));

        jitteredPos += currentOffset;
    #endif

    // float dist = (abs(position.x - position.y) + abs(position.x + position.y)) * 0.5;
    float dist = length(jitteredPos);
    float distortion = mix(1.0, dist, SHADOW_DISTORTION);
    return jitteredPos / distortion;
}