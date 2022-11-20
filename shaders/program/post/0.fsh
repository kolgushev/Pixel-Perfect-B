// Figure out weird textures and generate our own

#define data_pass

#include "/lib/common_defs.glsl"

layout(location = 0) out vec4 buffer0;

in vec2 texcoord;
uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;

const int noiseTextureResolution = 512;
const float sunPathRotation = -20.0;

#if AO_MODE == 1
    const float ambientOcclusionLevel = 1.0;
#else
   const float ambientOcclusionLevel = 0;
#endif


// use floats since they aren't capped at one (for easier color manipulation)
/*
const int colortex0Format = RGBA16F;
const bool colortex0Clear = false;

const int colortex1Format = RGBA16F;
const bool colortex1Clear = false;

const int colortex2Format = RGBA16F;
const bool colortex2Clear = false;

const int colortex3Format = RG8;
const bool colortex3Clear = false;
*/

#include "/lib/to_viewspace.glsl"
#include "/lib/linearize_depth.fsh"
#include "/lib/tonemapping.glsl"

// masks:
// r - sky
// g - terrain / grass normals
// b - emissiveness

// coord.ba and lightmap.a combine to form velocity vectors

void main() {
    buffer0 = texture(colortex2, texcoord);
}
