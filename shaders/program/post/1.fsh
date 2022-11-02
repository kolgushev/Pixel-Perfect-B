// SSAO

#define ssao_pass

#include "/lib/common_defs.glsl"

layout(location = 5) out vec4 buffer5;

uniform int frameCounter;
uniform float frameTimeCounter;

uniform float near;
uniform float far;

uniform float aspectRatio; 

#include "/program/base/samplers.fsh"

uniform sampler2D noisetex;

uniform mat4 gbufferProjection;
uniform mat4 gbufferModelViewInverse;

#include "/lib/get_noise.fsh"
#include "/lib/anti_banding.glsl"
#include "/lib/get_samples.glsl"
#include "/lib/depth_influence.glsl"

vec2 ssao(float sampleMultiplier, float skyMask, vec3 normal, vec3 coord, float depth, float renderable, float pixelSize, sampler2D pixeltex, sampler2D coordtex) {
    if(skyMask < 0.5){
        vec2 aspectTransform = vec2(1, aspectRatio);

        float averageColor = 0;
        float totalSamples = 0;

        float samples = sampleMultiplier * AO_SAMPLES;

        // adapting some code from https://learnopengl.com/Advanced-Lighting/SSAO
        for(int i = 0; i < samples; i++) {
            vec4 noisetex = getNoise(NOISETEX_RES, i, 2);
            // create a sample in a hemisphere
            vec2 sampleCoord = normalize(vec2(noisetex.r - 0.5, noisetex.g - 0.5)) / aspectTransform;

            // scale randomly
            float scale = pow2(noisetex.b) * AO_RADIUS;

            // apply scale
            sampleCoord *= scale;

            // apply perspective scaling
            sampleCoord /= length(coord);

            vec2 combinedCoord = texcoord + sampleCoord;
            vec3 sampleSpace = texture(coordtex, combinedCoord).xyz;

            if(distance(sampleSpace, coord) <= AO_RADIUS && clamp(combinedCoord, 0, 1) == combinedCoord) {
                float sampleMod = antiBanding(i, samples);
                averageColor += calcDepthInfluence(coord, sampleSpace, normal, pixelSize, false, false, true) * sampleMod;
            }
        }
        return vec2(averageColor / samples, floor(samples));
    }
    return vec2(0);
}

void main() {
    
    float depth = texture(depthtex0, texcoord).r;
    
    vec4 normal = texture(colortex1, texcoord);
    vec4 masks = vec4(texture(colortex4, texcoord));
    vec4 generic = texture(colortex5, texcoord);
    vec4 generic2 = texture(colortex6, texcoord);
    
    #include "/program/base/passthrough_1.fsh"

    if(renderable != 0) {
        /* SSAO */
        float sampleMultiplier = 1;

        vec2 aoFull = ssao(sampleMultiplier, masks.r, normal.xyz, generic.xyz, depth, renderable, texelSurfaceArea, colortex3, colortex5);
        float ao = aoFull.r;
        float samples = aoFull.g;

        if(TEMPORAL_UPDATE_SPEED_AO < 1) {
            float mixFactor = generic2.g / (samples + generic2.g);
            generic2.b = max(mix(generic2.b, ao, clamp((1 - mixFactor) * (1 - TEMPORAL_UPDATE_SPEED_AO), 0, 1)), EPSILON);
            generic2.g = max((generic2.g + samples) * (1 - TEMPORAL_UPDATE_SPEED_AO), EPSILON);
        } else {
            generic2.b = ao;
        }
    }

	buffer5 = generic;
}