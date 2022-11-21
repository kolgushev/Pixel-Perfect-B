// Figure out weird textures and generate our own

#define data_pass

#include "/lib/common_defs.glsl"

#if defined DIM_NETHER
/*
const bool colortex0Clear = true;
const vec4 colortex0ClearColor = vec4(0, 0, 0, 0);

const bool colortex1Clear = true;
const vec4 colortex1ClearColor = vec4(0, 0, 0, 0);

const bool colortex2Clear = true;
const vec4 colortex2ClearColor = vec4(0, 0, 0, 0);
*/
#else
/*
const bool colortex0Clear = false;

const bool colortex1Clear = false;

const bool colortex2Clear = false;
*/
#endif

// use floats since they aren't capped at one (for easier color manipulation)
/*
const int colortex0Format = RGB16F;

const int colortex1Format = RGBA16F;

const int colortex2Format = RGBA16F;

const int colortex3Format = RG8;
const bool colortex3Clear = false;

const int colortex4Format = RGB8_SNORM;
const bool colortex4Clear = false;

const int colortex5Format = RGB16F;
const bool colortex5Clear = false;
*/

const int noiseTextureResolution = 512;
const float sunPathRotation = -20.0;

#if AO_MODE == 1
    const float ambientOcclusionLevel = 1.0;
#else
   const float ambientOcclusionLevel = 0;
#endif

in vec2 texcoord;

uniform sampler2D colortex1;

layout(location = 1) out vec4 b1;

#include "/lib/to_viewspace.glsl"
#include "/lib/linearize_depth.fsh"
#include "/lib/tonemapping.glsl"


void main() {
    b1 = texture(colortex1, texcoord);
}
