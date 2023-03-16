// float gustFunction(in float t, in float smoothness) {
// 	float x = sin((mod(t, 2 * PI) + PI) * 0.5);
// 	return -sin(signedPow(x, smoothness) * PI + PI);
// }

float gustFunction(in float t, in float smoothness) {
	float x = fract(t * 0.5 / PI);
	const float p = 0.75;
	float start = x > p ? 0 : 1;

	return smoothstep(start, 1 - start, x);
}

vec2 windImpulse(in float size, in float rotation, in float directionality, in float offset, in float smoothness, in vec2 position, in float time) {
	float actualRotation = rotation * 2 * PI;

	float positionAlongWindLine = cos(actualRotation) * position.x + sin(actualRotation) * position.y;

	float magnitude = (
			(
				gustFunction((positionAlongWindLine * WIND_PERIOD_CONSTANT + time * WIND_SPEED_CONSTANT) / size + offset * 2 * PI, smoothness)
			)
			* (0.5 + directionality * 0.3) + (0.5 - directionality * 0.3)
		) * size;

	return vec2(cos(actualRotation), sin(actualRotation)) * magnitude * WIND_SIZE_CONSTANT;
}