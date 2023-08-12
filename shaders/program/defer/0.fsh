#include "/common_defs.glsl"

/* DRAWBUFFERS:1 */
layout(location = 0) out vec4 b1;

in vec2 texcoord;

// uniforms

#define use_colortex1
#define use_colortex2
#define use_colortex3
#define use_depthtex1
#define use_shadowcolor0

#define use_sun_position
#define use_moon_position
#define use_camera_position
#define use_sky_time
#define use_moon_brightness
#define use_rain_strength
#define use_lightning_bolt_position
#define use_is_lightning
#define use_direct_light_mult
#define use_night_vision
#define use_darkness_factor
#define use_darkness_light_factor
#define use_gbuffer_model_view
#define use_gbuffer_projection_inverse
#define use_gbuffer_model_view_inverse

#define use_tonemapping
#define use_color_manipulation
#define use_calculate_lighting
#define use_basic_direct_shading


#if defined SHADOWS_ENABLED
    #define use_shadowtex1
    #define use_shadow_projection
    #define use_shadow_model_view

    #define use_sample_noise
    #define use_get_shadow
#endif

#if defined TAA_ENABLED
    #define use_temporal_AA_offsets

    #define use_frame_counter
    #define use_view_width
    #define use_view_height
#endif


#include "/lib/use.glsl"

void main() {
    vec4 albedo = texture(colortex1, texcoord);
    
    vec3 lightmap = texture(colortex2, texcoord).rgb;
    
    vec3 normal = texture(colortex3, texcoord).rgb;
    vec3 normalViewspace = view(normal);

    float depth = texture(depthtex1, texcoord).r;
    #if defined TAA_ENABLED
        vec2 texcoordJittered = texcoord - temporalAAOffsets[frameCounter % TAA_OFFSET_LEN] / vec2(viewWidth, viewHeight);
    #else
        vec2 texcoordJittered = texcoord;
    #endif

    vec3 position = getWorldSpace(texcoordJittered, depth);

    #if defined SHADOWS_ENABLED
        vec3 pixelatedPosition = position;

        #if PIXELATED_SHADOWS != 0
            pixelatedPosition = ceil((position + cameraPosition) * PIXELATED_SHADOWS) / PIXELATED_SHADOWS - cameraPosition;
            position = mix(pixelatedPosition, position, ceil(abs(normal)));
        #endif

        float shadow = getShadow(
            position,
            pixelatedPosition + cameraPosition,
            shadowProjection,
            shadowModelView,
            texcoord,
            shadowtex1,
            lightmap.g,
            skyTime);
    #else
        #if defined VANILLA_SHADOWS
            float shadow = lightmap.g < 1 - RCP_16 ? 0 : 1;
        #else
            float shadow = basicDirectShading(lightmap.g);
        #endif
    #endif

    vec3 positionNormalized = normalize(position);
    mat2x3 lightColor = getLightColor(lightmap,
    normal,
    normalViewspace,
    positionNormalized,
    viewInverse(sunPosition),
    viewInverse(moonPosition),
    rainStrength,
    shadowcolor0
    );

    vec3 lightningColor = vec3(0.0);

    if(lightningBoltPosition.w == 1.0) {
        #if !defined SHADOWS_ENABLED
            float depth = texture(depthtex1, texcoord).r;
            vec3 position = getWorldSpace(texcoord, depth);
        #endif

        lightningColor = lightningFlash(1, rainStrength) / (pow(distance(position.xz, lightningBoltPosition.xz), 2) + 1.0);
        lightningColor *= DIRECT_LIGHTNING_STRENGTH;
    }

    #if !defined DEBUG_VIEW
        albedo.rgb *= lightColor[0] + (lightColor[1] + lightningColor) * shadow;
    #endif

    b1 = albedo;
}