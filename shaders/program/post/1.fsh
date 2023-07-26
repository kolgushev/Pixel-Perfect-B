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
		vec2 closestOffset = vec2(0);
		#if defined TAA_CLOSEST_MOTION_VECTOR
			float closestDist = depth;
			for(int i = 0; i < 4; i++) {
				vec2 currentOffset = superSampleOffsets4[i].xy * 2 / vec2(viewWidth, viewHeight);
				float neighborSample = texture2D(depthtex0, texcoord + currentOffset).r;
				if(neighborSample < closestDist) {
					closestDist = neighborSample;
					closestOffset = currentOffset;
				}
			}
		#endif

		vec2 velocity = texture2D(colortex5, texcoord + closestOffset).xy;
		vec2 texcoordPrev = texcoord + velocity;

		if(clamp(texcoordPrev, 0.0, 1.0) == texcoordPrev) {
			// write the diffuse color
			vec3 prevFrame = texture2D(colortex4, texcoordPrev).rgb;

			vec3 minFrame = colored;
			vec3 maxFrame = colored;
			#if defined TAA_SHARP_ENABLED
				vec3 avgFrame = vec3(0);
			#endif

			for(int i = 0; i < 4; i++) {
				vec3 neighborSample = texture2D(colortex0, texcoord + superSampleOffsets4[i].xy * 2 / vec2(viewWidth, viewHeight)).rgb;
				minFrame = min(minFrame, neighborSample);
				maxFrame = max(maxFrame, neighborSample);
				#if defined TAA_SHARP_ENABLED
					avgFrame += neighborSample;
				#endif
			}

			#if defined TAA_CORNER_CLAMPING
				// edges
				for(int i = 1; i < 5; i++) {
					vec3 neighborSample = texture2D(colortex0, texcoord + superSampleOffsetsCross[i].xy * 2 / vec2(viewWidth, viewHeight)).rgb;
					minFrame = min(minFrame, neighborSample);
					maxFrame = max(maxFrame, neighborSample);
				}
			#endif

			#if defined TAA_SHARP_ENABLED
				avgFrame *= 0.25;
			#endif

			float velocityLen = length(velocity * vec2(viewWidth, viewHeight));


			// perform clipping similar to https://twvideo01.ubm-us.net/o1/vault/gdc2016/Presentations/Pedersen_LasseJonFuglsang_TemporalReprojectionAntiAliasing.pdf

			// convert to YCoCg colorspace
			#define Y_CO_CG_TRANSFORM mat3(0.25, 0.5, 0.25, 0.5, 0.0, -0.5, -0.25, 0.5, -0.25)
			#define Y_CO_CG_TRANSFORM_INV mat3(1.0, 1.0, -1.0, 1.0, 0.0, 1.0, 1.0, -1.0, -1.0)

			vec3 maxFrameC = Y_CO_CG_TRANSFORM * maxFrame;
			vec3 minFrameC = Y_CO_CG_TRANSFORM * minFrame;
			vec3 prevC = Y_CO_CG_TRANSFORM * prevFrame;


			vec3 coloredClip = 0.5 * (maxFrameC + minFrameC);
			vec3 eClip = 0.5 * (maxFrameC - minFrameC);

			vec3 vClip = prevC - coloredClip;
			vec3 vUnit = vClip.xyz / eClip;
			vec3 aUnit = abs(vUnit);
			float MAUnit = max(aUnit.x, max(aUnit.y, aUnit.z));

			// if(MAUnit > 1.0) {
			// 	prevC = coloredClip + vClip / max(MAUnit, EPSILON);
			// 	prevFrame = Y_CO_CG_TRANSFORM_INV * prevC;
			// } 

			float mixingFactor = smoothstep(0.0, 0.2, velocityLen) * 0.07 + 0.02;

			// TAA Sharpening
			#if defined TAA_SHARP_ENABLED
				float sharpeningFactor = smoothstep(0.0, TAA_SHARP_PIXEL_THRESHOLD, velocityLen) * TAA_SHARP_SPEED_WEIGHT + 1.0;
				colored = (colored - avgFrame) * sharpeningFactor * TAA_SHARP_WEIGHT + avgFrame;
				colored = max(colored, 0.0);
			#endif

			colored = mix(prevFrame, colored, mixingFactor);
			
			b4 = colored;
		} else {
			b4 = colored;
		}
		

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