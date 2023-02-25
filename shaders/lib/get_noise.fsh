vec2 grid2(in float i, in vec2 cells) {
    float xPos = i * cells.x;
    return mod(vec2(xPos, floor(xPos) * cells.y), 1);
}

vec4 getNoise(in int noiseTextureResolution, in float i, in int level) {
	vec2 noiseRes = vec2(NOISETEX_TILES_RES);
	vec2 noiseResInverse = 1 / noiseRes;
	float noiseArea = pow2(NOISETEX_TILES_RES);
	vec2 screenRes = vec2(viewWidth, viewHeight);
	// 0, 1 screen range to noise range
	vec2 res = screenRes * noiseResInverse;
	
	vec2 loopingSample = texcoord * res;
	vec4 noise = texture(noisetex, loopingSample);
	if(level == 0) return noise;
	
	loopingSample = grid2((noiseArea * noise.r + i), noiseResInverse) * res;

	vec4 noise_ = texture(noisetex, loopingSample);
	if(level == 1) return noise_;

	loopingSample = grid2((noiseArea * noise_.r + frameCounter), noiseResInverse) * res;

	vec4 noiseTemporal = texture(noisetex, loopingSample);
	if(level == 2) return noiseTemporal;
	
	loopingSample = grid2((noiseArea * noise_.r + frameCounter) * (1 - TEMPORAL_UPDATE_SPEED)), noiseResInverse) * res;
	
	vec4 noiseTemporalSmooth = texture(noisetex, loopingSample);
	if(level == 3) return noiseTemporalSmooth;
}