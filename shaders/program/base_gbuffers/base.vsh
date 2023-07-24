#include "/common_defs.glsl"

out vec2 texcoord;
out vec4 color;
out vec2 light;
out vec3 position;
out vec3 normal;
flat out int mcEntity;
#if defined TAA_ENABLED
    out vec2 offset;
    out vec3 velocity;
#endif
#if defined g_skybasic
    out vec2 stars;
#endif


in vec3 at_velocity;

#if defined gc_terrain
    in vec2 mc_Entity;
    in vec3 at_midBlock;
#endif

#if defined g_line
    in vec3 vaNormal;
#endif


// uniforms

#define use_frame_time_counter
#define use_gbuffer_model_view_inverse
#define use_render_stage

#if defined g_line
    #define use_view_width
    #define use_view_height
    #define use_model_view_matrix
    #define use_model_view_matrix_inverse
    #define use_projection_matrix
    #define use_projection_matrix_inverse
#endif

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

    #define use_rain_wind
#endif

#if defined DIM_END
    #define use_camera_position

    #define use_sample_noisetex
#endif

#if defined TAA_ENABLED
    #define use_frame_counter
    #define use_view_width
    #define use_view_height
#endif

#include "/lib/use.glsl"

// TODO: world-space coordinates for everything not terrain
void main() {
    #if defined TAA_ENABLED
        velocity = at_velocity;
    #endif

    #if defined gc_terrain
        mcEntity = int(mc_Entity.x);
    #elif defined gc_emissive
        mcEntity = 1;
    #else
        mcEntity = -1;
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
    #elif defined g_line
        normal = vaNormal;
    #else
        normal = viewInverse(gl_Normal);
    #endif

    position = gl_Vertex.xyz;

    #if defined g_line
        // The line is given to us as a single point at the start with the offset being given via the normal
        // We have to turn that into a thin parallelogram stretching across the screen with a pixel width
        // Special thanks to https://cdn.discordapp.com/attachments/960320448594329630/960695935837548695/base150.zip
        // for providing a solution

        const float LINE_WIDTH  = 2.5;
        const float VIEW_SHRINK = 1.0 - (1.0 / 256.0);
        const mat4 VIEW_SCALE   = mat4(
            VIEW_SHRINK, 0.0, 0.0, 0.0,
            0.0, VIEW_SHRINK, 0.0, 0.0,
            0.0, 0.0, VIEW_SHRINK, 0.0,
            0.0, 0.0, 0.0, 1.0
        );

        // find the resolution used for the pixel-width
        vec2 resolution = vec2(viewWidth, viewHeight);

        // Find the viewspace position of the line start and end
        vec4 linePosStart = projectionMatrix * (VIEW_SCALE * (modelViewMatrix * vec4(gl_Vertex.xyz, 1.0)));
        vec4 linePosEnd = projectionMatrix * (VIEW_SCALE * (modelViewMatrix * vec4(gl_Vertex.xyz + normal, 1.0)));

        // account for perspective
        vec3 ndc1 = linePosStart.xyz / linePosStart.w;
        vec3 ndc2 = linePosEnd.xyz / linePosEnd.w;

        // calculate the direction of the line (using the resolution is a surprise tool that will help us later)
        vec2 lineScreenDirection = normalize((ndc2.xy - ndc1.xy) * resolution);

        // use the surprise tool right away to add thickness to our polygons by stretching them perpendicularly to the line
        // we multiply by the resolution to specify a pixel width for our lines
        // and convert them back from pixel-space by dividing by the resolution
        vec2 lineOffset = vec2(-lineScreenDirection.y, lineScreenDirection.x) * LINE_WIDTH / resolution;

        // I'm gonna be honest, I have no idea what this does
        if(lineOffset.x < 0) lineOffset = -lineOffset;
        // offset half the vertices in the parallelogram one way
        // (if all vertices are offset by the same value they won't have thickness)
        if(gl_VertexID % 2 != 0) lineOffset = -lineOffset;

        vec3 viewPosition = (ndc1 + vec3(lineOffset, 0.0)) * linePosStart.w;

        position = (
            modelViewMatrixInverse
            * (
                projectionMatrixInverse
                *
                vec4(viewPosition, linePosStart.w)
                )
            ).xyz;
    #endif

    #if (defined g_terrain || (defined g_weather && defined WAVING_RAIN_ENABLED) || (defined g_water && defined WAVING_WATER_ENABLED)) && defined WAVING_ENABLED && !defined DIM_NO_WIND
        #if !defined g_weather
            bool isTopPart = at_midBlock.y < 10;
            if(mc_Entity.x == WAVING_CUTOUTS_LOW) {
                isTopPart = at_midBlock.y < 30;
            }
            bool isFullWaving = mc_Entity.x == WAVING || mc_Entity.x == WAVING_STIFF;
            bool isWater = mc_Entity.x == WATER;

            bool allowWaving = 
                (
                    (mc_Entity.x == WAVING_CUTOUTS_LOW || mc_Entity.x == WAVING_CUTOUTS_BOTTOM || mc_Entity.x == WAVING_CUTOUTS_BOTTOM_STIFF || mc_Entity.x == WAVING_CUTOUTS_BOTTOM_LIT)
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
                bool isStiff = mc_Entity.x == WAVING_CUTOUTS_BOTTOM_STIFF || mc_Entity.x == WAVING_CUTOUTS_TOP_STIFF || mc_Entity.x == WAVING_STIFF || mc_Entity.x == WAVING_CUTOUTS_LOW;
                bool isSuperStiff = mc_Entity.x == WAVING_CUTOUTS_LOW;
            #else
                bool isUpper = position.y > 3;
                bool isStiff = false;
                bool isSuperStiff = false;
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
            if(wetness <= rainUpper || rainWind < 1.0) {
                offset = getCalmWindProfile(absolutePosition.xz, time, fine) * WIND_STRENGTH_CONSTANT_CALM;
            }

            // custom faster wind for bad weather
            if(isWater) {
                rainOffset = getStormyWindProfile(absolutePosition.xz, time * 0.4, fine * 1.7) * 1.5;
            } else if(wetness >= rainLower) {
                rainOffset = getStormyWindProfile(absolutePosition.xz, time, fine);
            }
            
            // mix the two winds depending on weather
            // in snowy biomes, rainOffset is nonexistent
            offset = mix(offset, rainOffset, smoothstep(rainLower, rainUpper, wetness) * rainWind);

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
                
                // stop waving in snowy areas
                offset *= rainWind;
            #endif

            
            if(isStiff) {
                offset *= 0.3;
            } else if (isFullWaving) {
                offset *= 0.5;
            }

            if(isSuperStiff) {
                offset *= 0.5;
            }

            if(isWater) {
                float offset1D = length(offset) * 0.4 - (smoothstep(rainLower, rainUpper, wetness) * 0.3 * WIND_STRENGTH_CONSTANT + 0.07);
                float modAbsPos = mod(absolutePosition.y, 1);
                if(modAbsPos > 1 - 0.01) offset1D = 0;

                offset1D *= modAbsPos * RCP_7 * 8;
                position.y += min(offset1D * WAVE_STRENGTH_CONSTANT_USER, 0.112);
            } else {
                position.xz += offset;
                // realistic value is 1.0
                float heightOffset = 0.8;
                // prevent z-fighting for full blocks
                if(isFullWaving) {
                    position.y += EPSILON;
                }
                #if !defined g_weather
                    else {
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
            float displacement = tile((position.xz + cameraPosition.xz + EPSILON) * 0.1, NOISE_PERLIN_4D, false).x - 0.5;
            position.y *= pow(pow(position.x, 2) + pow(position.z, 2), 0.02 * END_WARPING);
            position.y += displacement * (length(position.xz) * 0.2) * END_WARPING;
        }
    #endif

    #if (PANORAMIC_WORLD == 1 || PANORAMIC_WORLD == 2) && !defined gc_skybox && !defined g_skybasic
        // TODO: fix compatibility with TAA
        vec4 glPos = mul_m4_v3(gl_ModelViewMatrix, position);
        float yaw = atan(glPos.x, -glPos.z);
        float absYaw = abs(yaw);

        #if PANORAMIC_WORLD == 2
            // mult * some value 0.5<n<=1
            yaw = yaw * 0.6;
        #elif PANORAMIC_WORLD == 1
            yaw = mix(absYaw, 0.5 * absYaw + 0.3, smoothstep(0.5, 2.4, absYaw)) * sign(yaw);
        #endif

        glPos.xz = vec2(sin(yaw), -cos(yaw)) * length(glPos.xz);

        #if PANORAMIC_WORLD == 2
            const float n = 3;
            glPos.x /= glPos.z * n;
            glPos.x = mix(glPos.x * (1.5 - 0.5 * abs(glPos.x)), glPos.x, pow(glPos.x, 2));
            glPos.x *= glPos.z * n;
        #endif

        glPos = (gl_ProjectionMatrix * glPos);
    #else
        #if defined gc_sky
            vec4 glPos = toViewspace(gl_ProjectionMatrix, gl_ModelViewMatrix, position);
        #else
            vec4 glPos = toForcedViewspace(gl_ProjectionMatrix, gl_ModelViewMatrix, position);
        #endif
    #endif

    #if defined gc_basic
        if(renderStage == MC_RENDER_STAGE_OUTLINE && color.rgb == vec3(0)) {
            #if defined OUTLINE_THROUGH_BLOCKS
                glPos.z *= 0.2;
            #endif
        }
    #endif

    // apply jittering
    #if defined TAA_ENABLED
        offset = temporalAAOffsets[frameCounter % TAA_OFFSET_LEN];
        glPos.xy += offset * glPos.w / vec2(viewWidth, viewHeight);
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