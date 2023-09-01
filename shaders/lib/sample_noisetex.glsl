vec4 tile(in vec2 texcoord, in vec2 id, in bool sharp) {

	if(sharp)
		texcoord = floor(texcoord) + 0.5;

	// map texcoord to a 0-tilewidth range
	vec2 texcoordInRange = (mod(texcoord, vec2(NOISETEX_TILES_RES)) + id * NOISETEX_TILES_RES) / (NOISETEX_TILES_RES * NOISETEX_TILES_WIDTH);

	return texture(noisetex, removeBorder(texcoordInRange, 1 / (NOISETEX_TILES_RES * NOISETEX_TILES_WIDTH)));
}