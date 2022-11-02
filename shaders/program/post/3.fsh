// post-GI filter

#define exposure_pass

#include "/lib/common_defs.glsl"

layout(location = 7) out vec4 buffer7;

uniform int frameCounter;
uniform float frameTimeCounter;

uniform float aspectRatio; 
uniform int worldTime; 

#include "/program/base/samplers.fsh"
uniform sampler2D noisetex;

#include "/lib/sampling_algorithms.glsl"
#include "/lib/tonemapping.glsl"
#include "/lib/get_noise.fsh"

/*
colortex0MipmapEnabled = true;
*/

void main() {
    vec4 masks = vec4(texture(colortex4, texcoord));
    vec4 generic3 = texture(colortex7, texcoord);

    #if defined AUTO_EXPOSE || defined DEBUG_VIEW
        /* find exposure */
        vec2 pixelSize = 1 / vec2(viewWidth, viewHeight);
        if(texcoord.x <= pixelSize.x && texcoord.y <= pixelSize.y) {
            float averageExposure = 0;
            
            int samples = EXPOSURE_SAMPLES;

            vec3 cells = makeCells(samples);

            for(int i = 0; i < samples; i++) {
                vec4 noisetex = getNoise(NOISETEX_RES, i, 2);
                // vec2 sampleCoordRaw = vec2((noisetex.r + noisetex.g) / 2,  noisetex.b);
                vec2 sampleCoord = jitter(vec2(noisetex.r, noisetex.b), i, cells);

                float mipmapLevel = textureQueryLod(colortex0, sampleCoord).x;
                // get average color
                vec3 sampleColor = texture(colortex0, sampleCoord, mipmapLevel).rgb;
                
                averageExposure += dot(sampleColor, vec3(RCP_3));
            }

            averageExposure = samples / max(averageExposure, EPSILON);

            if(generic3.a == 0) {
                generic3.a = averageExposure;
            } else {
                generic3.a = clamp(mix(texture(colortex7, pixelSize).a, averageExposure, EXPOSURE_UPDATE_SPEED), MIN_EXPOSURE, MAX_EXPOSURE);
            }
        }
    #endif


    buffer7 = generic3;
}