#include "/common_defs.glsl"

/* DRAWBUFFERS:04 */
layout(location = 0) out vec4 b0;
#if defined TAA_ENABLED
    layout(location = 1) out vec3 b4;
#endif

in vec2 texcoord;



// uniforms

#define use_depthtex0
#define use_colortex0

#define use_is_eye_in_water
#define use_view_width
#define use_view_height

#if defined FAST_GI
	#define use_colortex1

	#define use_far
	#define use_blindness_smooth
	#define use_gbuffer_projection_inverse
	#define use_gbuffer_model_view_inverse

	#define use_linearize_depth
	#define use_fogify
	#define use_tonemapping
#endif

#if defined DYNAMIC_EXPOSURE_LIGHTING
	#define use_colortex1
	#define use_tonemapping
#endif

#if defined TAA_ENABLED
	#define use_colortex4
	#define use_colortex5

    #define use_frame_counter
    #define use_view_width
    #define use_view_height
#endif

#include "/lib/use.glsl"

/*
const bool colortex1MipmapEnabled = true;
*/

void main() {
	float depth = texture(depthtex0, texcoord).r;
	vec3 diffuse = texture(colortex0, texcoord).rgb;
	vec3 colored = diffuse;

    #if defined TAA_ENABLED
        vec2 texcoordPrev = texcoord + texture2D(colortex5, texcoord).xy;

		if(clamp(texcoordPrev, 0.0, 1.0) == texcoordPrev) {
			// write the diffuse color
			vec3 prevFrame = texture2D(colortex4, texcoordPrev).rgb;

			vec3 minFrame = colored;
			vec3 maxFrame = colored;

			for(int i = 0; i < 4; i++) {
				vec3 neighborSample = texture2D(colortex0, texcoord + superSampleOffsets4[i].xy * 2 / vec2(viewWidth, viewHeight)).rgb;
				minFrame = min(minFrame, neighborSample);
				maxFrame = max(maxFrame, neighborSample);
			}

			prevFrame = clamp(prevFrame, minFrame, maxFrame);

			colored = mix(colored, prevFrame, 0.9);
		}
		
		b4 = colored;
    #endif

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
			colored += colored * diffuseBlur * FAST_GI_STRENGTH * (1 - fogifyDistanceOnly(position, far, blindnessSmooth, 1 / far));
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