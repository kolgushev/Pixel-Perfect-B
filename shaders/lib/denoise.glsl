#include "get_noise.fsh"
#include "sampling_algorithms.glsl"
#include "anti_banding.glsl"

vec4 squareBlur(in vec2 texcoord, in sampler2D colortex, in sampler2D pixeltex, in float diameter, in bool vertical) {
    vec4 averageColor = vec4(0);
    float totalSamples = 0;

    vec2 resolution = vec2(viewWidth, viewHeight);
    for(int i = 0; i < diameter; i++){
        float offset = i - floor(diameter) * 0.5;
        vec2 samplePos = vertical ? vec2(0, offset) : vec2(offset, 0);
        samplePos = texcoord + samplePos / resolution;
        float renderable = texture(pixeltex, samplePos).b;
        totalSamples += ceil(renderable);
        averageColor += texture(colortex, samplePos) * ceil(renderable);
    }

    return averageColor / max(totalSamples, EPSILON);
}

// // credit to http://callumhay.blogspot.com/2010/09/gaussian-blur-shader-glsl.html for some of the code
// vec3 gaussianBlur(in vec3 color, in vec2 texcoord, in vec3 coord, in sampler2D colortex, in float samples, in float radius, in bool vertical) {
//     const float sigma = 4;

//     float blurSize = 1;
//     if(vertical) {
//         blurSize /= viewHeight;
//     } else {
//         blurSize /= viewHeight;
//     }

//     return color;
// }

// // code adapted from https://stackoverflow.com/questions/6538310/anyone-know-where-i-can-find-a-glsl-implementation-of-a-bilateral-filter-blur/6538650#6538650
// float bilateralBlurGrayscale(in float color, in vec2 texcoord, in vec3 coord, in sampler2D colortex, in float samples, in float radius) {
//     float normalization = 1;
//     float averageColor = color;

//     for(int i = 0; i < samples; i++) {
//         vec3 noise = getNoise(NOISETEX_RES, i)[1];
//         vec2 samplePos = normalize(vec2(noise.r, noise.g)) * radius;

//         float sampleColor = texture(colortex, texcoord + samplePos).a;

//         float gaussianCoefficient = computeGaussian(samplePos);
//     }

//     return color;
// }
// vec3 bilateralBlur(vec3 color, vec2 texcoord, vec3 coord, sampler2D colortex, float samples, float radius) {
//     return color;
// }