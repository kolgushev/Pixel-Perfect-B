float lavaNoise(in vec2 position, in float t) {
	#define noise_f(x) tile(position * (x), vec2(1, 0), false)
	#if defined DIM_NETHER
		#define LAVA_SCALE 1
	#else
		#define LAVA_SCALE 2
	#endif
	vec4 noise = noise_f(LAVA_SCALE);
	#if NOISY_LAVA == 2
		noise = pow2(noise - 0.3) * 20;
	#endif

	return (noise.r * (sin(t) * 0.5 + 0.5) + noise.g * (sin(t + PI * 0.5) * 0.5 + 0.5) + noise.b * (sin(t + PI) * 0.5 + 0.5) + noise.a * (sin(t + PI * 1.5) * 0.5 + 0.5));
}
