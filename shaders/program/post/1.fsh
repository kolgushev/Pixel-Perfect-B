#include "/common_defs.glsl"

/* DRAWBUFFERS:0 */
layout(location = 0) out vec4 b0;

in vec2 texcoord;

uniform sampler2D depthtex0;
uniform sampler2D colortex0;

uniform int isEyeInWater;

uniform float viewWidth;
uniform float viewHeight;

#if defined FAST_GI
	uniform float far;
	uniform float blindnessSmooth;

	uniform mat4 gbufferProjectionInverse;
	uniform mat4 gbufferModelViewInverse;

	#include "/lib/linearize_depth.fsh"
	#include "/lib/fogify.glsl"
#endif

#if defined FAST_GI || defined DYNAMIC_EXPOSURE_LIGHTING
	uniform sampler2D colortex1;
	#include "/lib/tonemapping.glsl"
#endif

/*
const bool colortex1MipmapEnabled = true;
*/

void main() {
	float depth = texture(depthtex0, texcoord).r;
	vec3 diffuse = texture(colortex0, texcoord).rgb;
	vec3 colored = diffuse;

	#if defined FAST_GI
		// check for sky
		if(depth != 1) {
			vec3 diffuseBlur = vec3(0);

			vec2 offsetMult = pow(2, FAST_GI_LOD_LEVEL) / vec2(viewWidth, viewHeight);
			float sum = 0;
			const float maxBrightness = 1.7;

			for(int i = 0; i < superSampleOffsetsCross.length; i++) {
				vec3 offsetAndWeight = superSampleOffsetsCross[i];
				vec2 offset = offsetAndWeight.xy * offsetMult;

				vec2 coord = texcoord + offset;
				// coord = removeBorder(coord, offsetMult * 2);
				vec3 sampled = texture(colortex1, coord, FAST_GI_LOD_LEVEL).rgb * offsetAndWeight.z;

				diffuseBlur += reinhard(sampled / maxBrightness) * maxBrightness;
				sum += offsetAndWeight.z;
			}

			diffuseBlur /= sum;



			vec3 position = depthToView(texcoord, depth, gbufferProjectionInverse);
			position = mul_m4_v3(gbufferModelViewInverse, position).rgb;
			colored += colored * diffuseBlur * FAST_GI_STRENGTH * (1 - fogifyDistanceOnly(position, far, blindnessSmooth));
			// colored = diffuseBlur;
		}
	#endif

	#if defined WATER_FOG
		if(isEyeInWater == 1) {
			colored *= OVERLAY_COLOR_WATER;
		}
	#endif

	#if defined DYNAMIC_EXPOSURE_LIGHTING
		vec3 light = texture(colortex1, texcoord, 100).rgb;
		float maxLight = max(max(light.r, light.g), light.b);

		colored /= maxLight * 2 + 0.005;
	#endif

    #ifdef DEBUG_VIEW
        b0 = opaque(diffuse);
    #else
		b0 = opaque(colored);
    #endif
}