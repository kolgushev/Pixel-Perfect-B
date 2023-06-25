#include "/common_defs.glsl"

out vec2 texcoord;
out vec4 color;
out vec2 light;
out vec3 position;
out vec3 normal;

#if defined g_skybasic
    out vec2 stars;
#endif

flat out int mcEntity;

#if defined gc_terrain
    in vec2 mc_Entity;
    in vec3 at_midBlock;
#endif



// uniforms

#define use_frame_time_counter
#define use_gbuffer_model_view_inverse
#define use_render_stage

#define use_to_viewspace

#if defined gc_terrain && defined USE_DOF
    const int countInstances = 2;
    #define use_instance_id
#endif

#if defined g_terrain
    #define use_get_terrain_mask
#endif

#if defined WAVING_ENABLED
    #if (defined g_terrain || defined g_water || defined g_weather)
        #if !defined DIM_NO_RAIN
            #define use_wetness
        #endif

        #define use_generate_wind
        #define use_camera_position
    #endif

    #if defined g_weather
        #define use_rain_wind
    #endif

#endif

#if defined DIM_END
    #define use_camera_position

    #define use_noisetex
    #define use_sample_noisetex
#endif

#include "/lib/use.glsl"

// TODO: world-space coordinates for everything not terrain
void main() {
    #if defined gc_terrain
        mcEntity = int(mc_Entity.x);
    #elif defined gc_emissive
        mcEntity = 1;
    #endif

    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    
    color = gl_Color;

    #if defined g_weather
        color.a = 1;
    #endif

    light = (LIGHT_MATRIX * gl_MultiTexCoord1).xy;
    /*
    The Optifine-provided lightmap is actually what is used to sample the
    vanilla lighting texture, so it isn't in a 0-1 range by default.
    */
    #if VANILLA_LIGHTING == 2
        light = max(light - 0.0313, 0) * 1.067;
    #endif

    #if defined gc_terrain || defined gc_textured || defined g_clouds || defined g_weather
        normal = gl_Normal;

        #if defined g_terrain
            float fakeNormal = (getCutoutMask(mc_Entity.x) - 2) * CUTOUT_ALIGN_STRENGTH;
            normal = mix(normal, vec3(0, sign(fakeNormal), 0), abs(fakeNormal));
        #endif
    #else
        normal = viewInverse(gl_Normal);
    #endif

    position = gl_Vertex.xyz;

    #if (defined g_terrain || (defined g_weather && defined WAVING_RAIN_ENABLED) || (defined g_water && defined WAVING_WATER_ENABLED)) && defined WAVING_ENABLED && !defined DIM_NO_WIND
        #if !defined g_weather
            bool isTopPart = at_midBlock.y < 10;
            bool isFullWaving = mc_Entity.x == WAVING || mc_Entity.x == WAVING_STIFF;
            bool isWater = mc_Entity.x == WATER;

            bool allowWaving = 
                (
                    (mc_Entity.x == WAVING_CUTOUTS_BOTTOM || mc_Entity.x == WAVING_CUTOUTS_BOTTOM_STIFF || mc_Entity.x == WAVING_CUTOUTS_BOTTOM_LIT)
                    &&
                    isTopPart
                )
                ||
                (mc_Entity.x == WAVING_CUTOUTS_TOP || mc_Entity.x == WAVING_CUTOUTS_TOP_STIFF || isFullWaving || isWater);
        #else
            bool isTopPart = false;
            bool isFullWaving = true;
            bool isWater = false;
            bool allowWaving = true;
        #endif

        if(allowWaving) {
            #if !defined g_weather
                bool isUpper = (mc_Entity.x == WAVING_CUTOUTS_TOP || mc_Entity.x == WAVING_CUTOUTS_TOP_STIFF) && isTopPart;
                bool isStiff = mc_Entity.x == WAVING_CUTOUTS_BOTTOM_STIFF || mc_Entity.x == WAVING_CUTOUTS_TOP_STIFF || mc_Entity.x == WAVING_STIFF;
            #else
                bool isUpper = position.y > 3;
                bool isStiff = false;
            #endif

            float fine = 1;

            if(isUpper) {
                fine = 1.5;
            }

            vec3 absolutePosition = position + cameraPosition;
            float time = frameTimeCounter / 3600;
            if((isUpper && !isStiff) || isFullWaving) {
                time += absolutePosition.y * 0.004 / abs(WIND_SPEED_CONSTANT);
            }
            // simulates wind gusts from several directions at several frequencies
            // requires a lot of computation but results in very good looking wind
            
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
                offset = getCalmWindProfile(absolutePosition.xz, time, fine) * WIND_STRENGTH_CONSTANT_CALM;
            }

            // custom faster wind for bad weather
            if(isWater) {
                rainOffset = getStormyWindProfile(absolutePosition.xz, time * 0.4, fine * 1.7) * 1.5;
            } else if(wetness >= rainLower) {
                rainOffset = getStormyWindProfile(absolutePosition.xz, time, fine);
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
            
            #if !defined g_weather && defined HAS_SKY
                // multiply by sky light to make sure grass doesn't wave in caves and indoors
                offset *= pow(light.y, 2);
            #endif

            offset = sign(offset) * (0.5 - 0.5 / (abs(2 * offset) + 1));
            
            #if !defined g_weather
                if(isUpper) {
                    offset *= 1.8;
                }
            #else
                if(isUpper) {
                    offset *= 2;
                } else {
                    offset *= 4.0;
                }

                offset *= rainWind;
            #endif
            
            if(isStiff) {
                offset *= 0.3;
            }

            if(isWater) {
                float offset1D = length(offset) * 0.4 - (smoothstep(rainLower, rainUpper, wetness) * 0.03 + 0.07);
                if(!isTopPart && offset1D > 0) offset1D = 0;
                position.y += min(offset1D, 0.112);
            } else {
                position.xz += offset;
                // realistic value is 1.0
                float heightOffset = 0.8;
                // prevent z-fighting for full blocks
                if(isFullWaving) {
                    position.y += EPSILON;
                }
                #if !defined g_weather
                    else if(!isFullWaving) {
                        // realistic value is * 2.0
                        if(isUpper) heightOffset *= 2.3;
                        position.y += sqrt(pow(heightOffset, 2) - pow(offset.x, 2) - pow(offset.y, 2)) - heightOffset;
                    }
                #endif
            }

        }
        
    #endif

    #if defined DIM_END
        // #if defined g_skytextured
        //     // turn the end sky into a hemisphere-like shape
        //     position.xz *= 0.5;
        // #endif


        if(END_WARPING > 0.0) {
            float displacement = tile((position.xz + cameraPosition.xz + EPSILON) * 0.1, vec2(1, 0), false).x - 0.5;
            position.y *= pow(pow(position.x, 2) + pow(position.z, 2), 0.02 * END_WARPING);
            position.y += displacement * (length(position.xz) * 0.2) * END_WARPING;
        }
    #endif

    #if !defined gc_sky
        vec4 glPos = toForcedViewspace(gl_ProjectionMatrix, gl_ModelViewMatrix, position);
    #else
        vec4 glPos = toViewspace(gl_ProjectionMatrix, gl_ModelViewMatrix, position);
    #endif

    #if defined g_basic
        if(renderStage == MC_RENDER_STAGE_OUTLINE) {
            #if defined OUTLINE_THROUGH_BLOCKS
                glPos.z *= 0.2;
            #else
                glPos.z -= EPSILON * 0.5;
            #endif
        }
    #endif

    gl_Position = glPos;

    #if defined g_skybasic
        stars = vec2(color.r, color.r == color.g && color.g == color.b && color.r > 0.0);
    #endif

    #if ISOLATE_RENDER_STAGE != -1
        if(renderStage != ISOLATE_RENDER_STAGE) {
            gl_Position = vec4(0);
        }
    #endif

    #if defined g_skytextured
        position = viewInverse(gl_Vertex.xyz);
    #endif

    #if defined NO_SHADING
        normal = vec3(0, 1, 0);
    #endif
}