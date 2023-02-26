vec2 getCoords(in int id) {
	// pseudorandom number generator such that an input id of 0 yields an offset of 0
	float offsetX = sin(8 * id);
	float offsetY = sin(7 * offsetX * pow2(id));
	vec2 offset = vec2(offsetX, offsetY);

	vec2 originalCoords = (texcoord * vec2(viewWidth, viewHeight) / noiseTextureResolution);

	return mod(originalCoords + offset, 1) * NOISETEX_TILES_RES;
}

vec4 sampleNoise(in vec2 texcoord, in int id, in vec2 offset) {
	// vec2 offset = vec2(0);

	return tile(getCoords(id), offset);
}