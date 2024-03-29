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

	#define use_super_sample_offsets_cross

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

	#define use_super_sample_offsets_4
	#define use_temporal_AA_offsets

	#if defined TAA_CORNER_CLAMPING
		#define use_super_sample_offsets_cross
	#endif

	#if defined TAA_USE_BICUBIC
		#define use_bicubic_filter
	#endif

	#if defined TAA_HYBRID_TONEMAP
		#define use_tonemapping
	#endif
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
		vec2 closestOffset = vec2(0);
		// Force-enable in end dimension to fix aliasing of edges near border between geometry and end sky without apply AA to sky
		#if defined TAA_CLOSEST_MOTION_VECTOR || defined DIM_END
			float closestDist = depth;
			for(int i = 0; i < 4; i++) {
				vec2 currentOffset = superSampleOffsets4[i].xy * 2 / vec2(viewWidth, viewHeight);
				float neighborSample = texture(depthtex0, texcoord + currentOffset).r;
				if(neighborSample < closestDist) {
					closestDist = neighborSample;
					closestOffset = currentOffset;
				}
			}
		#endif

		vec2 velocity = texture(colortex5, texcoord + closestOffset).xy;
		vec2 texcoordPrev = texcoord + velocity;

		bool doAA = clamp(texcoordPrev, 0.0, 1.0) == texcoordPrev;

		#if defined DIM_END
			doAA = doAA && closestDist != 1.0;
		#endif

		if(doAA) {
			// write the diffuse color
			#if defined TAA_USE_BICUBIC
				// Use bicubic sampling to reduce blur as suggested in
				// https://research.activision.com/publications/2020-03/dynamic-temporal-antialiasing-and-upsampling-in-call-of-duty
				// TODO: optimize further
				vec3 prevFrame = textureBicubic(colortex4, texcoordPrev).rgb;
			#else
				vec3 prevFrame = texture(colortex4, texcoordPrev).rgb;
			#endif

			vec3 minFrame = colored;
			vec3 maxFrame = colored;
			#if defined TAA_SHARP_ENABLED
				vec3 avgFrame = vec3(0);
			#endif

			for(int i = 0; i < 4; i++) {
				vec3 neighborSample = texture(colortex0, texcoord + superSampleOffsets4[i].xy * 2 / vec2(viewWidth, viewHeight)).rgb;
				minFrame = min(minFrame, neighborSample);
				maxFrame = max(maxFrame, neighborSample);
				#if defined TAA_SHARP_ENABLED
					avgFrame += neighborSample;
				#endif
			}

			#if defined TAA_CORNER_CLAMPING
				// edges
				for(int i = 1; i < 5; i++) {
					vec3 neighborSample = texture(colortex0, texcoord + superSampleOffsetsCross[i].xy * 2 / vec2(viewWidth, viewHeight)).rgb;
					minFrame = min(minFrame, neighborSample);
					maxFrame = max(maxFrame, neighborSample);
				}
			#endif

			#if defined TAA_SHARP_ENABLED
				avgFrame *= 0.25;
			#endif

			float velocityLen = length(velocity * vec2(viewWidth, viewHeight));


			#if defined TAA_DO_CLIPPING
				#if defined TAA_NO_CLIPPING_WHEN_STILL
					if(velocityLen != 0.0 || depth == 1.0) {
				#endif

				// perform clipping similar to https://twvideo01.ubm-us.net/o1/vault/gdc2016/Presentations/Pedersen_LasseJonFuglsang_TemporalReprojectionAntiAliasing.pdf

				// convert to YCoCg colorspace
				#define Y_CO_CG_TRANSFORM mat3(0.25, 0.5, 0.25, 0.5, 0.0, -0.5, -0.25, 0.5, -0.25)
				#define Y_CO_CG_TRANSFORM_INV mat3(1.0, 1.0, -1.0, 1.0, 0.0, 1.0, 1.0, -1.0, -1.0)

				// TODO: Using YCoCg should look better... am I using the wrong transform? Need to look into.
				#if defined TAA_DO_CLIPPING_IN_Y_CO_CG
					vec3 maxFrameC = Y_CO_CG_TRANSFORM * maxFrame;
					vec3 minFrameC = Y_CO_CG_TRANSFORM * minFrame;
					vec3 prevC = Y_CO_CG_TRANSFORM * prevFrame;
				#else
					vec3 maxFrameC = maxFrame;
					vec3 minFrameC = minFrame;
					vec3 prevC = prevFrame;
				#endif

				vec3 coloredClip = 0.5 * (maxFrameC + minFrameC);
				vec3 eClip = 0.5 * (maxFrameC - minFrameC);

				vec3 vClip = prevC - coloredClip;
				vec3 vUnit = vClip.xyz / eClip;
				vec3 aUnit = abs(vUnit);
				float MAUnit = max(aUnit.x, max(aUnit.y, aUnit.z));

				if(MAUnit > 1.0) {
					prevC = coloredClip + vClip / max(MAUnit, EPSILON);
					#if defined TAA_DO_CLIPPING_IN_Y_CO_CG
						prevFrame = Y_CO_CG_TRANSFORM_INV * prevC;
					#else
						prevFrame = prevC;
					#endif
				}

				#if defined TAA_NO_CLIPPING_WHEN_STILL
					}
				#endif
			#endif

			#if defined DITAA_ENABLED
				float mixingFactor = TAA_OFFSET_LEN_RCP;
			#else
				float mixingFactor = 0.64 * TAA_OFFSET_LEN_RCP;
			#endif

			// TAA Sharpening
			#if defined TAA_SHARP_ENABLED
				colored = (colored - avgFrame) * TAA_SHARP_WEIGHT + avgFrame;
				colored = max(colored, 0.0);
			#endif

			#if defined DITAA_ENABLED
				b4 = colored;
			#endif

			colored = mix(prevFrame, colored, mixingFactor);
			
			#if !defined DITAA_ENABLED
				b4 = max(colored, 0.0);
			#endif
		} else {
			b4 = colored;
		}

		#if defined TAA_HYBRID_TONEMAP
			colored = reinhardInverse(colored);
		#endif
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