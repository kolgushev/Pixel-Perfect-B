vec3 playerSpace(in vec3 modelPos) {
	#if defined gc_terrain
		return modelPos + chunkOffset;
	#else
		return (gbufferModelViewInverse * (modelViewMatrix * vec4(vaPosition, 1.0))).xyz;
	#endif
}

vec4 playerToClip(in vec3 playerPos) {
	return (projectionMatrix * (gbufferModelView * vec4(playerPos, 1.0)));
}

vec3 playerToView(in vec3 playerPos) {
	return (gbufferModelView * vec4(playerPos, 1.0)).xyz;
}

vec4 viewToClip(in vec3 viewPos) {
	return (projectionMatrix * vec4(viewPos, 1.0));
}