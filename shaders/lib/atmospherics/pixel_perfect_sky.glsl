vec3 pixelPerfectSkyVector(in vec3 v, in vec3 sun_dir, in vec2 stars, in float rain, in float skyTime) {
	v = normalize(v);
	vec3 vecSun = normalize(sun_dir);
	float dt = dot(vecSun, UP);
	float expandSky = EXPAND_SKY * abs(vecSun.y);
	vec3 vec = vec3(v.x, max(expandSky, v.y + expandSky), v.z);
	// vec3 color = hosekWilkieSkyVector(normalize(vec), vecSun);
	vec3 color = preethamSkyVector(v, vecSun);

	if(v.y < 0) {
		vec = vec3(v.x, max(expandSky, -v.y + expandSky), v.z);
		vecSun = normalize(vec3(sun_dir.x, -sun_dir.y, sun_dir.z));
		// apply fresnel to mirror copy
		float fresnelFactor = pow(1.0 - dot(v, UP), 5.0) * (1.0 - REFLECTANCE_WATER) + REFLECTANCE_WATER;

		vec3 colorMod = vec3(0.1, 0.35, 1.5);
		colorMod *= clamp(dt, 0.0, 1.0) * SUN_COLOR + clamp(-dt, 0.0, 1.0) * MOON_COLOR;

		colorMod += hosekWilkieSkyVector(normalize(vec), vecSun) / fresnelFactor;


		#define SKY_FOG_DENSITY 0.01
		float fogFactor = exp(-SKY_FOG_DENSITY / (abs(v.y) + 0.01));
		color = mix(color, colorMod, fogFactor);
	}

	color *= 0.05;

	float mixFactor = smoothstep(THUNDER_THRESHOLD, 1, rain) * skyTime;
	color = mix(color, RAINY_SKY_COLOR, mixFactor);
        
	#if defined RAIN_FOG
		vec3 rainColor = ATMOSPHERIC_FOG_COLOR_RAIN;
		rainColor = rainColor * mix(skyTime, 1, 0.65);

		color = mix(color, rainColor, smoothstep(-1.0, -0.0, -normalize(v).y) * smoothstep(0.0, THUNDER_THRESHOLD, rain));
	#else
		vec3 rainColor = vec3(0.0);
	#endif


	return color;
}