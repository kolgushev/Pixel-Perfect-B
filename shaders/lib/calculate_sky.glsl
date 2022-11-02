float fogify(float x, float w) {
	return w / fma(x, x, w);
}

// TODO: fix
vec3 calcSkyColor(vec3 pos) {
	float upDot = dot(pos, gbufferModelView[1].xyz);
	return mix(skyColor, fogColor, fogify(max(upDot, 0.0), 0.25)) * RGB_to_ACEScg;
}