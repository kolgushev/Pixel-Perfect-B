// returns [alignedPos1, alignedPos2, alignedPos3, alignedPos4, mixingGradient]
vec2[5] bilinearCoordinateShift(in sampler2D tex, in vec2 uv, in bool clamping) {
    vec2 resolution = textureSize(tex, 0);
    vec2 texResolution = resolution * TEXELS_PER_BLOCK;

    vec2 minSampleCoords = floor(uv * texResolution) / texResolution;
    vec2 maxSampleCoords = minSampleCoords + (1 - 0.5 * TEXELS_PER_BLOCK) / texResolution;

    uv += 0.5 / resolution;

    // Calculate the position within the texture bounds
    vec2 samplePositionWithinBounds = mod(uv * resolution, 1);

    uv = (floor(uv * resolution)) / resolution;

    vec2 uvMod = uv;

    // Initialize an array to store the samples
    vec2 samples[5] = vec2[5](vec2(0), vec2(0), vec2(0), vec2(0), vec2(0));

    // Sample the texture at four positions
    for (int i = 0; i < 4; i++) {
        uvMod = uv + vec2(superSampleOffsets4[i] / resolution);

        if(clamping) {
            uvMod = clamp(uvMod, minSampleCoords, maxSampleCoords);
        }
        samples[i] = uvMod;
    }

    samples[4] = samplePositionWithinBounds;

    return samples;
}