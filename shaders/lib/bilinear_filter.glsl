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

vec4 textureBilinear(in sampler2D tex, in vec2 uv, in bool clamping) {
    vec2 sampleLocations[5] = bilinearCoordinateShift(tex, uv, clamping);

    // Initialize an array to store the samples
    vec4 samples[4] = vec4[4](vec4(0), vec4(0), vec4(0), vec4(0));

    // Sample the texture at four positions
    for (int i = 0; i < 4; i++) {
        samples[i] = texture2D(tex, sampleLocations[i]);
    }

    // Interpolate between the first two samples based on the y position
    samples[0] = mix(samples[0], samples[1], sampleLocations[4].y);
    // Interpolate between the last two samples based on the y position
    samples[1] = mix(samples[2], samples[3], sampleLocations[4].y);

    // Interpolate between the two interpolated samples based on the x position
    vec4 result = mix(samples[0], samples[1], sampleLocations[4].x);
    return result;
}