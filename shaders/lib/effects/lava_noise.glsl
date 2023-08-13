float lavaNoise(in vec2 position, in float t) {
	#ifdef SMOOTH_LAVA
		const bool sharpLava = false;
	#else
		const bool sharpLava = true;
	#endif

	#if defined DIM_NETHER
		#define LAVA_SCALE 1
	#else
		#define LAVA_SCALE 2
	#endif

	vec4 noise = tile(position * LAVA_SCALE, NOISE_PERLIN_4D, sharpLava);
	
	#if NOISY_LAVA == 2
		noise = noise - 0.35;
		noise = noise * noise * 20;
	#endif

	return (noise.r * (sin(t) * 0.5 + 0.5) + noise.g * (sin(t + PI * 0.5) * 0.5 + 0.5) + noise.b * (sin(t + PI) * 0.5 + 0.5) + noise.a * (sin(t + PI * 1.5) * 0.5 + 0.5));
}
