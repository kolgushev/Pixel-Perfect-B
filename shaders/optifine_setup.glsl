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

const int shadowcolor1Format = RGB16_SNORM;
const bool shadowcolor1Clear = true;
*/

const float shadowDistanceRenderMul = 1.0;

const int noiseTextureResolution = 512;
const float sunPathRotation = -20.0;

#if AO_MODE == 1
    const float ambientOcclusionLevel = 1.0;
#else
   const float ambientOcclusionLevel = 0;
#endif