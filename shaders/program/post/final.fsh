#include "/common_defs.glsl"

/* DRAWBUFFERS:0 */
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

    #define use_bicubic_filter
#endif

#define use_tonemapping

#include "/lib/use.glsl"

void main() {
    vec4 albedo = texture2D(colortex0, texcoord);
    buffer0 = albedo;

    #if defined SHADOW_DEBUG
        vec2 texcoordMod = supersampleSampleShift(texcoord);
        buffer0 = opaque1(texture(shadowcolor1, texcoordMod).r);
        buffer0 = textureBicubic(colortex0, (texcoord - 0.5) * 0.0125 + 0.5);
        // buffer0 = opaque(tile(texcoord * vec2(viewWidth, viewHeight), NOISE_CHECKERBOARD_1D, false).rgb);
        // buffer0 = opaque(texture3D(noisetex, vec3(0.0, 0.0, texcoord.x)).rgb);
        // buffer0 = opaque(texture3D(noisetex, vec3(0.0, 0.0, removeBorder(texcoord.x, 1.0 / 7.0))).rgb);
    #endif
}