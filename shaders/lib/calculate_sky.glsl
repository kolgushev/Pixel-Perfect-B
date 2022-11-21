float skyGradient(float x, float w) {
	return w / fma(x, x, w);
}

// output is sRGB
vec3 calcSkyColor(in vec3 pos, in vec3 skyColor, in vec3 fogColor) {
	float upDot = clamp(pos.y, 0, 1);
	return mix(skyColor, fogColor, skyGradient(upDot, 0.25));
}