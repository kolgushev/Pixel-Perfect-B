#include "sampling_algorithms.glsl"
#include "anti_banding.glsl"
#include "get_samples.glsl"
#include "depth_influence.glsl"

vec4 SSBounce(in float sampleMultiplier, in vec2 texcoordMod, in float skyMask, in vec3 normal, in vec3 depth, in float renderable, in float pixelSize, in sampler2D masktex, in sampler2D albedotex, in sampler2D bouncetex, in sampler2D depthtex, in sampler2D pixeltex) {
    if(skyMask < 0.5){
        vec2 aspectTransform = vec2(aspectRatio, 1);
        // vec2 resolution = vec2(viewWidth, viewHeight);

        dvec3 averageColor = vec3(0);

        float normalization = 0;
        #ifdef OLD_SAMPLING
            int actualSamples = 0;
        #endif

        // float samples = clamp(getSamples(SCREEN_SAMPLES, renderable, pixelSize) * sampleMultiplier, MIN_SAMPLES, MAX_NEW_SAMPLES);
        float samples = SCREEN_SAMPLES * sampleMultiplier;

        vec3 cells = makeCells(samples);

        for(int i = 0; i < samples; i++) {
            vec4 noisetex = getNoise(NOISETEX_RES, i, 2);
            #if SCREEN_SAMPLES == 1
                vec2 sampleCoord = vec2((noisetex.r + noisetex.g) * 0.5, (noisetex.b + noisetex.a) * 0.5);
            #else
                vec2 sampleCoord = jitter(vec2(noisetex.r, noisetex.b), i, cells);
            #endif

            #ifdef POWERFUL_SAMPLE
                // bias samples near pixel
                sampleCoord = sampleCoord - texcoord;
                sampleCoord = mix(texcoord, sampleCoord + texcoord, pow(length(sampleCoord), POWERFUL_SAMPLE_AMOUNT));
            #endif

            vec3 sampleMasks = texture(masktex, sampleCoord).rba;

            if(sampleMasks.r == 0) {
                vec3 sampleDepth = texture(depthtex, sampleCoord).rgb;
                vec3 sampleColor = texture(albedotex, sampleCoord).rgb;
                float sampleSize = texture(pixeltex, sampleCoord).a;
                #ifdef COLORED_LIGHT_ONLY
                    sampleColor = sampleColor * fma(sampleMasks.g, LIT_MULTIPLIER, LIT_MIN);
                #else
                    float saturatedMult = sampleMasks.g * LIT_MULTIPLIER;
                    #ifdef USE_SECONDARY_BOUNCES
                        vec3 normalMult = texture(bouncetex, sampleCoord).rgb + sampleMasks.b + LIT_MIN;
                    #else
                        float normalMult = sampleMasks.b + LIT_MIN;
                    #endif
                    vec3 litSaturatedColor = clamp(sampleColor, 0, 1);
                    sampleColor = litSaturatedColor * saturatedMult + sampleColor * normalMult;
                #endif
                float depthInfluence = calcDepthInfluence(depth, sampleDepth, normal, sampleSize, true, true, false);

                sampleColor = sampleColor * depthInfluence;

                #ifdef OLD_SAMPLING
                    actualSamples ++;
                #endif

                normalization += depthInfluence;
                averageColor += sampleColor;
            
                // averageColor += distance(sampleCoord, texcoord);
            }
        }
        
        averageColor /= max(normalization, EPSILON);
        
        #ifndef OLD_SAMPLING
            // multiply by epsilon to avoid nasty overflow problems
            // TODO: figure out a system where this doesn't happen
            return vec4(max(averageColor, vec3(EPSILON)), normalization * EPSILON);
        #else
            return vec4(max(averageColor, vec3(EPSILON)), float(actualSamples));
        #endif
    }
    return vec4(0, 0, 0, 0);
}