// These are already supported, this is mainly for linting
#define MC_RENDER_STAGE_NONE 0                      // Undefined
#define MC_RENDER_STAGE_SKY 1                       // Sky
#define MC_RENDER_STAGE_SUNSET 2                    // Sunset and sunrise overlay
#define MC_RENDER_STAGE_CUSTOM_SKY 3                // Custom sky
#define MC_RENDER_STAGE_SUN 4                       // Sun
#define MC_RENDER_STAGE_MOON 5                      // Moon
#define MC_RENDER_STAGE_STARS 6                     // Stars
#define MC_RENDER_STAGE_VOID 7                      // Void
#define MC_RENDER_STAGE_TERRAIN_SOLID 8             // Terrain solid
#define MC_RENDER_STAGE_TERRAIN_CUTOUT_MIPPED 9     // Terrain cutout mipped
#define MC_RENDER_STAGE_TERRAIN_CUTOUT 10            // Terrain cutout
#define MC_RENDER_STAGE_ENTITIES 11                  // Entities
#define MC_RENDER_STAGE_BLOCK_ENTITIES 12            // Block entities
#define MC_RENDER_STAGE_DESTROY 13                   // Destroy overlay
#define MC_RENDER_STAGE_OUTLINE 14                   // Selection outline
#define MC_RENDER_STAGE_DEBUG 15                     // Debug renderers
#define MC_RENDER_STAGE_HAND_SOLID 16                // Solid handheld objects
#define MC_RENDER_STAGE_TERRAIN_TRANSLUCENT 17       // Terrain translucent
#define MC_RENDER_STAGE_TRIPWIRE 18                  // Tripwire string
#define MC_RENDER_STAGE_PARTICLES 19                 // Particles
#define MC_RENDER_STAGE_CLOUDS 20                    // Clouds
#define MC_RENDER_STAGE_RAIN_SNOW 21                 // Rain and snow
#define MC_RENDER_STAGE_WORLD_BORDER 22              // World border
#define MC_RENDER_STAGE_HAND_TRANSLUCENT 23          // Translucent handheld objects


// mappings

// colorspace
#define SRGB_COLORSPACE 0
#define DCI_P3_COLORSPACE 1
#define DISPLAY_P3_COLORSPACE 2
#define REC2020_COLORSPACE 3
#define ADOBE_RGB_COLORSPACE 4
#define P3_D65_PQ_COLORSPACE 5
#define REC709_COLORSPACE 6
#define REC2100_HLG_COLORSPACE 7
#define REC2100_PQ_COLORSPACE 8
#define ACESCG_COLORSPACE 9
#define ACES2065_1_COLORSPACE 10
#define LINEAR_RGB_COLORSPACE 11
#define XYZ_COLORSPACE 12
#define OKLAB_COLORSPACE 13

// tonemap
#define NONE_TONEMAP 0
#define REINHARD_TONEMAP 1
#define HABLE_TONEMAP 2
#define ACES_FITTED_TONEMAP 3
#define ACES_APPROX_TONEMAP 4
#define CUSTOM_TONEMAP 5
#define HLG_TONEMAP 6

#include "/block_aliases.glsl"

// g stands for gbuffers
// gc stands for gbuffers category
#if defined g_particles || defined g_particles_translucent
    #define gc_particles
#endif
#if defined g_basic || defined g_basic_lit || defined g_line
    #define gc_basic
#endif
#if defined g_skybasic || defined g_skytextured
    #define gc_sky
#endif
#if defined g_textured || defined g_textured_lit || defined g_particles
    #define gc_textured
#endif
#if defined g_water || defined g_dh_water || defined g_hand_water || defined g_weather || defined g_clouds || defined gc_textured || defined g_particles_translucent || defined g_armor_glint
    #define gc_transparent
#endif
#if defined g_water || defined g_terrain
    #define gc_terrain
#endif
#if defined g_beaconbeam || defined g_entities_glowing || defined g_spidereyes || defined g_basic_lit || defined g_textured_lit
    #define gc_emissive
#endif
#if defined g_block || defined g_block_translucent
    #define gc_block_entities
#endif
#if defined g_entities || defined g_entities_glowing || defined g_spidereyes || defined g_entities_translucent || defined gc_block_entities
    #define gc_entities
#endif
#if defined DIM_USES_SKYBOX && defined g_skytextured
    #define gc_skybox
#endif
#if defined g_hand || defined g_hand_water
    #define gc_hand
#endif
#if defined gc_entities
    #define gc_fades_out
#endif
#if defined g_dh_terrain || defined g_dh_water
    #define gc_dh
#endif

#if defined gc_skybox && defined DIM_END
    #define NO_AA
#endif