const vec3 superSampleOffsetsCross[5] = vec3[5](
    vec3(0, 0, 1),
    vec3(-0.5, -0.5, ISQRT_2),
    vec3(-0.5, 0.5, ISQRT_2),
    vec3(0.5, -0.5, ISQRT_2),
    vec3(0.5, 0.5, ISQRT_2)
);

const vec2 superSampleOffsets4[4] = vec2[4](
    vec2(-0.5, -0.5),
    vec2(-0.5, 0.5),
    vec2(0.5, -0.5),
    vec2(0.5, 0.5)
);

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

#if defined DITAA_ENABLED
    #define TAA_OFFSET_LEN 2
    #define TAA_OFFSET_LEN_RCP 0.5
    const vec2 temporalAAOffsets[TAA_OFFSET_LEN] = vec2[TAA_OFFSET_LEN](
        vec2(-0.5, -0.5),
        vec2(0.5, 0.5)
    );
#else
    #define TAA_OFFSET_LEN 8
    #define TAA_OFFSET_LEN_RCP RCP_8
    const vec2 temporalAAOffsets[TAA_OFFSET_LEN] = vec2[TAA_OFFSET_LEN](
        vec2(0.42193535490543965, 0.6377455362026838),
        vec2(-0.5780646450945603, -0.695587797130649),
        vec2(0.9219353549054397, -0.028921130463982703),
        vec2(-0.07806464509456035, 0.8599677584249061),
        vec2(0.17193535490543965, -0.4733655749084271),
        vec2(-0.8280646450945603, 0.19330109175823962),
        vec2(0.6719353549054397, 0.41552331398046194),
        vec2(-0.32806464509456035, -0.9178100193528712)
    );
#endif

#if SHADOW_SUPERSAMPLE == 1
    const vec2 superSampleOffsets[4] = superSampleOffsets4;
#elif SHADOW_SUPERSAMPLE == 2
    const vec2 superSampleOffsets[16] = superSampleOffsets16;
#endif
