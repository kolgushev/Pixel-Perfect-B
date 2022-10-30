// generate fake ambient bounce lighting, apply existing lighting

#define fake_gi_pass

#include "/lib/common_defs.glsl"
#include "/program/base/configure_buffers.fsh"

uniform int frameCounter;
uniform float frameTimeCounter;

uniform float near;
uniform float far;

uniform float aspectRatio;

uniform sampler2D noisetex;

uniform mat4 modelViewMatrix;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;

#include "/program/base/samplers.fsh"

#include "/lib/get_noise.fsh"

#include "/lib/to_viewspace.glsl"

#include "/lib/bounce.glsl"

void main() {
    
    #define READ_NORMAL
    #define OVERRIDE_NORMAL

    #define READ_MASKS
    #define OVERRIDE_MASKS

    #define READ_GENERIC
    #define OVERRIDE_GENERIC

    #define READ_GENERIC2
    #define WRITE_GENERIC2
    
    #define READ_GENERIC3
    #define WRITE_GENERIC3
    
    #include "/program/base/passthrough_1.fsh"

    #ifndef DEBUG_VIEW
    if(renderable != 0) {
    #endif
        // render fake GI
        // it's fake because we don't do any ray occlusion tests (and it's screenspace)
        // float sampleMultiplier = MAX_NEW_SAMPLES / generic2.a;
        #ifdef ADAPTIVE_SAMPLING_SSGI
            float sampleMultiplier = clamp(MAX_NEW_SAMPLES * MAX_SAMPLES / max(generic2.a, EPSILON), MIN_SAMPLES, MAX_SAMPLES);
            // float sampleMultiplier = MAX_NEW_SAMPLES / max(generic2.a, 0.2);
        #else
            float sampleMultiplier = 1;
        #endif

        vec4 bounceColor = SSBounce(sampleMultiplier, texcoordMod, masks.r, normal, generic.rgb, renderable, texelSurfaceArea, colortex4, colortex0, colortex7, colortex5, colortex3);
        if(TEMPORAL_UPDATE_SPEED < 1) {
            float mixFactor = bounceColor.a / (generic2.a + bounceColor.a);
            generic3.rgb = max(mix(bounceColor.rgb, generic3.rgb, clamp((1 - mixFactor) * (1 - TEMPORAL_UPDATE_SPEED), 0, 1)), EPSILON);
            // original EQ: mix(generic2.a + bounceColor.a, 0, TEMPORAL_UPDATE_SPEED);
            generic2.a = max(mix(generic2.a + bounceColor.a, bounceColor.a, TEMPORAL_UPDATE_SPEED), EPSILON);
        } else {
            generic3.rgb = bounceColor.rgb;
        }
    #ifndef DEBUG_VIEW
    }
    #endif

    // albedo = vec4((texcoord - texcoordMod) * 1000 + 0.5 * 1, 0, 1);
    #include "/program/base/passthrough_2.fsh"
}