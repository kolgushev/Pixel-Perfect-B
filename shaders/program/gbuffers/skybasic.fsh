#include "/program/base/setup.fsh"

in vec4 stars;
uniform mat4 gbufferModelView;
uniform vec3 fogColor;
uniform vec3 skyColor;

float fogify(float x, float w) {
	return w / fma(x, x, w);
}

vec3 calcSkyColor(vec3 pos) {
	float upDot = dot(pos, gbufferModelView[1].xyz);
	return mix(skyColor, fogColor * sRGB_to_ACEScg, fogify(max(upDot, 0.0), 0.25));
}

void main() {
	vec3 skyColor = stars.a > 0.5 ? stars.rgb : calcSkyColor(normalize(projectInverse(vec3(position.xy / vec2(viewWidth, viewHeight) * 2 - 1, 1))));
	
	diffuseBuffer = opaque(skyColor);
	normalBuffer = opaque(normal);
	lightmapBuffer = vec4(light, 0);
	genericBuffer.xyz = position;

	maskBuffer = vec4(1, 0, 0, 0);
}