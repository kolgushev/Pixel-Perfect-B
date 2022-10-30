#include "/program/base/setup.vsh"

out vec4 stars;

void main() {
	// transform vertices
	position = chunkOffset + vaPosition;

	gl_Position = toViewspace(projectionMatrix, modelViewMatrix, position);
	texcoord = vaUV0;
	light = vec3((LIGHT_MATRIX * vec4(vaUV2, 1, 1)).xy, 1);
	color = vaColor;
	normal = vaNormal;

	stars = vec4(color.rgb, float(color.r == color.g && color.g == color.b && color.r > 0.0));
}