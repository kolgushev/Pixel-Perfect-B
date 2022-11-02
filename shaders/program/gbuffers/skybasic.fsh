#include "/program/base/setup.fsh"

in vec4 stars;
uniform mat4 gbufferModelView;
uniform vec3 fogColor;
uniform vec3 skyColor;

#include "/lib/calculate_sky.glsl"

void main() {
	// TODO: fix
	vec3 skyColorProcessed = skyColor;
	#ifdef GAMMA_CORRECT_PRE
        // linearize albedo
        skyColorProcessed = gammaCorrection(skyColorProcessed, GAMMA);
    #endif
	// vec3 skyColor = stars.a > 0.5 ? stars.rgb : calcSkyColor(normalize(projectInverse(vec3(position.xy / vec2(viewWidth, viewHeight) * 2 - 1, 1))));
	vec3 skyColor = stars.a > 0.5 ? stars.rgb : skyColorProcessed * RGB_to_ACEScg;

	buffer0 = opaque(skyColor);
	buffer1 = opaque(normal);
	buffer2 = vec4(light, 0);
	buffer4 = vec4(1, 0, 0, 0);
	buffer5.xyz = position;

}