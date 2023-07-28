// sample a bilinearly-interpolated texture as if it were bicubic
// https://vec3.ca/bicubic-filtering-in-fewer-taps/

vec4 textureBicubic(in sampler2D tex, in vec2 uv) {
	vec2 resolution = textureSize(tex, 0);

	vec2 uvTex = uv * resolution;

	vec2 tc = floor(uvTex - 0.5) + 0.5;
	vec2 f = uvTex - tc;

	vec2 f2 = f * f;
	vec2 f3 = f2 * f;

	// using catmull-rom splines
	vec2 w0 = ((-f + 2.0) * f - 1.0) * f * 0.5;
	vec2 w1 = ((3.0 * f - 5.0) * f) * f * 0.5 + 1.0;
	vec2 w2 = ((-3.0 * f + 4.0) * f + 1.0) * f * 0.5;
	vec2 w3 = ((f - 1.0) * f * f) * 0.5;


	vec2 tc0 = tc - 1.0;
	vec2 tc1 = tc;
	vec2 tc2 = tc + 1.0;
	vec2 tc3 = tc + 2.0;

	vec2 s1 = w1 + w2;

	// also known as sw1 or sw_+0
	vec2 f1 = w2 / (s1);
	vec2 tc1_2 = tc + f1;

	vec2 resolutionRcp = 1.0 / resolution;

	tc0 *= resolutionRcp;
	tc1_2 *= resolutionRcp;
	tc3 *= resolutionRcp;

	// (3 coords) ^ 2 = 9 sample points

	return 
		texture2D(tex, vec2(tc0.x, tc0.y)) * w0.x * w0.y +
		texture2D(tex, vec2(tc3.x, tc0.y)) * w3.x * w0.y +
		texture2D(tex, vec2(tc1_2.x, tc0.y)) * s1.x * w0.y +

		texture2D(tex, vec2(tc0.x, tc3.y)) * w0.x * w3.y +
		texture2D(tex, vec2(tc3.x, tc3.y)) * w3.x * w3.y +
		texture2D(tex, vec2(tc1_2.x, tc3.y)) * s1.x * w3.y +

		texture2D(tex, vec2(tc0.x, tc1_2.y)) * w0.x * s1.y +
		texture2D(tex, vec2(tc3.x, tc1_2.y)) * w3.x * s1.y +
		texture2D(tex, vec2(tc1_2.x, tc1_2.y)) * s1.x * s1.y;

}