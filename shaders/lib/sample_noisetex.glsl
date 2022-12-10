vec4 sampleNoise(in vec2 texcoord) {
	// float offsetX = sin(frameCounter);
	// float offsetY = sin(offsetX * frameCounter);
	// vec2 offset = vec2(offsetX, offsetY);

	vec2 originalCoords = (texcoord * vec2(viewWidth, viewHeight) / noiseTextureResolution);
	vec2 offset = vec2(0);

	return texture(noisetex, mod(originalCoords + offset, 1));
}