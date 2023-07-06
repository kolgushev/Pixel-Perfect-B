float skyGradient(float x, float w) {
	return w / (x * x + w);
}

// output is sRGB
vec3 calcSkyColor(in vec3 pos, in vec3 skyColor, in vec3 fogColor) {
	float upDot = clamp(pos.y, 0.0, 1.0);
	vec3 sky = mix(skyColor, fogColor, skyGradient(upDot, 0.05));
	return sky * (skyGradient(upDot, 1.2) * 0.7 + 0.3);
}