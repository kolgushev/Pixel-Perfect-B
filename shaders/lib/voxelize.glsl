// returns block positions mapped onto 2D plane
vec2 flatten(in vec3 center) {
	vec2 blockPos = vec2(0);
	blockPos.x = int(center.y) % int(SHADOW_MAP_SQRT_NUM_LAYERS);
	blockPos.y = floor(center.y / SHADOW_MAP_SQRT_NUM_LAYERS);

	return floor(center.xz) + floor(blockPos) * SHADOW_MAP_RANGE;
}

// returns block positions 
vec2 voxelize(in vec3 center) {
	vec2 blockPos = flatten(center) / (SHADOW_MAP_RANGE * SHADOW_MAP_SQRT_NUM_LAYERS);

	blockPos = removeBorder(blockPos, 1 / shadowMapResolution);

	return blockPos;
}