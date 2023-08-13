float gustFunction(in float t, in float p) {
	float x = mod(t * 0.5 / PI, 1);

	return smoothstep(
		x < p ? 0 : p,
		x < p ? p : 1,
		x < p ? x : 1 + p - x
		) * 2 - 1;
}

vec2 windImpulse(in float size, in float rotation, in float directionality, in float offset, in float speed, in vec2 position, in float time) {
	float actualRotation = rotation * 2 * PI;

	float positionAlongWindLine = cos(actualRotation) * position.x + sin(actualRotation) * position.y;

	float magnitude = (
			(
				gustFunction((positionAlongWindLine * WIND_PERIOD_CONSTANT + time * speed * WIND_SPEED_CONSTANT) / size + offset * 2 * PI, 0.8)
			)
			* (0.5 + directionality * 0.3) + (0.5 - directionality * 0.3)
		) * size;

	return vec2(cos(actualRotation), sin(actualRotation)) * magnitude * WIND_STRENGTH_CONSTANT;
}

vec2 getCalmWindProfile(in vec2 position, in float time, in float fine) {
	#if defined DIM_OVERWORLD
		return 
			windImpulse(2.35, 0.63 * 0.25, 0.903, 0.15, 1.0, position, time) +
			windImpulse(1.45, 0.17 * 0.25, 0.606, 0.48, 1.0, position, time) +
			windImpulse(1.29, 0.19 * 0.25, 0.697, 0.62, 1.0, position, time) +
			windImpulse(1.14, 0.41 * 0.25, 0.741, 0.19, 1.0, position, time) +
			windImpulse(1.03, 0.85 * 0.25, 0.624, 0.06, 1.0, position, time) +
			(
			windImpulse(0.82, 0.67 * 0.25, 0.714, 0.93, 1.0, position, time) +
			windImpulse(0.50, 0.30 * 0.25, 0.113, 0.59, 1.0, position, time) +
			windImpulse(0.40, 0.85 * 0.25, 0.212, 0.43, 1.0, position, time)
			) * fine
			;
	#elif defined DIM_NETHER
		return 
			windImpulse(2.35 * 0.6, 0.63, 0.903, 0.15, 0.4, position, time) +
			windImpulse(1.45 * 0.6, 0.17, 0.606, 0.48, 0.4, position, time) +
			windImpulse(1.03 * 0.6, 0.85, 0.624, 0.06, 0.4, position, time) +
			windImpulse(1.29 * 0.6, 0.19, 0.697, 0.62, 0.4, position, time)
			;
	#else
		return vec2(0, 0);
	#endif
}

vec2 getStormyWindProfile(in vec2 position, in float time, in float fine) {
	fine = (0.8 + 0.2 * fine);
	#if defined DIM_OVERWORLD
		return 
			windImpulse(2.35 * 2.0, 0.63 * 0.25 + 0.5, 0.903, 0.15, 4.0, position, time) +
			windImpulse(2.05 * 2.0, 0.17 * 0.25 + 0.5, 0.606, 0.48, 4.0, position, time) +
			windImpulse(1.03 * 2.0, 0.85 * 0.25 + 0.5, 0.624, 0.06, 4.0, position, time) +
			windImpulse(1.39 * 2.0, 0.19 * 0.25 + 0.5, 0.697, 0.62, 4.0, position, time) +
			(
			windImpulse(0.95 * 1.4, 0.41 * 0.25 + 0.5, 0.541, 0.84, 4.0, position, time) +
			windImpulse(0.82 * 1.4, 0.67 * 0.25 + 0.5, 0.214, 0.93, 4.0, position, time) +
			windImpulse(0.50 * 1.4, 0.30 * 0.25 + 0.5, 0.113, 0.59, 4.0, position, time) +
			windImpulse(0.40 * 1.4, 0.85 * 0.25 + 0.5, 0.212, 0.43, 4.0, position, time)
			) * fine
			;
	#else
		return vec2(0, 0);
	#endif
}