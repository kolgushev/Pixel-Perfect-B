float SDRToHDR(in float sdr) {
	const float a = 10;
	const float b = 0.99;
	// converts from a 0-1 range to about a 0-10 range
	return 1 / (a - a * x * b) - 1 / a + x;
}