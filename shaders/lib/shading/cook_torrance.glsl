// Referencing https://graphicscompendium.com/gamedev/15-pbr
// and https://graphicscompendium.com/references/cook-torrance


vec3 fresnelSchlick(in vec3 normalizedLight, in vec3 half, in vec3 F0) {
	return F0 + (1.0 - F0) * pow(1.0 - dot(normalizedLight, half), 5.0);
}

float subGeometryGGX(in vec3 x, in vec3 normal, in vec3 half, in float roughness2) {
	// basically the same as multiplying by \chi
	float xDotN = dot(x, normal);
	float xDotH = dot(x, half);

	if(xDotN * xDotH <= 0.0) {
		return 0.0;
	}

	float cosTheta = xDotN / (length(x) * length(normal));
	float cosTheta2 = cosTheta * cosTheta;
	float tan2Theta = (1.0 - cosTheta2) / cosTheta2;

	return 2.0 / (1.0 + sqrt(1.0 + roughness2 * tan2Theta));
}

float geometryGGX(in vec3 light, in vec3 view, in vec3 normal, in vec3 half, in float roughness2) {
	return subGeometryGGX(view, normal, half, roughness2) * subGeometryGGX(light, normal, half, roughness2);
}

float geometryCookTorrance(in vec3 light, in vec3 view, in vec3 normal, in vec3 half, in float roughness2) {
	float coeff = 2.0 * dot(normal, half) / dot(view, half);
	return min(1.0, min(coeff * dot(normal, view), coeff * dot(light, normal)));
}

float distributionGGX(in vec3 normal, in vec3 half, in float roughness2) {
	float nDotM = dot(normal, half);
	#if defined USE_LIGHT_RADIUS_HACK
		// this is a hack to approximate non-point light sources. Need to figure out how to do this for real someday.
		nDotM = min(nDotM + 0.0002, 1.0);
	#endif

	float cosTheta = nDotM / (length(normal) * length(half));
	float cosTheta2 = cosTheta * cosTheta;
	float tan2Theta = (1.0 - cosTheta2) / cosTheta2;

	return roughness2 / (PI * pow(nDotM * nDotM * (roughness2 + tan2Theta), 2.0));
}

float distributionBlinnPhong(in vec3 normal, in vec3 half, in float roughness2) {
	float nDotM = dot(normal, half);

	#if defined USE_LIGHT_RADIUS_HACK
		nDotM = min(nDotM + 0.0002, 1.0);
	#endif

	return pow(nDotM, 2 / roughness2 - 2) / (PI * roughness2);
}

vec3 cookTorranceSingleLight(in vec3 normal, in vec3 position, in vec3 relativeLightPosition /* from surface to light source */, in vec3 albedo, in vec3 F0, in float roughness, in bool isMetal, in vec3 lightColor) {
	if(dot(normal, relativeLightPosition) <= 0.0) {
		return vec3(0.0);
	}

	// Does not include ambient light so that multiple lights can be summed up
	vec3 normalizedLight = normalize(relativeLightPosition);
	vec3 normalizedView = normalize(-position);

	// correct for when dot(normal, view) < 0 (this can happen with normal mapping)
	if(dot(normal, normalizedView) < 0.0) {
		normalizedView = reflect(normalizedView, normal);
	}

	vec3 half = normalize(normalizedLight + normalizedView);

	float roughness2 = roughness * roughness;

	#if FRESNEL_MODEL == 0
		vec3 F = fresnelSchlick(normalizedLight, half, F0);
	#endif

	#if GEOMETRY_MODEL == 0
		float G = geometryGGX(normalizedLight, normalizedView, normal, half, roughness2);
	#elif GEOMETRY_MODEL == 1
		float G = geometryCookTorrance(normalizedLight, normalizedView, normal, half, roughness2);
	#endif

	#if defined USE_LIGHT_RADIUS_HACK
		roughness2 = min(roughness2 + 0.00001, 1.0);
	#endif
	#if DISTRIBUTION_MODEL == 0
		float D = distributionGGX(normal, half, roughness2);
	#elif DISTRIBUTION_MODEL == 1
		float D = distributionBlinnPhong(normal, half, roughness2);
	#endif

	// lambertian diffuse * dot(n, l)
	vec3 diffuse = vec3(0.0);
	if(!isMetal) {
		diffuse = albedo * RCP_PI * dot(normal, normalizedLight) * (1.0 - F);
	}
	// Cook-Torrance specular * dot(n, l)
	vec3 specular = D * G * F / (4.0 * dot(normal, normalizedView));

	return lightColor * (diffuse + specular);
}