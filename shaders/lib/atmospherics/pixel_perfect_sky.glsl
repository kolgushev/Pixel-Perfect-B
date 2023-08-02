vec3 pixelPerfectSkyVector(vec3 v, vec3 sun_dir) {
	vec3 color = hosekWilkieSkyVector(v, sun_dir);
	color = mix(vec3(0.025, 0.088, 0.29) * luminance(color), color, smoothstep(-0.02, 0.0, v.y));

	color *= 0.07;


	return color;
}