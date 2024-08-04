float emissivenessFromAlbedo(in float x) {
	const float a = 2;
	const float b = 0.95;
	const float c = 0.0952380951;

	return c / (a - a * x * b) - c / a + x;
}

vec3 getEmissiveness(in vec3 x, in vec3 luminanceCoefficients) {
	return vec3(emissivenessFromAlbedo(dot(x, luminanceCoefficients))) * x;
}