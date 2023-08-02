vec3 pixelPerfectSkyVector(vec3 v, vec3 sun_dir) {
	vec3 color = hosekWilkieSkyVector(v, sun_dir);

	color *= 0.07;

	return color;
}