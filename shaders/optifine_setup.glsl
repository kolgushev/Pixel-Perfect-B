#if defined DIM_NETHER
/*
const bool colortex0Clear = true;

const bool colortex1Clear = true;
*/
#else
/*
const bool colortex0Clear = false;

const bool colortex1Clear = false;
*/
#endif

// use floats since they aren't capped at one (for easier color manipulation)
/*
const int colortex0Format = RGB16F;

const int colortex1Format = RGBA16F;

const int colortex2Format = RG8F;
const bool colortex3Clear = false;

const int colortex3Format = RGB8_SNORM;
const bool colortex4Clear = false;

const int shadowcolor1Format = R16F;
const bool shadowcolor1Clear = false;
*/

#if AO_MODE == 1
    const float ambientOcclusionLevel = 1.0;
#else
   const float ambientOcclusionLevel = 0;
#endif

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