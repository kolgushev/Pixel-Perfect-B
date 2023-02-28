float SDRToHDR(in float x) {
	const float a = 2;
	const float b = 0.95;
	// converts from a 0-1 range to about a 0-6 range
	return 1 / (a - a * x * b) - 1 / a + x;
}

vec3 SDRToHDRColor(in vec3 x) {
	return vec3(SDRToHDR(x.r), SDRToHDR(x.g), SDRToHDR(x.b));
}