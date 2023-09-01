#if defined DIM_TWILIGHT
	vec3 transitionSky(in float transition, in vec3 vec, in vec3 vecSun) {
		vec3 daySky = hosekWilkieSkyVector(vec, vecSun);
		vec3 nightSky = mix(NIGHT_SKY_EDGE_COLOR, NIGHT_SKY_TOP_COLOR, smoothstep(0.0, 0.33, vec.y));
		return daySky * 0.7 + nightSky;
	}
#else
	vec3 transitionSky(in float transition, in vec3 vec, in vec3 vecSun) {
		vec3 daySky = vec3(0.0);
		vec3 nightSky = vec3(0.0);

		if(transition > 0.0) {
			daySky = hosekWilkieSkyVector(vec, vecSun);
		}
		if(transition < 1.0) {
			nightSky = mix(NIGHT_SKY_EDGE_COLOR, NIGHT_SKY_TOP_COLOR, clamp(vec.y, 0.0, 1.0));
		}

		return mix(nightSky, daySky, transition);
	}
#endif

vec3 pixelPerfectSkyVector(in vec3 v, in vec3 sun_dir, in vec2 stars, in float rain, in float skyTime) {
	v = normalize(v);
	vec3 vecSun = normalize(sun_dir);
	float dt = dot(vecSun, UP);
	float transition = smoothstep(-0.2, 0.0, dt);
	float expandSky = EXPAND_SKY * abs(vecSun.y);
	vec3 vec = vec3(v.x, max(expandSky, v.y + expandSky), v.z);
	vec3 color = transitionSky(transition, normalize(vec), vecSun);

	#if defined HORIZON_AS_OCEAN
		if(v.y < 0.0) {
			vec = vec3(v.x, max(expandSky, -v.y + expandSky), v.z);
			vecSun = normalize(vec3(sun_dir.x, -sun_dir.y, sun_dir.z));
			// apply fresnel to mirror copy
			float fresnelFactor = pow(1.0 - dot(v, UP), 5.0) * (1.0 - REFLECTANCE_WATER) + REFLECTANCE_WATER;

			vec3 colorMod = vec3(0.1, 0.35, 1.5);
			colorMod *= clamp(dt, 0.0, 1.0) * SUN_COLOR + clamp(-dt, 0.0, 1.0) * MOON_COLOR;

			vec3 specular = transitionSky(transition, normalize(vec), vecSun);
			
			// technically incorrect, but allows the sun to appear circular and not as a point
			specular += (
					pow(smoothstep(0.97, 1.0, dot(v, vecSun)), 8.0) * 0.9
					+ pow(smoothstep(0.5, 1.0, dot(v, vecSun)), 2.0) * 0.1
				)
				* smoothstep(-0.1, 0.1, dt)
				* SUN_COLOR * directLightMult;

			colorMod += specular / fresnelFactor;


			#define SKY_FOG_DENSITY 0.01
			float fogFactor = exp(-SKY_FOG_DENSITY / (abs(v.y) + 0.01));
			fogFactor *= 1.0 - pow(1.0 - smoothstep(0.0, 0.05, -v.y), 10.0);
			color = mix(color, colorMod, fogFactor);
		}
	#endif

	color *= 0.1;

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