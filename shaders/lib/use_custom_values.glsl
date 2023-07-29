#if defined use_super_sample_offsets_cross
	const vec3 superSampleOffsetsCross[5] = vec3[5](
		vec3(0, 0, 1),
		vec3(-0.5, -0.5, ISQRT_2),
		vec3(-0.5, 0.5, ISQRT_2),
		vec3(0.5, -0.5, ISQRT_2),
		vec3(0.5, 0.5, ISQRT_2)
	);
#endif

#if defined use_super_sample_offsets_4
    const vec2 superSampleOffsets4[4] = vec2[4](
        vec2(-0.5, -0.5),
        vec2(-0.5, 0.5),
        vec2(0.5, -0.5),
        vec2(0.5, 0.5)
    );
#endif

#if defined use_super_sample_offsets_16
    const vec2 superSampleOffsets16[16] = vec2[16](
        vec2(-0.25, -0.25),
        vec2(0.75, 0.75),
        vec2(-0.75, 0.75),
        vec2(0.75, -0.75),
        vec2(-0.75, -0.75),
        vec2(0.75, -0.25),
        vec2(-0.25, 0.25),
        vec2(0.25, -0.75),
        vec2(-0.25, 0.75),
        vec2(0.25, 0.25),
        vec2(-0.75, -0.25),
        vec2(0.75, 0.25),
        vec2(-0.25, -0.75),
        vec2(0.25, 0.75),
        vec2(-0.75, 0.25),
        vec2(0.25, -0.25)
    );
#endif

#if defined use_temporal_AA_offsets
    #if defined DITAA_ENABLED
        #define TAA_OFFSET_LEN 2
        const vec2 temporalAAOffsets[2] = vec2[2](
            vec2(-0.5, -0.5),
            vec2(0.5, 0.5)
        );
    #else
        #define TAA_OFFSET_LEN 16
        const vec2 temporalAAOffsets[16] = vec2[16](
            vec2(0.16407393408806126, 0.3774324646270857),
            vec2(-0.8359260659119387, -0.28923420203958106),
            vec2(0.6640739340880613, -0.9559008687062476),
            vec2(-0.33592606591193874, 0.599654686849308),
            vec2(0.41407393408806126, -0.06701197981735885),
            vec2(-0.5859260659119387, -0.7336786464840254),
            vec2(0.9140739340880613, 0.8218769090715303),
            vec2(-0.08592606591193874, 0.1552102424048638),
            vec2(0.03907393408806126, -0.5114564242618032),
            vec2(-0.9609260659119387, 0.525580612775234),
            vec2(0.5390739340880613, -0.14108605389143292),
            vec2(-0.46092606591193874, -0.8077527205580993),
            vec2(0.28907393408806126, 0.7478028349974559),
            vec2(-0.7109260659119387, 0.0811361683307894),
            vec2(0.7890739340880613, -0.5855304983358772),
            vec2(-0.21092606591193874, 0.9700250572196782)
        );
    #endif
#endif

#if defined use_shadow_offsets
    #if SHADOW_SUPERSAMPLE == 1
        const vec2 superSampleOffsets[4] = superSampleOffsets4;
    #elif SHADOW_SUPERSAMPLE == 2
        const vec2 superSampleOffsets[16] = superSampleOffsets16;
    #endif
#endif