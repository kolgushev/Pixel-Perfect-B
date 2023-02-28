#include "/common_defs.glsl"
#if defined gc_terrain || defined gc_textured
    #define use_raw_normal
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
    out vec2 entity;
    in vec3 at_midBlock;
#endif

uniform vec3 chunkOffset;
uniform float frameTimeCounter;

uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform mat4 gbufferModelViewInverse;

uniform int renderStage;

#if (defined g_terrain || defined g_weather) && defined WAVING_ENABLED
    uniform vec3 cameraPosition;

    #if !defined DIM_NO_RAIN
        uniform float wetness;
    #endif
    // uniform float frameTimeCounter;

    #include "/lib/generate_wind.glsl"
#endif

#include "/lib/to_viewspace.glsl"

#if defined g_terrain
    #include "/lib/get_terrain_mask.glsl"
#endif

void main() {
    #if defined g_terrain
        entity = mc_Entity;
    #endif

    texcoord = vaUV0;
    
    color = vaColor;

    light = (LIGHT_MATRIX * vec4(vaUV2, 1, 1)).xy;
    /*
    The Optifine-provided lightmap is actually what is used to sample the
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

    position = chunkOffset + vaPosition;

    #if (defined g_terrain || defined g_weather) && defined WAVING_ENABLED && !defined DIM_NO_WIND
        #if !defined g_weather
            bool isTopPart = at_midBlock.y < 0;
            bool isFullWaving = mc_Entity.x == WAVING || mc_Entity.x == WAVING_STIFF;

            bool allowWaving = 
                (
                    (mc_Entity.x == WAVING_CUTOUTS_BOTTOM || mc_Entity.x == WAVING_CUTOUTS_BOTTOM_STIFF)
                    &&
                    isTopPart
                )
                ||
                (mc_Entity.x == WAVING_CUTOUTS_TOP || mc_Entity.x == WAVING_CUTOUTS_TOP_STIFF || isFullWaving);
        #else
            bool isTopPart = false;
            bool isFullWaving = true;
            bool allowWaving = true;
        #endif

        if(allowWaving) {
            #if !defined g_weather
                bool isUpper = (mc_Entity.x == WAVING_CUTOUTS_TOP || mc_Entity.x == WAVING_CUTOUTS_TOP_STIFF) && isTopPart;
                bool isStiff = mc_Entity.x == WAVING_CUTOUTS_BOTTOM_STIFF || mc_Entity.x == WAVING_CUTOUTS_TOP_STIFF || mc_Entity.x == WAVING_STIFF;
            #else
                bool isUpper = position.y > 6;
                bool isStiff = false;
            #endif

            vec3 absolutePosition = position + cameraPosition;
            float time = frameTimeCounter / 3600;
            if((isUpper && !isStiff) || isFullWaving) {
                time += absolutePosition.y * 0.004 / abs(WIND_SPEED_CONSTANT);
            }
            // simulates wind gusts from several directions at several frequencies
            // requires a lot of computation but results in very good looking wind
            // TODO: add a custom wind configuration for nether and end
            
            // there is no rain in the nether (rain in deserts is a windstorm)
            #if defined DIM_NO_RAIN
                float wetness = 0.0;
            #endif

            vec2 offset = vec2(0,0);
            vec2 rainOffset = vec2(0,0);
            
            const float rainLower = 0.04;
            const float rainUpper = 0.9;
            
            // normal wind
            if(wetness <= rainUpper) {
                offset = getCalmWindProfile(absolutePosition.xz, time);
            }

            // custom faster wind for bad weather
            if(wetness >= rainLower) {
                rainOffset = getStormyWindProfile(absolutePosition.xz, time);
            }
            
            // mix the two winds depending on weather
            offset = mix(offset, rainOffset, smoothstep(rainLower, rainUpper, wetness));

            #if !defined g_weather
                if(isUpper) {
                    offset *= 1.3;
                }
            #else
                if(isUpper) {
                    offset *= -0.5;
                } else {
                    offset *= 0.5;
                }
            #endif
            
            offset = sign(offset) * (0.5 - 0.5 / (abs(2 * offset) + 1));
            
            #if !defined g_weather
                if(isUpper) {
                    offset *= 1.8;
                }
            #else
                if(isUpper) {
                    offset *= 1.4;
                } else {
                    offset *= 3.0;
                }
            #endif
            
            if(isStiff) {
                offset *= 0.3;
            }
            #if !defined g_weather && !defined DIM_NO_SKY
                // multiply by sky light to make sure grass doesn't wave in caves and indoors
                offset *= light.y;
            #endif

            position.xz += offset;
            // prevent z-fighting for full blocks
            if(isFullWaving) {
                position.y += EPSILON;
            }
        }
    #endif

    #if !defined gc_sky
        vec4 glPos = toForcedViewspace(projectionMatrix, modelViewMatrix, position);
    #else
        vec4 glPos = toViewspace(projectionMatrix, modelViewMatrix, position);
    #endif
    gl_Position = glPos;

    #if defined g_skybasic
        stars = vec2(color.r, color.r == color.g && color.g == color.b && color.r > 0.0);
    #endif
}