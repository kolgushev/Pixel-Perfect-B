float SDRToHDR(in float x) {
	const float a = 2;
	const float b = 0.95;
	// converts from a 0-1 range to about a 0-6 range
	return 1 / (a - a * x * b) - 1 / a + x;
}

vec2 SDRToHDR(in vec2 x) {
	return vec2(SDRToHDR(x.r), SDRToHDR(x.g));
}
vec3 SDRToHDR(in vec3 x) {
	return vec3(SDRToHDR(x.r), SDRToHDR(x.g), SDRToHDR(x.b));
}
vec4 SDRToHDR(in vec4 x) {
	return vec4(SDRToHDR(x.r), SDRToHDR(x.g), SDRToHDR(x.b), SDRToHDR(x.a));
}