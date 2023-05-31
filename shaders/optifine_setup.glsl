// use floats since they aren't capped at one (for easier color manipulation)
/*
const int colortex0Format = RGB16F;

const int colortex1Format = RGBA16F;

const int colortex2Format = RGB8;

const int colortex3Format = RGB8_SNORM;
const bool colortex3Clear = false;

const int colortex4Format = RGB8_SNORM;
const bool colortex4Clear = false;

const int shadowcolor1Format = RGBA16F;
const bool shadowcolor1Clear = false;
*/

const bool generateShadowMipmap = false;
const bool generateShadowColorMipmap = false;

#if AO_MODE == 1
    const float ambientOcclusionLevel = 1.0;
#else
   const float ambientOcclusionLevel = 0;
#endif

const float centerDepthHalflife = 1.0;

/* WETNESSHL:600.0 */
const float wetnessHalflife = 40.0;
/* DRYNESSHL:200.0 */
const float drynessHalflife = 70.0;

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


// block mappings

#define CUTOUTS 1
#define CUTOUTS_UPSIDE_DOWN 2
#define LIT 3
#define LIT_CUTOUTS 4
#define LIT_CUTOUTS_UPSIDE_DOWN 5
#define LIT_PARTIAL 6
#define LIT_PARTIAL_CUTOUTS 7
#define LIT_PARTIAL_CUTOUTS_UPSIDE_DOWN 8
#define LIT_PROBLEMATIC 9
#define WAVING_CUTOUTS_BOTTOM 10
#define WAVING_CUTOUTS_TOP 11
#define WAVING_CUTOUTS_BOTTOM_STIFF 12
#define WAVING_CUTOUTS_TOP_STIFF 13
#if defined WAVING_FULL_BLOCKS_ENABLED
    #define WAVING 14
    #define WAVING_STIFF 15
#else
    #define WAVING (-2)
    #define WAVING_STIFF (-2)
#endif
#define WATER 16
#define LAVA 17
#define WAVING_CUTOUTS_BOTTOM_LIT 18

// g stands for gbuffers
// gc stands for gbuffers category
#if defined g_skybasic || defined g_skytextured
    #define gc_sky
#endif
#if defined g_textured || defined g_textured_lit || defined g_particles
    #define gc_textured
#endif
#if defined g_water || defined g_hand_water || defined g_weather || defined g_clouds || defined gc_textured || defined g_particles_translucent
    #define gc_transparent
#endif
#if defined g_water || defined g_terrain
    #define gc_terrain
#endif
#if defined g_beaconbeam || defined g_entities_glowing || defined g_spidereyes || defined g_textured_lit
    #define gc_emissive
#endif
#if defined g_armor_glint || defined g_skytextured
    #define gc_additive
#endif
#if defined g_entities || defined g_entities_glowing || defined g_spidereyes || defined g_entities_translucent
    #define gc_entities
#endif
#if defined g_block || defined g_block_translucent
    #define gc_block_entities
#endif
#if defined DIM_USES_SKYBOX && defined g_skytextured
    #define gc_skybox
#endif