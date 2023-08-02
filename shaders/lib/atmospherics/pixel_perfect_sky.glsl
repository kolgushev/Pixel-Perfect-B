
uniform vec3 skyAlbedo;
vec3 pixelPerfectSkyVector(vec3 v, vec3 sun_dir, vec2 stars, float rain, float skyTime) {
	float vy = v.y + 0.05;
	vec3 vec = normalize(vec3(v.x, mix(0.03, vy, smoothstep(0.03, 0.1, vy)), v.z));
	vec3 color = hosekWilkieSkyVector(vec, sun_dir);

	#define A mix(-0.05, -0.2, abs(skyTime))
	color = mix(skyAlbedo * XYZ_to_ACEScg * color, color, smoothstep(A, 0.07, v.y));

	float mixFactor = smoothstep(THUNDER_THRESHOLD, 1, rain) * skyTime;
	color = mix(color, RAINY_SKY_COLOR, mixFactor);
        
	#if defined RAIN_FOG
		vec3 rainColor = gammaCorrection(ATMOSPHERIC_FOG_COLOR_RAIN, RCP_GAMMA);
		rainColor = rainColor * mix(skyTime, 1, 0.65);

		color = mix(color, rainColor, smoothstep(-1.0, -0.2, -normalize(position).y) * smoothstep(0.0, THUNDER_THRESHOLD, rain));
	#else
		vec3 rainColor = vec3(0.0);
	#endif

	color *= 0.07;

	return color;
}