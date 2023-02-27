// float gustFunction(in float t, in float smoothness) {
// 	float x = sin((mod(t, 2 * PI) + PI) * 0.5);
// 	return -sin(signedPow(x, smoothness) * PI + PI);
// }

float gustFunction(in float t, in float sharpness) {
	float x = mod(t * 0.5 / PI, 1);
	float p = sharpness;

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