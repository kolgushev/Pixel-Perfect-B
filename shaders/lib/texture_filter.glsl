// Full credit to https://www.youtube.com/watch?v=d6tp43wZqps for the design and implementation of the filtering, this is mostly just a port
vec4 textureFiltered(in sampler2D tex, in vec2 uv, in bool clamping) {
	vec2 resolution = textureSize(tex, 0);

	vec2 boxSize = clamp(fwidth(uv) * resolution, EPSILON, 1.0);
	vec2 texelCoord = uv * resolution - 0.5 * boxSize;
	vec2 texelOffset = smoothstep(1 - boxSize, vec2(1.0), fract(texelCoord));
	vec2 bilinearSamplePos = (floor(texelCoord) + 0.5 + texelOffset) / resolution;
	
	vec2[5] sampleLocations = bilinearCoordinateShift(tex, bilinearSamplePos, resolution, clamping);

	// Initialize an array to store the samples
    vec4 samples[4] = vec4[4](vec4(0), vec4(0), vec4(0), vec4(0));

    // Sample the texture at four positions
    for (int i = 0; i < 4; i++) {
        samples[i] = textureGrad(tex, sampleLocations[i], dFdx(uv), dFdy(uv));
    }

    // Interpolate between the first two samples based on the y position
    samples[0] = mix(samples[0], samples[1], sampleLocations[4].y);
    // Interpolate between the last two samples based on the y position
    samples[1] = mix(samples[2], samples[3], sampleLocations[4].y);

    // Interpolate between the two interpolated samples based on the x position
    vec4 result = mix(samples[0], samples[1], sampleLocations[4].x);
    return result;
}