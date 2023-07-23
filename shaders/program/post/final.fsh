#include "/common_defs.glsl"

layout(location = 0) out vec4 buffer0;

in vec2 texcoord;

// uniforms

#define use_colortex0

#if defined SHADOW_DEBUG
    #define use_shadowcolor1

    #define use_get_shadow
    // #define use_sample_noisetex
    // #define use_view_height
    // #define use_view_width
#endif

#include "/lib/use.glsl"

void main() {
    vec4 albedo = texture(colortex0, texcoord);
    buffer0 = albedo;

    #if defined SHADOW_DEBUG
        vec2 texcoordMod = supersampleSampleShift(texcoord);
        buffer0 = opaque1(texture(shadowcolor1, texcoordMod).r);
        // buffer0 = opaque(tile(texcoord * vec2(viewWidth, viewHeight), NOISE_CHECKERBOARD_1D, false).rgb);
        // buffer0 = opaque(texture3D(noisetex, vec3(0.0, 0.0, texcoord.x)).rgb);
        // buffer0 = opaque(texture3D(noisetex, vec3(0.0, 0.0, removeBorder(texcoord.x, 1.0 / 7.0))).rgb);
    #endif
}