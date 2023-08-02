
uniform vec3 skyAlbedo;
vec3 pixelPerfectSkyVector(vec3 v, vec3 sun_dir, vec2 stars, float rain, float skyTime) {
	vec3 vec = vec3(v.x, max(EXPAND_SKY, v.y + EXPAND_SKY), v.z);
	vec3 vecSun = vec3(sun_dir.x, sun_dir.y, sun_dir.z);
	vec3 color = hosekWilkieSkyVector(normalize(vec), normalize(vecSun));

	if(v.y < 0) {
		vec3 vec = vec3(v.x, max(EXPAND_SKY, -v.y + EXPAND_SKY), v.z);
		vec3 vecSun = vec3(sun_dir.x, -sun_dir.y, sun_dir.z);
		// use schlick approximation
		float fresnelFactor = pow(1.0 - dot(v, UP), 5.0) * (1.0 - REFLECTANCE_WATER) + REFLECTANCE_WATER;

		vec3 colorMod = vec3(0.05, 0.2, 1.0) + hosekWilkieSkyVector(normalize(vec), normalize(vecSun)) / fresnelFactor;

		#define SKY_FOG_DENSITY 0.01
		float fogFactor = exp(-SKY_FOG_DENSITY / (abs(v.y) + 0.01));
		color = mix(color, colorMod, fogFactor);
	}

	// apply fresnel to mirror copy

	float mixFactor = smoothstep(THUNDER_THRESHOLD, 1, rain) * skyTime;
	color = mix(color, RAINY_SKY_COLOR, mixFactor);
        
	#if defined RAIN_FOG
		vec3 rainColor = gammaCorrection(ATMOSPHERIC_FOG_COLOR_RAIN, RCP_GAMMA);
		rainColor = rainColor * mix(skyTime, 1, 0.65);

		color = mix(color, rainColor, smoothstep(-1.0, -0.2, -normalize(position).y) * smoothstep(0.0, THUNDER_THRESHOLD, rain));
	#else
		vec3 rainColor = vec3(0.0);
	#endif

	color *= 0.05;

	return color;
}