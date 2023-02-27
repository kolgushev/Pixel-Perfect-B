#include "/common_defs.glsl"
#if defined gc_terrain || defined gc_textured
    #define use_raw_normal
#endif
#if defined gc_terrain || defined gc_sky
    #define use_raw_position
#endif

out vec2 texcoord;
out vec4 color;
out vec2 light;
out vec3 position;
out vec3 normal;

#if defined g_skybasic
    out vec2 stars;
#endif

in vec2 vaUV0;
in ivec2 vaUV2;
in vec4 vaColor;
in vec3 vaNormal;
in vec3 vaPosition;

#if defined g_terrain
    in vec2 mc_Entity;
    in vec3 at_midBlock;
#endif

uniform vec3 chunkOffset;
uniform float frameTimeCounter;

uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform mat4 gbufferModelViewInverse;

uniform int renderStage;


#include "/lib/to_viewspace.glsl"

#if defined g_terrain
    #if defined WAVING_ENABLED
        uniform sampler2D noisetex;
        
        uniform vec3 cameraPosition;

        uniform float wetness;
        // uniform float frameTimeCounter;

        #include "/lib/sample_noisetex.glsl"
        #include "/lib/generate_wind.glsl"
    #endif

    #include "/lib/get_terrain_mask.glsl"
#endif

void main() {

    texcoord = vaUV0;
    
    color = vaColor;

    light = (LIGHT_MATRIX * vec4(vaUV2, 1, 1)).xy;
    /*
    The Optifine-provided lightmap is actually used to sample the
    vanilla lighting texture, so it isn't in a 0-1 range by default.
    */
    #if VANILLA_LIGHTING == 2
        light = max(light - 0.0313, 0) * 1.067;
    #endif

    #if defined use_raw_normal
        normal = vaNormal;

        #if defined g_terrain
            float fakeNormal = (getCutoutMask(mc_Entity.x) - 2) * CUTOUT_ALIGN_STRENGTH;
            normal = mix(normal, vec3(0, sign(fakeNormal), 0), abs(fakeNormal));
        #endif
    #else
        normal = viewInverse(vaNormal);
    #endif

    #if defined use_raw_position
        position = chunkOffset + vaPosition;
    #else
        position = viewInverse(vaPosition);
    #endif

    #if defined g_terrain && defined WAVING_ENABLED && !defined DIM_END
        bool isTopPart = at_midBlock.y < 0;
        bool isFullWaving = mc_Entity.x == WAVING || mc_Entity.x == WAVING_STIFF;
        if(
            (
                (mc_Entity.x == WAVING_CUTOUTS_BOTTOM || mc_Entity.x == WAVING_CUTOUTS_BOTTOM_STIFF)
                &&
                isTopPart
            )
            ||
            (mc_Entity.x == WAVING_CUTOUTS_TOP || mc_Entity.x == WAVING_CUTOUTS_TOP_STIFF || isFullWaving)) {
            
            bool isUpper = (mc_Entity.x == WAVING_CUTOUTS_TOP || mc_Entity.x == WAVING_CUTOUTS_TOP_STIFF) && isTopPart;
            bool isStiff = mc_Entity.x == WAVING_CUTOUTS_BOTTOM_STIFF || mc_Entity.x == WAVING_CUTOUTS_TOP_STIFF || mc_Entity.x == WAVING_STIFF;

            vec3 absolutePosition = position + cameraPosition;
            float time = frameTimeCounter / 3600;
            if((isUpper && !isStiff) || isFullWaving) {
                time += absolutePosition.y * 0.004 / abs(WIND_SPEED_CONSTANT);
            }
            // simulates wind gusts from several directions at several frequencies
            // requires a lot of computation but results in very good looking wind
            // TODO: add a custom wind configuration for nether and end
            vec2 offset =
                windImpulse(2.35, 0.63 * 0.25, 0.903, 0.15, 0.8, absolutePosition.xz, time) +
                windImpulse(1.45, 0.17 * 0.25, 0.606, 0.48, 1.0, absolutePosition.xz, time) +
                windImpulse(1.03, 0.85 * 0.25, 0.624, 0.06, 1.0, absolutePosition.xz, time) +
                windImpulse(1.29, 0.19 * 0.25, 0.697, 0.62, 1.0, absolutePosition.xz, time) +
                windImpulse(1.14, 0.41 * 0.25, 0.741, 0.19, 1.0, absolutePosition.xz, time) +
                windImpulse(0.82, 0.67 * 0.25, 0.714, 0.93, 2.0, absolutePosition.xz, time) +
                windImpulse(0.50, 0.30 * 0.25, 0.113, 0.59, 2.0, absolutePosition.xz, time) +
                windImpulse(0.40, 0.85 * 0.25, 0.212, 0.43, 2.0, absolutePosition.xz, time)
            ;
            // there is no rain in the nether (rain in deserts is a windstorm)
            #if !defined DIM_NETHER
                offset *= (1 + wetness * 3);
            #endif
            if(isUpper) {
                offset *= 1.3;
            }
            offset = sign(offset) * (0.5 - 0.5 / (abs(2 * offset) + 1));
            if(isStiff) {
                offset *= 0.3;
            }
            if(isUpper) {
                offset *= 1.8;
            }
            position.xz += offset;
        }
    #endif

    #if defined use_raw_position
        #if !defined gc_sky
            vec4 glPos = toForcedViewspace(projectionMatrix, modelViewMatrix, position);
        #else
            vec4 glPos = toViewspace(projectionMatrix, modelViewMatrix, position);
        #endif
    #else
        vec4 glPos = toForcedViewspace(projectionMatrix, modelViewMatrix, vaPosition);
    #endif
    gl_Position = glPos;

    #if defined g_skybasic
        stars = vec2(color.r, color.r == color.g && color.g == color.b && color.r > 0.0);
    #endif
}